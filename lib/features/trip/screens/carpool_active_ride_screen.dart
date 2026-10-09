import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_pop_scope_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/loader_widget.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/message/controllers/message_controller.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/screens/sos_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/carpool_active_ride_map_card.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

/// Carpool Active Ride Screen matching new requested design.
class CarpoolActiveRideScreen extends StatefulWidget {
  final String tripId;
  const CarpoolActiveRideScreen({super.key, required this.tripId});

  @override
  State<CarpoolActiveRideScreen> createState() =>
      _CarpoolActiveRideScreenState();
}

class _CarpoolActiveRideScreenState extends State<CarpoolActiveRideScreen> {
  static const Color _primaryBlue = Color(0xFF00A3EC);
  static const Color _textDark = Color(0xFF1E2432);
  static const Color _textSubtle = Color(0xFF8C94A3);
  static const Color _dropoffRed = Color(0xFFEF5350);

  @override
  void initState() {
    super.initState();
    Get.find<RideController>().getRideDetails(widget.tripId, isUpdate: false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  LatLng _toCorrectLatLng(double a, double b) {
    return MapBoundHelper.toCorrectLatLng(a, b);
  }

  bool _isReturn(TripDetails trip) {
    if (trip.isReturnLeg) return true;
    final leg = (trip.effectiveTripLeg ?? trip.currentTripLeg ?? '').toLowerCase().trim();
    if (leg == 'return' || leg == 'evening' || leg == 'night') return true;
    final rName = (trip.routeName ?? '').toLowerCase();
    final ttl = (trip.title ?? '').toLowerCase();
    if (rName.contains('return_trip') || rName.contains('night_trip') || ttl.contains('return_trip') || ttl.contains('night_trip')) {
      return true;
    }
    return false;
  }



  LatLng? _resolveRouteEndLatLng(TripDetails trip) {
    final bool isReturn = _isReturn(trip);
    if (isReturn) {
      if (trip.startCoordinates?.coordinates != null &&
          trip.startCoordinates!.coordinates!.length >= 2) {
        return _toCorrectLatLng(
          trip.startCoordinates!.coordinates![0],
          trip.startCoordinates!.coordinates![1],
        );
      }
      if (trip.pickupCoordinates?.coordinates != null &&
          trip.pickupCoordinates!.coordinates!.length >= 2) {
        return _toCorrectLatLng(
          trip.pickupCoordinates!.coordinates![0],
          trip.pickupCoordinates!.coordinates![1],
        );
      }
      final driverStart = MapBoundHelper.getDriverStart(trip);
      if (driverStart != null) return driverStart;
    }

    if (trip.endCoordinates?.coordinates != null &&
        trip.endCoordinates!.coordinates!.length >= 2) {
      return _toCorrectLatLng(
        trip.endCoordinates!.coordinates![1],
        trip.endCoordinates!.coordinates![0],
      );
    }
    if (trip.destinationCoordinates?.coordinates != null &&
        trip.destinationCoordinates!.coordinates!.length >= 2) {
      return _toCorrectLatLng(
        trip.destinationCoordinates!.coordinates![1],
        trip.destinationCoordinates!.coordinates![0],
      );
    }
    final driverEnd = MapBoundHelper.getDriverEnd(trip);
    if (driverEnd != null) return driverEnd;

    final routePoly = MapBoundHelper.getRoutePolylinePoints(trip);
    if (routePoly.isNotEmpty) {
      return isReturn ? routePoly.first : routePoly.last;
    }

    return isReturn
        ? MapBoundHelper.getDriverStart(trip) ?? MapBoundHelper.getDriverEnd(trip)
        : MapBoundHelper.getDriverEnd(trip) ?? MapBoundHelper.getDriverStart(trip);
  }

  Future<void> _openDirectionsInGoogleMaps({
    required LatLng? targetPos,
    required String targetAddress,
  }) async {
    try {
      double? originLat;
      double? originLng;

      try {
        if (Get.isRegistered<LocationController>()) {
          final loc = Get.find<LocationController>().initialPosition;
          if (loc.latitude != 0.0 || loc.longitude != 0.0) {
            originLat = loc.latitude;
            originLng = loc.longitude;
          }
        }
      } catch (_) {}

      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            Position currentPosition = await Geolocator.getCurrentPosition(
              locationSettings:
                  const LocationSettings(accuracy: LocationAccuracy.high),
            );
            originLat = currentPosition.latitude;
            originLng = currentPosition.longitude;
          }
        }
      } catch (e) {
        debugPrint('Error getting current location: $e');
      }

      String googleMapsUrl;
      if (targetPos != null &&
          (targetPos.latitude != 0.0 || targetPos.longitude != 0.0)) {
        if (originLat != null && originLng != null) {
          googleMapsUrl =
              'https://www.google.com/maps/dir/?api=1&origin=$originLat,$originLng&destination=${targetPos.latitude},${targetPos.longitude}&travelmode=driving';
        } else {
          googleMapsUrl =
              'https://www.google.com/maps/dir/?api=1&destination=${targetPos.latitude},${targetPos.longitude}&travelmode=driving';
        }
      } else {
        final encodedAddress = Uri.encodeComponent(targetAddress);
        if (originLat != null && originLng != null) {
          googleMapsUrl =
              'https://www.google.com/maps/dir/?api=1&origin=$originLat,$originLng&destination=$encodedAddress&travelmode=driving';
        } else {
          googleMapsUrl =
              'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
        }
      }

      final Uri uri = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        showCustomSnackBar('Could not open Google Maps'.tr);
      }
    } catch (e) {
      debugPrint('Error launching Google Maps directions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: Scaffold(
        appBar: AppBar(
          title: Text('trip_details'.tr),
          backgroundColor: const Color(0xFFF6F8F8),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        backgroundColor: const Color(0xFFF6F8F8),
        body: GetBuilder<RideController>(
          builder: (rideController) {
            final trip = rideController.tripDetails;
            if (trip == null) {
              return const LoaderWidget();
            }

            final String status =
                (trip.currentStatus ?? 'accepted').toLowerCase();
            final bool isOngoing = status == 'ongoing' || status == 'on_going';

            return BodyWidget(
              body: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    /// 1. REAL GOOGLE MAP CONTAINER
                    CarpoolActiveRideMapCard(trip: trip),
                    const SizedBox(height: 14),

                    /// 2. ROUTE CARD (ROUTE NAME, START & END POINTS)
                    _buildRouteCard(trip),
                    const SizedBox(height: 12),

                    /// 3. DRIVER INFO CARD
                    if (trip.driver != null) ...[
                      _buildDriverCard(trip),
                      const SizedBox(height: 12),
                    ],

                    /// 4. OTP START TRIP CODE CARD (ONLY IF NOT STARTED YET)
                    if (!isOngoing &&
                        trip.otp != null &&
                        trip.otp!.isNotEmpty) ...[
                      _buildOtpCard(trip),
                      const SizedBox(height: 12),
                    ],

                    /// 5. MESSAGE & CALL ACTION BUTTONS
                    _buildActionButtons(trip),
                    const SizedBox(height: 12),

                    /// 6. RIDING WITH YOU (CO-PASSENGERS) CARD
                    _buildRidingWithCard(trip),
                    const SizedBox(height: 12),

                    /// 7. EMERGENCY SOS CARD (ENABLED ONLY WHEN TRIP IS ONGOING)
                    _buildSosCard(trip, isOngoing: isOngoing),
                    const SizedBox(height: 12),

                    /// 8. CANCEL TRIP ACTION
                    _buildCancelTripButton(trip),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 2. ROUTE CARD (ROUTE NAME, START POINT, END POINT, DATE & TIME)
  Widget _buildRouteCard(TripDetails trip) {
    final bool isReturnLeg = _isReturn(trip);

    final String routeName =
        (trip.routeName != null && trip.routeName!.trim().isNotEmpty)
            ? trip.routeName!.trim()
            : ((trip.title != null && trip.title!.trim().isNotEmpty)
                ? trip.title!.trim()
                : '');

    final String defaultStartAddr = trip.startAddressDisplay.isNotEmpty
        ? trip.startAddressDisplay
        : (trip.startAddress ?? trip.pickupAddress ?? 'Start Point');

    final String defaultEndAddr = trip.endAddressDisplay.isNotEmpty
        ? trip.endAddressDisplay
        : (trip.endAddress ?? trip.destinationAddress ?? 'End Point');

    final String startAddress =
        isReturnLeg ? defaultEndAddr : defaultStartAddr;
    final String endAddress =
        isReturnLeg ? defaultStartAddr : defaultEndAddr;

    final LatLng? endPos = _resolveRouteEndLatLng(trip);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBEFF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (routeName.isNotEmpty) ...[
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F6FE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.alt_route_rounded,
                          size: 14,
                          color: _primaryBlue,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            routeName,
                            style: textBold.copyWith(
                              fontSize: 12,
                              color: const Color(0xFF0284C7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (trip.hasReturnTrip || trip.hasReturnLeg == true)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isReturnLeg
                        ? const Color(0xFFF3E8FF)
                        : const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isReturnLeg
                            ? Icons.nights_stay_rounded
                            : Icons.wb_sunny_rounded,
                        size: 14,
                        color: isReturnLeg
                            ? const Color(0xFF7C3AED)
                            : const Color(0xFFEA580C),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isReturnLeg ? 'night_trip'.tr : 'morning_trip'.tr,
                        style: textBold.copyWith(
                          fontSize: 11,
                          color: isReturnLeg
                              ? const Color(0xFF7C3AED)
                              : const Color(0xFFEA580C),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 44,
                    color: Colors.grey.shade300,
                  ),
                  const Icon(
                    Icons.location_on,
                    size: 14,
                    color: _dropoffRed,
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'start_address'.tr.isNotEmpty &&
                                  !'start_address'.tr.contains('start_address')
                              ? 'start_address'.tr.toUpperCase()
                              : 'START POINT',
                          style: textSemiBold.copyWith(
                            color: _textSubtle,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                        // InkWell(
                        //   onTap: () => _openDirectionsInGoogleMaps(
                        //     targetPos: startPos,
                        //     targetAddress: startAddress,
                        //   ),
                        //   borderRadius: BorderRadius.circular(16),
                        //   child: Padding(
                        //     padding: const EdgeInsets.symmetric(
                        //         horizontal: 4, vertical: 2),
                        //     child: Image.asset(
                        //       Images.mapIcon,
                        //       width: 22,
                        //       height: 22,
                        //       fit: BoxFit.contain,
                        //       errorBuilder: (context, error, stackTrace) =>
                        //           const Icon(
                        //         Icons.map,
                        //         size: 20,
                        //         color: _primaryBlue,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      startAddress,
                      style: textBold.copyWith(
                        color: _textDark,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'end_address'.tr.isNotEmpty &&
                                  !'end_address'.tr.contains('end_address')
                              ? 'end_address'.tr.toUpperCase()
                              : 'END POINT',
                          style: textSemiBold.copyWith(
                            color: _textSubtle,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                        InkWell(
                          onTap: () => _openDirectionsInGoogleMaps(
                            targetPos: endPos,
                            targetAddress: endAddress,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            // child: Image.asset(
                            //   Images.mapIcon,
                            //   width: 22,
                            //   height: 22,
                            //   fit: BoxFit.contain,
                            //   errorBuilder: (context, error, stackTrace) =>
                            //       const Icon(
                            //     Icons.map,
                            //     size: 20,
                            //     color: _primaryBlue,
                            //   ),
                            // ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      endAddress,
                      style: textBold.copyWith(
                        color: _textDark,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0F3F7)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${trip.formattedDate.isNotEmpty ? trip.formattedDate : 'Today'} · ${trip.activeLegFormattedTime}',
                style: textRegular.copyWith(
                  color: _textSubtle,
                  fontSize: 12,
                ),
              ),
              if (trip.carpoolType != null && trip.carpoolType!.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trip.carpoolType!.capitalizeFirst ?? trip.carpoolType!,
                    style: textMedium.copyWith(
                      color: const Color(0xFF475569),
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 3. DRIVER CARD WITH ESTIMATED ARRIVAL TIME
  Widget _buildDriverCard(TripDetails trip) {
    final driver = trip.driver!;
    final vehicle = trip.vehicle;
    final String status = (trip.currentStatus ?? 'accepted').toLowerCase();
    final bool isOngoing = status == 'ongoing' || status == 'on_going';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBEFF5)),
      ),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F6FE),
                shape: BoxShape.circle,
              ),
              child: (driver.profileImage != null &&
                      driver.profileImage!.isNotEmpty)
                  ? ImageWidget(
                      image: driver.profileImage!,
                      width: 48,
                      height: 48,
                      radius: 24,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Text(
                        driver.displayName.isNotEmpty
                            ? driver.displayName[0].toUpperCase()
                            : 'D',
                        style: textBold.copyWith(
                          color: _primaryBlue,
                          fontSize: 18,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.displayName.isNotEmpty ? driver.displayName : 'Driver',
                  style: textBold.copyWith(
                    color: _textDark,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  vehicle != null
                      ? '${vehicle.displayName} · ${vehicle.licencePlateNumber ?? ''}'
                      : 'Car Details',
                  style: textRegular.copyWith(
                    color: _textSubtle,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      '${trip.driverRatingText} · Verified driver',
                      style: textRegular.copyWith(
                        color: _textSubtle,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isOngoing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F6FE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    trip.realEstamitedTimeText,
                    style: textBold.copyWith(
                      color: _primaryBlue,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'away',
                    style: textRegular.copyWith(
                      color: _primaryBlue,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 4. START TRIP CODE (OTP) CARD - SHOWN ONLY IF TRIP NOT STARTED YET
  Widget _buildOtpCard(TripDetails trip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBEFF5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF2E7D32),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start trip code',
                  style: textBold.copyWith(
                    color: _textDark,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Share this code with your driver when they arrive.',
                  style: textRegular.copyWith(
                    color: _textSubtle,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  trip.otp ?? '----',
                  style: textBold.copyWith(
                    color: _textDark,
                    fontSize: 22,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Only share it when you're ready to start the trip.",
                  style: textRegular.copyWith(
                    color: _textSubtle,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 5. MESSAGE & CALL BUTTONS
  Widget _buildActionButtons(TripDetails trip) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                final driverId = trip.driver?.id;
                final tripId = trip.id;
                if (driverId != null &&
                    driverId.isNotEmpty &&
                    tripId != null &&
                    tripId.isNotEmpty) {
                  Get.find<MessageController>().createChannel(driverId, tripId);
                }
              },
              icon: const Icon(Icons.chat_bubble_outline_rounded,
                  size: 20, color: _primaryBlue),
              label: Text(
                'Message',
                style: textBold.copyWith(
                  color: _textDark,
                  fontSize: 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEBEFF5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () async {
                final phone = trip.driver?.phone;
                if (phone != null && phone.isNotEmpty) {
                  final Uri launchUri = Uri(scheme: 'tel', path: phone);
                  if (await canLaunchUrl(launchUri)) {
                    await launchUrl(launchUri);
                  }
                }
              },
              icon: const Icon(Icons.phone_outlined,
                  size: 20, color: _primaryBlue),
              label: Text(
                'Call',
                style: textBold.copyWith(
                  color: _textDark,
                  fontSize: 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEBEFF5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 6. RIDING WITH YOU CARD (CO-PASSENGERS)
  Widget _buildRidingWithCard(TripDetails trip) {
    final coPassengers = trip.coPassengers;
    final int passengerCount = (coPassengers != null && coPassengers.isNotEmpty)
        ? coPassengers.length
        : 3;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBEFF5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Riding with you',
                style: textBold.copyWith(
                  color: _textDark,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$passengerCount passengers sharing this route',
                style: textRegular.copyWith(
                  color: _textSubtle,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _passengerAvatar(
                  'S', const Color(0xFFFFF3E0), const Color(0xFFEF6C00)),
              const SizedBox(width: 4),
              _passengerAvatar(
                  'N', const Color(0xFFEDE7F6), const Color(0xFF673AB7)),
              const SizedBox(width: 4),
              _passengerAvatar('+1', const Color(0xFFF0F3F7), _textSubtle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _passengerAvatar(String label, Color bg, Color textCol) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          style: textBold.copyWith(
            color: textCol,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  /// 7. SOS / EMERGENCY HELP CARD (ENABLED ONLY WHEN TRIP IS ONGOING)
  Widget _buildCancelTripButton(TripDetails trip) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _confirmCancelTrip(trip),
        icon: const Icon(Icons.close_rounded, size: 20),
        label: Text(
          'cancel_ride'.tr,
          style: textBold.copyWith(fontSize: 15),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFD32F2F),
          side: const BorderSide(color: Color(0xFFE57373)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmCancelTrip(TripDetails trip) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('cancel_ride'.tr),
        content: Text('Are you sure you want to cancel this trip?'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('no'.tr),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
            child: Text('yes'.tr),
          ),
        ],
      ),
    );

    if (shouldCancel != true || !mounted) return;

    final response = await Get.find<RideController>().tripStatusUpdate(
      trip.id ?? widget.tripId,
      'cancelled',
      'trip_cancelled_successfully',
      '',
    );
    if (response?.statusCode == 200 && mounted) {
      Get.offAll(() => const DashboardScreen());
    }
  }

  /// 7. SOS / EMERGENCY HELP CARD (ENABLED ONLY WHEN TRIP IS ONGOING)
  Widget _buildSosCard(TripDetails trip, {required bool isOngoing}) {
    final Color bgColor =
        isOngoing ? const Color(0xFFFFEBEE) : const Color(0xFFF9FAFC);
    final Color borderColor =
        isOngoing ? const Color(0xFFFFCDD2) : const Color(0xFFEBEFF5);
    final Color iconBgColor =
        isOngoing ? const Color(0xFFFFCDD2) : const Color(0xFFF0F3F7);
    final Color iconColor =
        isOngoing ? const Color(0xFFD32F2F) : const Color(0xFFB0BEC5);
    final Color buttonColor =
        isOngoing ? const Color(0xFFD32F2F) : const Color(0xFFCFD8DC);
    final Color titleColor = isOngoing ? _textDark : _textSubtle;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need emergency help?',
                      style: textBold.copyWith(
                        color: titleColor,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Available only during your Carpool trip',
                      style: textRegular.copyWith(
                        color: _textSubtle,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isOngoing
                    ? () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Activate SOS'.tr,
                                          style:
                                              textBold.copyWith(fontSize: 16),
                                        ),
                                        IconButton(
                                          onPressed: () => Get.back(),
                                          icon: const Icon(Icons.close),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'This will alert Drivo and notify your emergency contact'
                                          .tr,
                                      style: textRegular.copyWith(fontSize: 13),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 44,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFD32F2F),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () {
                                          Get.back();
                                          final locationController =
                                              Get.find<LocationController>();
                                          final userAddress = locationController
                                              .getUserAddress();
                                          final lat = userAddress?.latitude;
                                          final lng = userAddress?.longitude;

                                          final profileController =
                                              Get.find<ProfileController>();
                                          profileController
                                              .sendSos(
                                            tripId: trip.id ?? widget.tripId,
                                            latitude: lat,
                                            longitude: lng,
                                          )
                                              .then((response) async {
                                            if (response.statusCode == 200) {
                                              showCustomSnackBar(
                                                'sos_sent_successfully'.tr,
                                                isError: false,
                                              );
                                              final emergencyPhone =
                                                  profileController
                                                      .profileModel
                                                      ?.data
                                                      ?.emergencyContactPhone;
                                              if (emergencyPhone != null &&
                                                  emergencyPhone.isNotEmpty) {
                                                final Uri launchUri = Uri(
                                                  scheme: 'tel',
                                                  path: emergencyPhone,
                                                );
                                                if (await canLaunchUrl(
                                                    launchUri)) {
                                                  await launchUrl(launchUri);
                                                }
                                              }
                                            } else if (response.statusCode ==
                                                403) {
                                              showCustomSnackBar(
                                                response.body?['message'] ??
                                                    'Please save an emergency contact name and phone before sending SOS.'
                                                        .tr,
                                              );
                                              Get.to(() => const SosScreen());
                                            }
                                          });
                                        },
                                        child: Text(
                                          'Send SOS'.tr,
                                          style: textBold.copyWith(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  disabledBackgroundColor: const Color(0xFFE0E0E0),
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'SOS',
                  style: textBold.copyWith(
                    color: isOngoing ? Colors.white : const Color(0xFF9E9E9E),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Use only in an emergency',
            style: textRegular.copyWith(
              color: isOngoing ? const Color(0xFFD32F2F) : _textSubtle,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
