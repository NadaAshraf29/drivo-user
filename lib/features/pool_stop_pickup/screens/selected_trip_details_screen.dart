import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/pool_ride_model.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/selected_trip_details_widgets/selected_trip_banner_widget.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/selected_trip_details_widgets/selected_trip_driver_card_widget.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/selected_trip_details_widgets/selected_trip_info_card_widget.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/selected_trip_details_widgets/selected_trip_map_widget.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/selected_trip_details_widgets/selected_trip_return_ride_widget.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';
import 'package:ride_sharing_user_app/features/walkthrough/controllers/walkthrough_controller.dart';
import 'package:ride_sharing_user_app/features/walkthrough/domain/models/walkthrough_model.dart';
import 'package:ride_sharing_user_app/features/walkthrough/helpers/walkthrough_helper.dart';
import 'package:ride_sharing_user_app/features/walkthrough/widgets/how_it_works_button.dart';

class SelectedTripDetailsScreen extends StatefulWidget {
  final PoolRide trip;

  const SelectedTripDetailsScreen({
    super.key,
    required this.trip,
  });

  @override
  State<SelectedTripDetailsScreen> createState() =>
      _SelectedTripDetailsScreenState();
}

class _SelectedTripDetailsScreenState extends State<SelectedTripDetailsScreen> {
  final GlobalKey _summaryKey = GlobalKey();
  final GlobalKey _driverKey = GlobalKey();
  final GlobalKey _confirmKey = GlobalKey();

  void _startWalkthrough({bool isManual = false}) {
    if (!Get.isRegistered<WalkthroughController>()) return;
    final walkthroughCtrl = Get.find<WalkthroughController>();
    walkthroughCtrl.startFlow(
      WalkthroughFlowType.booking,
      WalkthroughHelper.getBookingSteps(),
      isManual: isManual,
    );
  }

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<WalkthroughController>()) {
      final walkthroughCtrl = Get.find<WalkthroughController>();
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetBookingSummary, _summaryKey);
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetBookingDriver, _driverKey);
      walkthroughCtrl.registerTarget(
          WalkthroughHelper.targetBookingConfirm, _confirmKey);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!walkthroughCtrl.hasSeenFlow(WalkthroughFlowType.booking)) {
          Future.delayed(const Duration(milliseconds: 650), () {
            if (mounted &&
                !walkthroughCtrl.hasSeenFlow(WalkthroughFlowType.booking)) {
              _startWalkthrough(isManual: false);
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String titleText = 'Carpool Trip'.tr;
    if (widget.trip.carpoolTypeLabel != null &&
        widget.trip.carpoolTypeLabel.toString().trim().isNotEmpty) {
      titleText = widget.trip.carpoolTypeLabel.toString();
    } else if (widget.trip.carpoolType != null &&
        widget.trip.carpoolType.toString().trim().isNotEmpty) {
      final type = widget.trip.carpoolType.toString().toLowerCase();
      if (type == 'routine') {
        titleText = 'Routine Carpool'.tr;
      } else if (type == 'trip') {
        titleText = 'Daily Carpool'.tr;
      } else if (type == 'travel') {
        titleText = 'Travel Carpool'.tr;
      } else if (type == 'north_coast') {
        titleText = 'North Coast Trip'.tr;
      } else if (type == 'school') {
        titleText = 'School Route'.tr;
      } else if (type == 'university') {
        titleText = 'University Route'.tr;
      }
    }

    String subtitleText = 'Your scheduled carpool trip details.'.tr;
    final tripType = (widget.trip.carpoolType ?? '').toString().toLowerCase();
    if (tripType == 'routine') {
      subtitleText = 'Your active daily routine subscription.'.tr;
    } else if (tripType == 'university') {
      subtitleText = 'Your active university subscription.'.tr;
    } else if (tripType == 'school') {
      subtitleText = 'Your active school route subscription.'.tr;
    } else if (tripType == 'travel') {
      subtitleText = 'Your intercity travel ride details.'.tr;
    } else if (tripType == 'north_coast') {
      subtitleText = 'Your seasonal coastal ride details.'.tr;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: HowItWorksButton(
              onTap: () => _startWalkthrough(isManual: true),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Header section
                Text(
                  titleText,
                  style: textBold.copyWith(
                    fontSize: 28,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitleText,
                  style: textRegular.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),

                // Subscription Banner
                SelectedTripBannerWidget(trip: widget.trip),
                const SizedBox(height: 16),

                // Main Info Card
                KeyedSubtree(
                  key: _summaryKey,
                  child: SelectedTripInfoCardWidget(trip: widget.trip),
                ),
                const SizedBox(height: 16),

                // Return Ride Card
                if (widget.trip.carpoolType == 'routine')
                  SelectedTripReturnRideWidget(trip: widget.trip),
                const SizedBox(height: 16),

                // Driver Info Card
                KeyedSubtree(
                  key: _driverKey,
                  child: SelectedTripDriverCardWidget(
                    trip: widget.trip,
                    onDetailsTap: () => _showDriverDetails(context),
                  ),
                ),
                const SizedBox(height: 16),

                // Google Map Preview Widget
                SelectedTripMapWidget(
                  trip: widget.trip,
                  onTap: () => _showRouteMap(widget.trip, context),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Bottom Sticky Action Bar with "Book now" button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: KeyedSubtree(
                  key: _confirmKey,
                  child: ElevatedButton(
                    onPressed: () => _onBookNowPressed(widget.trip),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF08A9F0),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      'Book now'.tr,
                      style: textBold.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onBookNowPressed(dynamic trip) {
    final rideController = Get.find<RideController>();
    rideController.selectCarpoolTrip(
      trip,
      bookingType: 'all',
      selectedDates: const [],
    );
  }

  void _showDriverDetails(BuildContext context) {
    final driver = widget.trip.driver;
    final vehicle = widget.trip.vehicle;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Driver & Vehicle Details',
              style: textBold.copyWith(
                  fontSize: 18, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person, color: Color(0xFF08A9F0)),
              title: Text(driver.fullName.isNotEmpty ? driver.fullName : 'Ahmed Samir', style: textBold),
              subtitle: Text('Rating: ${driver.rating ?? 4.9} ★',
                  style: textRegular),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.directions_car, color: Color(0xFF08A9F0)),
              title: Text(
                  '${vehicle.brand.isNotEmpty ? vehicle.brand : 'Toyota'} ${vehicle.model.isNotEmpty ? vehicle.model : 'Hiace'}',
                  style: textBold),
              subtitle: Text('Plate: ${(vehicle.plateNumber != null && vehicle.plateNumber!.isNotEmpty) ? vehicle.plateNumber! : '123 ABC'}',
                  style: textRegular),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showRouteMap(dynamic trip, BuildContext context) {
    final List<LatLng> decodedPoints =
        MapBoundHelper.getRoutePolylinePoints(trip);
    final LatLng? startPos =
        MapBoundHelper.getDriverStart(trip, decodedPoints);
    final LatLng? endPos =
        MapBoundHelper.getDriverEnd(trip, decodedPoints);

    final double? closestPickupLat = trip.closestPickup?.lat;
    final double? closestPickupLng = trip.closestPickup?.lng;
    final double? closestDropoffLat = trip.closestDropoff?.lat;
    final double? closestDropoffLng = trip.closestDropoff?.lng;

    final String pickupSpotName = trip.closestPickup?.placeName ??
        trip.pickupAddress ??
        'Pickup Meeting Point';
    final String dropoffSpotName = trip.closestDropoff?.placeName ??
        trip.dropoffAddress ??
        'Dropoff Spot';

    final Set<Marker> markers = {};
    final List<LatLng> boundsPoints = [];
    final Set<Polyline> polylines = {};

    boundsPoints.addAll(decodedPoints);

    final LatLng? closestPickupPos = (closestPickupLat != null && closestPickupLng != null && (closestPickupLat != 0.0 || closestPickupLng != 0.0))
        ? MapBoundHelper.toCorrectLatLng(closestPickupLat, closestPickupLng)
        : null;
    final LatLng? closestDropoffPos = (closestDropoffLat != null && closestDropoffLng != null && (closestDropoffLat != 0.0 || closestDropoffLng != 0.0))
        ? MapBoundHelper.toCorrectLatLng(closestDropoffLat, closestDropoffLng)
        : null;

    if (startPos != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: startPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: 'Start Point (Driver)'.tr, snippet: trip.pickupAddress),
        ),
      );
      boundsPoints.add(startPos);
    }

    if (closestPickupPos != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('closest_pickup'),
          position: closestPickupPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          infoWindow: InfoWindow(title: 'Pickup Meeting Point'.tr, snippet: pickupSpotName),
        ),
      );
      boundsPoints.add(closestPickupPos);
    }

    if (closestDropoffPos != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('closest_dropoff'),
          position: closestDropoffPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(title: 'Dropoff Spot'.tr, snippet: dropoffSpotName),
        ),
      );
      boundsPoints.add(closestDropoffPos);
    }

    if (endPos != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('end'),
          position: endPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: 'End Point (Driver)'.tr, snippet: trip.dropoffAddress),
        ),
      );
      boundsPoints.add(endPos);
    }

    if (decodedPoints.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: decodedPoints,
          color: const Color(0xFF08A9F0),
          width: 5,
        ),
      );
    }

    final double? targetNavLat = closestPickupPos?.latitude ?? startPos?.latitude;
    final double? targetNavLng = closestPickupPos?.longitude ?? startPos?.longitude;

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Full Trip Route'.tr,
                        style: textBold.copyWith(
                          fontSize: 16,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: closestPickupPos ?? startPos ?? const LatLng(30.0444, 31.2357),
                      zoom: 13,
                    ),
                    markers: markers,
                    polylines: polylines,
                    myLocationEnabled: false,
                    zoomControlsEnabled: true,
                    onMapCreated: (controller) {
                      if (boundsPoints.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          controller.animateCamera(
                            CameraUpdate.newLatLngBounds(
                              MapBoundHelper.computeBounds(boundsPoints),
                              50,
                            ),
                          );
                        });
                      }
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00C48C),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pickupSpotName,
                              style: textBold.copyWith(
                                fontSize: 13,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (targetNavLat != null && targetNavLng != null) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: () => _openInGoogleMaps(
                              targetNavLat,
                              targetNavLng,
                            ),
                            icon: const Icon(
                              Icons.directions_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: Text(
                              'Navigate to Pickup Spot'.tr,
                              style: textBold.copyWith(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF08A9F0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openInGoogleMaps(double lat, double lng) async {
    try {
      final point = MapBoundHelper.toCorrectLatLng(lat, lng);
      final cLat = point.latitude;
      final cLng = point.longitude;
      final url =
          'https://www.google.com/maps/dir/?api=1&destination=$cLat,$cLng&travelmode=driving';

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        final fallbackUrl = 'https://maps.google.com/maps?q=$cLat,$cLng';
        if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
          await launchUrl(
            Uri.parse(fallbackUrl),
            mode: LaunchMode.externalApplication,
          );
        } else {
          Get.snackbar(
            'Error',
            'Could not open Google Maps. Please install Google Maps app.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      debugPrint('Error opening Google Maps: $e');
      Get.snackbar(
        'Error',
        'Could not open Google Maps. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
