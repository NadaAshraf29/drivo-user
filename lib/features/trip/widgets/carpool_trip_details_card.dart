import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/controller/create_your_own_trip_controller.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/features/trip/screens/carpool_active_ride_screen.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_paymob_sdk/flutter_paymob_sdk.dart';
import 'package:ride_sharing_user_app/features/message/controllers/message_controller.dart';
import 'package:ride_sharing_user_app/features/payment/domain/services/paymob_service.dart';
import 'package:ride_sharing_user_app/features/payment/widget/carpool_payment_widgets/carpool_payment_success_bottom_sheet.dart';

/// Clean light trip details card UI matching requested design.
class CarpoolTripDetailsCard extends StatefulWidget {
  final TripDetails tripDetails;

  const CarpoolTripDetailsCard({super.key, required this.tripDetails});

  @override
  State<CarpoolTripDetailsCard> createState() => _CarpoolTripDetailsCardState();
}

class _CarpoolTripDetailsCardState extends State<CarpoolTripDetailsCard> {
  TripDetails get tripDetails => widget.tripDetails;

  static const Color _primaryBlue = Color(0xFF00A3EC);
  static const Color _textDark = Color(0xFF1E2432);
  static const Color _textSubtle = Color(0xFF8C94A3);
  static const Color _pickupBlue = Color(0xFF00A3EC);
  static const Color _dropoffRed = Color(0xFFEF5350);

  static final Map<String, String> _addressCache = {};
  String? _resolvedPickupAddress;
  String? _resolvedDropoffAddress;
  bool _isPaymobSubmitting = false;

  Future<void> _handlePaymobPayment(double fare) async {
    if (_isPaymobSubmitting) return;

    final tripId = tripDetails.id;
    if (tripId == null || tripId.isEmpty) return;

    setState(() {
      _isPaymobSubmitting = true;
    });

    try {
      // Step 1: Fetch Payment Intent from Backend API (same endpoint as university carpool)
      final PaymobSDKIntentModel? intent =
          await Get.find<RideController>().getPaymobIntent(
        tripRequestId: tripId,
        amount: fare > 0 ? fare : 100.0,
        selectedDuration: '1_month',
      );

      if (intent == null ||
          (intent.clientSecret == null && intent.secretKey == null)) {
        if (!mounted) return;
        showCustomSnackBar('Failed to retrieve payment intent from backend.');
        return;
      }

      // Step 2: Launch Native Paymob SDK
      if (!mounted) return;
      final result = await PaymobSdkService.startPayment(
        context: context,
        intent: intent,
      );

      // Step 3: Handle Paymob result (identical to university carpool)
      bool isSuccess = false;
      String errorMsg = 'Payment was cancelled or failed.';

      if (result != null) {
        try {
          if (result.status == PaymentStatus.successful) {
            isSuccess = true;
          }
        } catch (_) {}

        if (!isSuccess) {
          try {
            final String statusStr =
                result.status?.toString().toLowerCase() ?? '';
            if (statusStr.contains('success') ||
                statusStr == 'true' ||
                result.status == true) {
              isSuccess = true;
            }
          } catch (_) {}
        }

        if (!isSuccess && result is Map) {
          if (result['status'] == true ||
              result['success'] == true ||
              result['hmac_valid'] == true) {
            isSuccess = true;
          }
        }

        try {
          if (result.errorMessage != null &&
              result.errorMessage.toString().trim().isNotEmpty) {
            errorMsg = result.errorMessage.toString();
          } else if (result is Map && result['message'] != null) {
            errorMsg = result['message'].toString();
          }
        } catch (_) {}
      }

      if (isSuccess) {
        if (Get.isRegistered<RideController>()) {
          Get.find<RideController>().getRideDetails(tripId);
          Get.find<RideController>().getCurrentRideCarpool(type: 'carpool');
        }
        if (Get.isRegistered<TripController>()) {
          Get.find<TripController>().getTripList(1, reload: true);
        }

        final routeTitle = tripDetails.routeNameDisplay.isNotEmpty
            ? tripDetails.routeNameDisplay
            : (tripDetails.title ?? tripDetails.routeName ?? 'Carpool Trip');

        if (!mounted) return;
        CarpoolPaymentSuccessBottomSheet.show(
          context: context,
          tripId: tripId,
          routeTitle: routeTitle,
          amount: fare.round(),
          paymentMethod: 'VISA / MasterCard',
        );
      } else {
        // Fallback: Check if backend webhook confirmed it
        if (Get.isRegistered<CreateYourOwnTripController>()) {
          final pollResult = await Get.find<CreateYourOwnTripController>()
              .pollVerifyPayment(tripId, initialConfirmed: isSuccess);
          if (pollResult.isConfirmed) {
            if (Get.isRegistered<RideController>()) {
              Get.find<RideController>().getRideDetails(tripId);
              Get.find<RideController>().getCurrentRideCarpool(type: 'carpool');
            }
            if (Get.isRegistered<TripController>()) {
              Get.find<TripController>().getTripList(1, reload: true);
            }
            final routeTitle = tripDetails.routeNameDisplay.isNotEmpty
                ? tripDetails.routeNameDisplay
                : (tripDetails.title ?? tripDetails.routeName ?? 'Carpool Trip');
            if (mounted) {
              CarpoolPaymentSuccessBottomSheet.show(
                context: context,
                tripId: tripId,
                routeTitle: routeTitle,
                amount: fare.round(),
                paymentMethod: 'VISA / MasterCard',
              );
            }
            return;
          }
        }
        if (!mounted) return;
        showCustomSnackBar(errorMsg);
      }
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar('Paymob error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isPaymobSubmitting = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _resolveAddresses();
  }

  @override
  void didUpdateWidget(covariant CarpoolTripDetailsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tripDetails != widget.tripDetails) {
      _resolveAddresses();
    }
  }

  void _resolveAddresses() {
    final trip = widget.tripDetails;
    final pickupPos = _resolvePickupLatLng(trip);
    final dropoffPos = _resolveDestinationLatLng(trip);

    // 1. Pickup address resolution
    final currentStart = trip.startAddressDisplay;
    if (_isNonPlaceholder(currentStart)) {
      _resolvedPickupAddress = currentStart;
    } else if (trip.carpoolRideLocation?.address != null &&
        _isNonPlaceholder(trip.carpoolRideLocation!.address)) {
      _resolvedPickupAddress = trip.carpoolRideLocation!.address;
    } else if (pickupPos != null) {
      final match = _findMatchingStopAddress(trip.pickupLocations, pickupPos);
      if (match != null && _isNonPlaceholder(match)) {
        _resolvedPickupAddress = match;
      } else {
        _geocodeAddress(pickupPos, isPickup: true);
      }
    }

    // 2. Dropoff address resolution
    final currentEnd = trip.endAddressDisplay;
    if (_isNonPlaceholder(currentEnd)) {
      _resolvedDropoffAddress = currentEnd;
    } else if (trip.carpoolDropoffLocation?.address != null &&
        _isNonPlaceholder(trip.carpoolDropoffLocation!.address)) {
      _resolvedDropoffAddress = trip.carpoolDropoffLocation!.address;
    } else if (dropoffPos != null) {
      final match =
          _findMatchingStopAddress(trip.destinationLocations, dropoffPos);
      if (match != null && _isNonPlaceholder(match)) {
        _resolvedDropoffAddress = match;
      } else {
        _geocodeAddress(dropoffPos, isPickup: false);
      }
    }
  }

  String? _findMatchingStopAddress(List<TripLocationItem>? stops, LatLng pos) {
    if (stops == null || stops.isEmpty) return null;
    for (var stop in stops) {
      if (stop.latitude != null && stop.longitude != null) {
        final dLat = (stop.latitude! - pos.latitude).abs();
        final dLng = (stop.longitude! - pos.longitude).abs();
        if (dLat < 0.002 && dLng < 0.002 && _isNonPlaceholder(stop.address)) {
          return stop.address;
        }
      }
    }
    return null;
  }

  void _geocodeAddress(LatLng pos, {required bool isPickup}) async {
    final key =
        '${pos.latitude.toStringAsFixed(5)},${pos.longitude.toStringAsFixed(5)}';
    if (_addressCache.containsKey(key)) {
      if (mounted) {
        setState(() {
          if (isPickup) {
            _resolvedPickupAddress = _addressCache[key];
          } else {
            _resolvedDropoffAddress = _addressCache[key];
          }
        });
      }
      return;
    }

    final addr = await _reverseGeocode(pos);
    if (addr != null && mounted) {
      _addressCache[key] = addr;
      setState(() {
        if (isPickup) {
          _resolvedPickupAddress = addr;
        } else {
          _resolvedDropoffAddress = addr;
        }
      });
    }
  }

  Future<String?> _reverseGeocode(LatLng pos) async {
    final key =
        '${pos.latitude.toStringAsFixed(5)},${pos.longitude.toStringAsFixed(5)}';
    if (_addressCache.containsKey(key)) {
      return _addressCache[key];
    }

    // 1. Try backend geocode endpoint
    try {
      if (Get.isRegistered<ApiClient>()) {
        final apiClient = Get.find<ApiClient>();
        final response = await apiClient.getData(
          '${AppConstants.geoCodeURI}?lat=${pos.latitude}&lng=${pos.longitude}',
        );
        if (response.statusCode == 200 && response.body != null) {
          dynamic results;
          if (response.body is Map) {
            results =
                response.body['data']?['results'] ?? response.body['results'];
          }
          if (results is List && results.isNotEmpty) {
            final addr = results[0]['formatted_address']?.toString();
            if (addr != null && addr.trim().isNotEmpty) {
              _addressCache[key] = addr.trim();
              return addr.trim();
            }
          }
        }
      }
    } catch (_) {}

    // 2. Try Google Geocoding API with AppConstants.mapKey
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${pos.latitude},${pos.longitude}&key=${AppConstants.mapKey}',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] is List && (data['results'] as List).isNotEmpty) {
          final addr = data['results'][0]['formatted_address']?.toString();
          if (addr != null && addr.trim().isNotEmpty) {
            _addressCache[key] = addr.trim();
            return addr.trim();
          }
        }
      }
    } catch (_) {}

    return null;
  }

  static bool _isNonPlaceholder(String? s) {
    if (s == null) return false;
    final clean = s.trim().toLowerCase();
    if (clean.isEmpty) return false;
    if (clean == 'pickup' ||
        clean == 'pick up' ||
        clean == 'pickup location' ||
        clean == 'pick up location' ||
        clean == 'pickup_location' ||
        clean == 'pick_up_location' ||
        clean == 'start point' ||
        clean == 'start address' ||
        clean == 'start_point' ||
        clean == 'start_address' ||
        clean == 'destination' ||
        clean == 'dropoff' ||
        clean == 'drop off' ||
        clean == 'dropoff location' ||
        clean == 'drop off location' ||
        clean == 'drop_off' ||
        clean == 'dropoff_location' ||
        clean == 'end point' ||
        clean == 'end address' ||
        clean == 'end_point' ||
        clean == 'end_address' ||
        clean == 'موقع الركوب' ||
        clean == 'موقع الانطلاق' ||
        clean == 'الوجهة' ||
        clean == 'موقع الوصول' ||
        clean == 'نقطة الانطلاق' ||
        clean == 'نقطة الوصول' ||
        clean == 'اختر موقعا' ||
        clean == '--' ||
        clean == '-') {
      return false;
    }
    try {
      if (clean == 'pickup_location'.tr.toLowerCase() ||
          clean == 'pickup'.tr.toLowerCase() ||
          clean == 'destination'.tr.toLowerCase() ||
          clean == 'drop_off'.tr.toLowerCase() ||
          clean == 'end_address'.tr.toLowerCase() ||
          clean == 'start_address'.tr.toLowerCase()) {
        return false;
      }
    } catch (_) {}
    return true;
  }

  double _fareAmount() {
    return tripDetails.actualFare ??
        tripDetails.estimatedFare ??
        tripDetails.paidFare ??
        (double.tryParse(tripDetails.totalFare ?? '0') ?? 0);
  }

  bool get _canPayWithPaymob {
    final currentStatusLower = (tripDetails.currentStatus ?? '').toLowerCase();

    // MUST NOT appear if trip is cancelled, canceled, completed, or complete
    if (currentStatusLower == 'cancelled' ||
        currentStatusLower == 'canceled' ||
        currentStatusLower == 'completed' ||
        currentStatusLower == 'complete') {
      return false;
    }

    final isPaid = tripDetails.paymentStatus?.toLowerCase() == 'paid' ||
        (tripDetails.paidFare != null && tripDetails.paidFare! > 0);
    if (isPaid) return false;

    final bool isSpecialOrScheduled = tripDetails.isScheduledSubscription ||
        tripDetails.type == 'scheduled_subscription' ||
        tripDetails.type == 'special_request' ||
        tripDetails.type == 'special_trip' ||
        tripDetails.carpoolType == 'scheduled_subscription' ||
        tripDetails.carpoolType == 'special_request';
    if (!isSpecialOrScheduled) return false;

    // Driver MUST be assigned
    final bool hasDriverAssigned = tripDetails.driver != null;
    final bool isDriverAssignedStatus =
        currentStatusLower == 'driver_assigned' ||
            currentStatusLower == 'driver_accepted' ||
            currentStatusLower == 'accepted' ||
            currentStatusLower == 'accepted_pending_payment' ||
            currentStatusLower == 'assigned' ||
            currentStatusLower == 'waiting_for_payment' ||
            currentStatusLower == 'waiting_payment';

    final bool isDriverReady = hasDriverAssigned || isDriverAssignedStatus;
    if (!isDriverReady) return false;

    return tripDetails.id != null && tripDetails.id!.isNotEmpty;
  }

  _StatusCardConfig _getStatusConfig(String status) {
    if (tripDetails.isScheduledSubscription) {
      switch (status.toLowerCase()) {
        case 'completed':
        case 'complete':
          return _StatusCardConfig(
            title: 'subscription_completed'.tr == 'subscription_completed'
                ? 'Subscription Completed'
                : 'subscription_completed'.tr,
            subtitle: 'All scheduled subscription trips have ended.',
            badgeText: 'completed'.tr,
            icon: Icons.check_circle_outline,
            cardBg: const Color(0xFFE8F5E9),
            primaryColor: const Color(0xFF2E7D32),
          );
        case 'cancelled':
        case 'cancel':
          return _StatusCardConfig(
            title: 'subscription_cancelled'.tr == 'subscription_cancelled'
                ? 'Subscription Cancelled'
                : 'subscription_cancelled'.tr,
            subtitle: 'This subscription request was cancelled.',
            badgeText: 'cancelled'.tr,
            icon: Icons.cancel_outlined,
            cardBg: const Color(0xFFFFEBEE),
            primaryColor: const Color(0xFFD32F2F),
          );
        case 'ongoing':
        case 'on_going':
        case 'active':
          return _StatusCardConfig(
            title: 'subscription_active'.tr == 'subscription_active'
                ? 'Subscription Active'
                : 'subscription_active'.tr,
            subtitle: 'Scheduled trips are currently active.',
            badgeText: 'active'.tr == 'active' ? 'Active' : 'active'.tr,
            icon: Icons.directions_car_outlined,
            cardBg: const Color(0xFFE8F6FE),
            primaryColor: _primaryBlue,
          );
        case 'accepted':
        case 'accepted_pending_payment':
        case 'waiting_for_payment':
        case 'waiting_payment':
        case 'driver_assigned':
          return _StatusCardConfig(
            title: 'driver_accepted'.tr == 'driver_accepted'
                ? 'Driver Accepted'
                : 'driver_accepted'.tr,
            subtitle: 'driver_accepted_description'.tr ==
                    'driver_accepted_description'
                ? 'A driver has accepted your request. Please complete payment to confirm.'
                : 'driver_accepted_description'.tr,
            badgeText: 'awaiting_payment'.tr == 'awaiting_payment'
                ? 'Awaiting Payment'
                : 'awaiting_payment'.tr,
            icon: Icons.payment_rounded,
            cardBg: const Color(0xFFFFF7ED),
            primaryColor: const Color(0xFFEA580C),
          );
        case 'pending':
          return _StatusCardConfig(
            title: 'scheduled_trip_pending'.tr == 'scheduled_trip_pending'
                ? 'Scheduled Request Pending'
                : 'scheduled_trip_pending'.tr,
            subtitle: 'waiting_for_driver_acceptance'.tr ==
                    'waiting_for_driver_acceptance'
                ? 'Waiting for driver acceptance'
                : 'waiting_for_driver_acceptance'.tr,
            badgeText: 'pending'.tr == 'pending' ? 'Pending' : 'pending'.tr,
            icon: Icons.access_time_rounded,
            cardBg: const Color(0xFFFFFBEB),
            primaryColor: const Color(0xFFD97706),
          );
        case 'confirmed':
        case 'paid':
        default:
          return _StatusCardConfig(
            title: 'subscription_confirmed'.tr == 'subscription_confirmed'
                ? 'Subscription Confirmed'
                : 'subscription_confirmed'.tr,
            subtitle: 'Your scheduled subscription is active and booked.',
            badgeText:
                'confirmed'.tr == 'confirmed' ? 'Confirmed' : 'confirmed'.tr,
            icon: Icons.check_circle_rounded,
            cardBg: const Color(0xFFF0FDF4),
            primaryColor: const Color(0xFF16A34A),
          );
      }
    }

    switch (status.toLowerCase()) {
      case 'completed':
      case 'complete':
        return _StatusCardConfig(
          title: 'trip_completed'.tr == 'trip_completed'
              ? 'Trip completed'
              : 'trip_completed'.tr,
          subtitle:
              'trip_completed_description'.tr == 'trip_completed_description'
                  ? 'Your trip has been completed.'
                  : 'trip_completed_description'.tr,
          badgeText: 'completed'.tr,
          icon: Icons.check_circle_outline,
          cardBg: const Color(0xFFE8F5E9),
          primaryColor: const Color(0xFF2E7D32),
        );
      case 'cancelled':
      case 'cancel':
        return _StatusCardConfig(
          title: 'trip_cancelled'.tr == 'trip_cancelled'
              ? 'Trip cancelled'
              : 'trip_cancelled'.tr,
          subtitle:
              'trip_cancelled_description'.tr == 'trip_cancelled_description'
                  ? 'This trip was cancelled.'
                  : 'trip_cancelled_description'.tr,
          badgeText: 'cancelled'.tr,
          icon: Icons.cancel_outlined,
          cardBg: const Color(0xFFFFEBEE),
          primaryColor: const Color(0xFFD32F2F),
        );
      case 'ongoing':
      case 'on_going':
      case 'active':
        return _StatusCardConfig(
          title: 'trip_in_progress'.tr == 'trip_in_progress'
              ? 'Trip in progress'
              : 'trip_in_progress'.tr,
          subtitle: 'trip_in_progress_description'.tr ==
                  'trip_in_progress_description'
              ? 'Your trip is currently ongoing.'
              : 'trip_in_progress_description'.tr,
          badgeText: 'ongoing'.tr,
          icon: Icons.directions_car_outlined,
          cardBg: const Color(0xFFE8F6FE),
          primaryColor: _primaryBlue,
        );
      case 'pending':
        final bool hasDriver = tripDetails.driver != null;
        return _StatusCardConfig(
          title: 'trip_pending'.tr == 'trip_pending'
              ? 'Trip pending'
              : 'trip_pending'.tr,
          subtitle: hasDriver
              ? ('trip_pending_description'.tr == 'trip_pending_description'
                  ? 'Waiting for payment approval.'
                  : 'trip_pending_description'.tr)
              : ('waiting_for_driver_acceptance'.tr ==
                      'waiting_for_driver_acceptance'
                  ? 'Waiting for driver acceptance'
                  : 'waiting_for_driver_acceptance'.tr),
          badgeText: 'pending'.tr,
          icon: Icons.access_time_rounded,
          cardBg: const Color(0xFFFFF3E0),
          primaryColor: const Color(0xFFEF6C00),
        );
      case 'accepted_pending_payment':
      case 'waiting_for_payment':
      case 'waiting_payment':
        return _StatusCardConfig(
          title: 'driver_accepted'.tr == 'driver_accepted'
              ? 'Driver Accepted'
              : 'driver_accepted'.tr,
          subtitle: 'driver_accepted_description'.tr ==
                  'driver_accepted_description'
              ? 'A driver has accepted your request. Please complete payment to confirm.'
              : 'driver_accepted_description'.tr,
          badgeText: 'awaiting_payment'.tr == 'awaiting_payment'
              ? 'Awaiting Payment'
              : 'awaiting_payment'.tr,
          icon: Icons.payment_rounded,
          cardBg: const Color(0xFFFFF7ED),
          primaryColor: const Color(0xFFEA580C),
        );
      case 'accepted':
      case 'confirmed':
      default:
        return _StatusCardConfig(
          title: 'trip_confirmed'.tr == 'trip_confirmed'
              ? 'Trip confirmed'
              : 'trip_confirmed'.tr,
          subtitle:
              'trip_confirmed_description'.tr == 'trip_confirmed_description'
                  ? "Your seat is booked for today's trip."
                  : 'trip_confirmed_description'.tr,
          badgeText: status.tr != status
              ? status.tr
              : (status.capitalizeFirst ?? 'Confirmed'),
          icon: Icons.check,
          cardBg: const Color(0xFFE8F6FE),
          primaryColor: _primaryBlue,
        );
    }
  }

  Widget _buildRouteSection({
    required String title,
    required IconData titleIcon,
    required Color titleColor,
    required Color titleBgColor,
    required String timeStr,
    required String fromLabel,
    required String fromAddress,
    required String toLabel,
    required String toAddress,
    String? fromEta,
    String? toEta,
    String? extraFee,
    VoidCallback? onFromMapTap,
    VoidCallback? onToMapTap,
    List<TripLocationItem>? fromStops,
    List<TripLocationItem>? toStops,
    LatLng? fallbackPickupPos,
    LatLng? fallbackDropoffPos,
  }) {
    final pickups = (fromStops != null && fromStops.isNotEmpty)
        ? fromStops
        : [
            TripLocationItem(
              address: fromAddress,
              latitude: fallbackPickupPos?.latitude,
              longitude: fallbackPickupPos?.longitude,
            )
          ];
    final dropoffs = (toStops != null && toStops.isNotEmpty)
        ? toStops
        : [
            TripLocationItem(
              address: toAddress,
              latitude: fallbackDropoffPos?.latitude,
              longitude: fallbackDropoffPos?.longitude,
            )
          ];
    final allStops = [...pickups, ...dropoffs];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: titleBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(titleIcon, size: 14, color: titleColor),
                  const SizedBox(width: 5),
                  Text(
                    title,
                    style: textSemiBold.copyWith(
                      color: titleColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (extraFee != null && extraFee.isNotEmpty) ...[
              // Container(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFFF3E8FF),
              //     borderRadius: BorderRadius.circular(12),
              //     border: Border.all(color: const Color(0xFFE9D5FF)),
              //   ),
              //   child: Text(
              //     extraFee,
              //     style: textSemiBold.copyWith(
              //       color: const Color(0xFF7C3AED),
              //       fontSize: 11,
              //     ),
              //   ),
              // ),
              const SizedBox(width: 6),
            ],
            if (timeStr.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 13, color: _textSubtle),
                    const SizedBox(width: 4),
                    Text(
                      timeStr,
                      style: textBold.copyWith(
                        color: _textDark,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: List.generate(allStops.length, (i) {
            final isPickup = i < pickups.length;
            final isLast = i == allStops.length - 1;
            final stop = allStops[i];
            final stopNumber = isPickup ? (i + 1) : (i - pickups.length + 1);
            final stopLabel = isPickup
                ? (pickups.length > 1 ? '$fromLabel #$stopNumber' : fromLabel)
                : (dropoffs.length > 1 ? '$toLabel #$stopNumber' : toLabel);
            final stopColor = isPickup ? _pickupBlue : _dropoffRed;
            final String rawStopAddr = (stop.address ?? '').trim();
            final String defaultAddr = isPickup ? fromAddress : toAddress;
            final String displayAddr = _isNonPlaceholder(rawStopAddr)
                ? rawStopAddr
                : (defaultAddr.isNotEmpty ? defaultAddr : '--');

            final LatLng? stopPos;
            if (isPickup) {
              if (pickups.length <= 1 && fallbackPickupPos != null) {
                stopPos = fallbackPickupPos;
              } else if (stop.latitude != null &&
                  stop.longitude != null &&
                  (stop.latitude != 0.0 || stop.longitude != 0.0)) {
                stopPos = MapBoundHelper.toCorrectLatLng(
                    stop.latitude!, stop.longitude!);
              } else {
                stopPos = fallbackPickupPos;
              }
            } else {
              if (dropoffs.length <= 1 && fallbackDropoffPos != null) {
                stopPos = fallbackDropoffPos;
              } else if (stop.latitude != null &&
                  stop.longitude != null &&
                  (stop.latitude != 0.0 || stop.longitude != 0.0)) {
                stopPos = MapBoundHelper.toCorrectLatLng(
                    stop.latitude!, stop.longitude!);
              } else {
                stopPos = fallbackDropoffPos;
              }
            }

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: stopColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: Colors.grey.shade300,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stopLabel,
                                  style: textSemiBold.copyWith(
                                    color: _textSubtle,
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  displayAddr.isNotEmpty ? displayAddr : '--',
                                  style: textBold.copyWith(
                                    color: _textDark,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (stopPos != null ||
                              (displayAddr.isNotEmpty &&
                                  displayAddr != '--')) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                if (isPickup &&
                                    onFromMapTap != null &&
                                    pickups.length <= 1) {
                                  onFromMapTap();
                                } else if (!isPickup &&
                                    onToMapTap != null &&
                                    dropoffs.length <= 1) {
                                  onToMapTap();
                                } else {
                                  _openGoogleMapsDirections(
                                    targetPos: stopPos,
                                    targetAddress: displayAddr,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: isPickup
                                      ? const Color(0xFFF0F6FA)
                                      : const Color(0xFFFDF2F2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isPickup
                                        ? const Color(0xFFD6E4EE)
                                        : const Color(0xFFFBD5D5),
                                  ),
                                ),
                                child: Icon(
                                  Icons.map_outlined,
                                  size: 16,
                                  color: stopColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final driver = tripDetails.driver;
    final vehicle = tripDetails.vehicle;
    final status = tripDetails.currentStatus ?? 'confirmed';
    final statusConfig = _getStatusConfig(status);
    final fare = _fareAmount();

    final rideController =
        Get.isRegistered<RideController>() ? Get.find<RideController>() : null;

    final String? otpCode = (tripDetails.otp != null &&
            tripDetails.otp!.trim().isNotEmpty)
        ? tripDetails.otp!.trim()
        : (rideController?.tripDetails?.otp != null &&
                rideController!.tripDetails!.otp!.trim().isNotEmpty)
            ? rideController.tripDetails!.otp!.trim()
            : (rideController?.carpoolTripDetails?.otp != null &&
                    rideController!.carpoolTripDetails!.otp!.trim().isNotEmpty)
                ? rideController.carpoolTripDetails!.otp!.trim()
                : null;

    final currentStatusLower = status.toLowerCase();

    final bool isCompletedOrCancelled = currentStatusLower == 'completed' ||
        currentStatusLower == 'complete' ||
        currentStatusLower == 'cancelled' ||
        currentStatusLower == 'canceled' ||
        currentStatusLower == 'rejected';

    final bool isOngoing =
        currentStatusLower == 'ongoing' || currentStatusLower == 'on_going';

    final bool isUpcomingStatus = currentStatusLower == 'accepted' ||
        currentStatusLower == 'confirmed' ||
        currentStatusLower == 'paid' ||
        currentStatusLower == 'upcoming' ||
        currentStatusLower == 'driver_assigned' ||
        currentStatusLower == 'driver_accepted' ||
        currentStatusLower == 'scheduled';

    final bool showOtpCard = (otpCode != null && otpCode.isNotEmpty) ||
        (!isCompletedOrCancelled && (isUpcomingStatus || isOngoing));

    final pickupPos = _resolvePickupLatLng(tripDetails);
    final dropoffPos = _resolveDestinationLatLng(tripDetails);

    final String startAddr;
    if (_resolvedPickupAddress != null &&
        _isNonPlaceholder(_resolvedPickupAddress)) {
      startAddr = _resolvedPickupAddress!;
    } else if (tripDetails.startAddressDisplay.isNotEmpty &&
        _isNonPlaceholder(tripDetails.startAddressDisplay)) {
      startAddr = tripDetails.startAddressDisplay;
    } else if (tripDetails.carpoolRideLocation?.address != null &&
        _isNonPlaceholder(tripDetails.carpoolRideLocation!.address)) {
      startAddr = tripDetails.carpoolRideLocation!.address!;
    } else if (tripDetails.pickupAddress != null &&
        _isNonPlaceholder(tripDetails.pickupAddress)) {
      startAddr = tripDetails.pickupAddress!;
    } else if (pickupPos != null) {
      startAddr =
          '${pickupPos.latitude.toStringAsFixed(4)}, ${pickupPos.longitude.toStringAsFixed(4)}';
    } else {
      startAddr = '--';
    }

    final String endAddr;
    if (_resolvedDropoffAddress != null &&
        _isNonPlaceholder(_resolvedDropoffAddress)) {
      endAddr = _resolvedDropoffAddress!;
    } else if (tripDetails.endAddressDisplay.isNotEmpty &&
        _isNonPlaceholder(tripDetails.endAddressDisplay)) {
      endAddr = tripDetails.endAddressDisplay;
    } else if (tripDetails.carpoolDropoffLocation?.address != null &&
        _isNonPlaceholder(tripDetails.carpoolDropoffLocation!.address)) {
      endAddr = tripDetails.carpoolDropoffLocation!.address!;
    } else if (tripDetails.destinationAddress != null &&
        _isNonPlaceholder(tripDetails.destinationAddress)) {
      endAddr = tripDetails.destinationAddress!;
    } else if (dropoffPos != null) {
      endAddr =
          '${dropoffPos.latitude.toStringAsFixed(4)}, ${dropoffPos.longitude.toStringAsFixed(4)}';
    } else {
      endAddr = '--';
    }

    final bool isCarpoolRide = tripDetails.carpoolRideLocation != null ||
        tripDetails.isCarpool == true ||
        (tripDetails.type != null &&
            tripDetails.type!.toLowerCase() == 'carpool');

    final List<TripLocationItem>? carpoolPickups = isCarpoolRide
        ? [
            TripLocationItem(
              address: startAddr,
              latitude: pickupPos?.latitude,
              longitude: pickupPos?.longitude,
            )
          ]
        : tripDetails.pickupLocations;

    final List<TripLocationItem>? carpoolDropoffs = isCarpoolRide
        ? [
            TripLocationItem(
              address: endAddr,
              latitude: dropoffPos?.latitude,
              longitude: dropoffPos?.longitude,
            )
          ]
        : tripDetails.destinationLocations;

    final showEta = !tripDetails.isTravelOrNorthCoast &&
        !tripDetails.isScheduledSubscription;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 0. TRIP TYPE BADGE (FOR SCHEDULED SUBSCRIPTION)
        if (tripDetails.isScheduledSubscription) ...[
          _buildScheduledSubscriptionHeader(),
          const SizedBox(height: 12),
        ],

        /// 1. DYNAMIC TRIP STATUS CARD
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusConfig.cardBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusConfig.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusConfig.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusConfig.title,
                      style: textBold.copyWith(
                        color: _textDark,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusConfig.subtitle,
                      style: textRegular.copyWith(
                        color: _textSubtle,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  statusConfig.badgeText,
                  style: textSemiBold.copyWith(
                    color: statusConfig.primaryColor,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        /// 1.5. SUBSCRIPTION SCHEDULE CARD (DATES & STATS)
        if (tripDetails.isScheduledSubscription) ...[
          _buildScheduledSubscriptionScheduleCard(context),
          const SizedBox(height: 14),
        ],

        /// 1.8. START TRIP CODE (OTP) CARD (FOR UPCOMING TRIPS)
        if (showOtpCard) ...[
          _buildOtpCard(context, otpCode),
          const SizedBox(height: 14),
        ],

        /// 2. ROUTE & BOOKING CARD
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEBEFF5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tripDetails.hasReturnTrip) ...[
                /// OUTBOUND TRIP (GOING)
                _buildRouteSection(
                  title: tripDetails.isScheduledSubscription
                      ? ('outbound_ride'.tr == 'outbound_ride'
                          ? 'Outbound Ride'
                          : 'outbound_ride'.tr)
                      : 'morning_trip'.tr,
                  titleIcon: Icons.wb_sunny_rounded,
                  titleColor: const Color(0xFFEA580C),
                  titleBgColor: const Color(0xFFFFF7ED),
                  timeStr: tripDetails.formattedTime,
                  fromLabel: 'START ADDRESS'.tr,
                  fromAddress: startAddr,
                  fromStops: carpoolPickups,
                  fromEta: showEta
                      ? '${'est_pickup'.tr == 'est_pickup' ? 'Est. Pickup' : 'est_pickup'.tr}: ${tripDetails.estimatedPickupTime} (+${tripDetails.estimatedMinutesFromStartToPickup} min)'
                      : null,
                  onFromMapTap: () => _openGoogleMapsDirections(
                    targetPos: pickupPos,
                    targetAddress: startAddr,
                  ),
                  toLabel: 'END ADDRESS'.tr,
                  toAddress: endAddr,
                  toStops: carpoolDropoffs,
                  toEta: showEta
                      ? '${'est_dropoff'.tr == 'est_dropoff' ? 'Est. Drop-off' : 'est_dropoff'.tr}: ${tripDetails.estimatedDropoffTime} (+${tripDetails.estimatedMinutesFromStartToDropoff} min)'
                      : null,
                  onToMapTap: () => _openGoogleMapsDirections(
                    targetPos: dropoffPos,
                    targetAddress: endAddr,
                  ),
                  fallbackPickupPos: pickupPos,
                  fallbackDropoffPos: dropoffPos,
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF0F3F7)),
                const SizedBox(height: 16),

                /// RETURN TRIP
                _buildRouteSection(
                  title: tripDetails.isScheduledSubscription
                      ? ('return_ride'.tr == 'return_ride'
                          ? 'Return Ride'
                          : 'return_ride'.tr)
                      : 'night_trip'.tr,
                  titleIcon: Icons.nights_stay_rounded,
                  titleColor: const Color(0xFF7C3AED),
                  titleBgColor: const Color(0xFFF3E8FF),
                  timeStr: tripDetails.formattedReturnTime,
                  extraFee: (tripDetails.returnFee != null &&
                          tripDetails.returnFee! > 0)
                      ? 'Return Fee: ${PriceConverter.convertPrice(tripDetails.returnFee!)}'
                      : null,
                  fromLabel: 'START ADDRESS'.tr,
                  fromAddress: endAddr,
                  fromStops:
                      (carpoolDropoffs != null && carpoolDropoffs.isNotEmpty)
                          ? carpoolDropoffs.reversed.toList()
                          : null,
                  fromEta: showEta
                      ? '${'est_pickup'.tr == 'est_pickup' ? 'Est. Pickup' : 'est_pickup'.tr}: ${tripDetails.estimatedReturnPickupTime} (+${tripDetails.estimatedMinutesFromStartToPickup} min)'
                      : null,
                  onFromMapTap: () => _openGoogleMapsDirections(
                    targetPos: dropoffPos,
                    targetAddress: endAddr,
                  ),
                  toLabel: 'END ADDRESS'.tr,
                  toAddress: startAddr,
                  toStops: (carpoolPickups != null && carpoolPickups.isNotEmpty)
                      ? carpoolPickups.reversed.toList()
                      : null,
                  toEta: showEta
                      ? '${'est_dropoff'.tr == 'est_dropoff' ? 'Est. Drop-off' : 'est_dropoff'.tr}: ${tripDetails.estimatedReturnDropoffTime} (+${tripDetails.estimatedMinutesFromStartToDropoff} min)'
                      : null,
                  onToMapTap: () => _openGoogleMapsDirections(
                    targetPos: pickupPos,
                    targetAddress: startAddr,
                  ),
                  fallbackPickupPos: dropoffPos,
                  fallbackDropoffPos: pickupPos,
                ),
              ] else ...[
                /// ONE-WAY ROUTE
                _buildRouteSection(
                  title: tripDetails.isScheduledSubscription
                      ? ('scheduled_route'.tr == 'scheduled_route'
                          ? 'Scheduled Route'
                          : 'scheduled_route'.tr)
                      : tripDetails.type == 'parcel'
                          ? 'parcel_delivery'.tr
                          : 'trip_route'.tr,
                  titleIcon: tripDetails.type == 'parcel'
                      ? Icons.inventory_2_outlined
                      : Icons.directions_car_outlined,
                  titleColor: _primaryBlue,
                  titleBgColor: const Color(0xFFE8F6FE),
                  timeStr: tripDetails.formattedTime,
                  fromLabel: 'START ADDRESS'.tr,
                  fromAddress: startAddr,
                  fromStops: carpoolPickups,
                  fromEta: showEta
                      ? '${'est_pickup'.tr == 'est_pickup' ? 'Est. Pickup' : 'est_pickup'.tr}: ${tripDetails.estimatedPickupTime} (+${tripDetails.estimatedMinutesFromStartToPickup} min)'
                      : null,
                  onFromMapTap: () => _openGoogleMapsDirections(
                    targetPos: pickupPos,
                    targetAddress: startAddr,
                  ),
                  toLabel: 'END ADDRESS'.tr,
                  toAddress: endAddr,
                  toStops: carpoolDropoffs,
                  toEta: showEta
                      ? '${'est_dropoff'.tr == 'est_dropoff' ? 'Est. Drop-off' : 'est_dropoff'.tr}: ${tripDetails.estimatedDropoffTime} (+${tripDetails.estimatedMinutesFromStartToDropoff} min)'
                      : null,
                  onToMapTap: () => _openGoogleMapsDirections(
                    targetPos: dropoffPos,
                    targetAddress: endAddr,
                  ),
                  fallbackPickupPos: pickupPos,
                  fallbackDropoffPos: dropoffPos,
                ),
              ],
              if (!tripDetails.isScheduledSubscription &&
                  tripDetails.formattedDate.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF0F3F7)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tripDetails.formattedDate,
                      style: textRegular.copyWith(
                        color: _textSubtle,
                        fontSize: 12,
                      ),
                    ),
                    if (tripDetails.refId != null &&
                        tripDetails.refId!.isNotEmpty)
                      Text(
                        'Booking #${tripDetails.refId!}',
                        style: textRegular.copyWith(
                          color: _textSubtle,
                          fontSize: 12,
                        ),
                      )
                    else if (tripDetails.id != null &&
                        tripDetails.id!.isNotEmpty)
                      Text(
                        'Booking #${tripDetails.id!.length >= 7 ? tripDetails.id!.substring(0, 7) : tripDetails.id!}',
                        style: textRegular.copyWith(
                          color: _textSubtle,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 14),

        /// 3. DRIVER CARD OR SEARCHING DRIVERS BANNER
        if (driver != null)
          Container(
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
                        ? Image.network(
                            driver.profileImage!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                              child: Text(
                                (((driver.firstName?.isNotEmpty ?? false) ||
                                            driver.displayName.isNotEmpty)
                                        ? (driver.firstName ??
                                            driver.displayName)
                                        : 'A')[0]
                                    .toUpperCase(),
                                style: textBold.copyWith(
                                  color: _primaryBlue,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              (((driver.firstName?.isNotEmpty ?? false) ||
                                          driver.displayName.isNotEmpty)
                                      ? (driver.firstName ?? driver.displayName)
                                      : 'A')[0]
                                  .toUpperCase(),
                              style: textBold.copyWith(
                                color: _primaryBlue,
                                fontSize: 18,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (driver.firstName != null || driver.lastName != null) &&
                                '${driver.firstName ?? ''} ${driver.lastName ?? ''}'
                                    .trim()
                                    .isNotEmpty
                            ? '${driver.firstName ?? ''} ${driver.lastName ?? ''}'
                                .trim()
                            : (driver.displayName.isNotEmpty
                                ? driver.displayName
                                : 'Driver'),
                        style: textBold.copyWith(
                          color: _textDark,
                          fontSize: 15,
                        ),
                      ),
                      if (vehicle != null &&
                          ((vehicle.model?.name != null &&
                                  vehicle.model!.name!.isNotEmpty) ||
                              (vehicle.licencePlateNumber != null &&
                                  vehicle.licencePlateNumber!.isNotEmpty))) ...[
                        const SizedBox(height: 3),
                        Text(
                          [
                            vehicle.model?.name,
                            vehicle.licencePlateNumber,
                          ]
                              .where((s) => s != null && s.trim().isNotEmpty)
                              .join(' · '),
                          style: textRegular.copyWith(
                            color: _textSubtle,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            '${tripDetails.driverRatingText.isNotEmpty ? tripDetails.driverRatingText : '5.0'} · Verified driver',
                            style: textRegular.copyWith(
                              color: _textSubtle,
                              fontSize: 11,
                            ),
                          ),
                          if (otpCode != null && otpCode.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'OTP: $otpCode',
                                style: textBold.copyWith(
                                  color: const Color(0xFF2E7D32),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (driver.phone != null && driver.phone!.isNotEmpty) ...[
                      IconButton(
                        onPressed: () => _callPhone(driver.phone!),
                        icon: const Icon(Icons.call_rounded,
                            color: _primaryBlue, size: 20),
                        tooltip: 'call'.tr,
                      ),
                    ],
                    IconButton(
                      onPressed: () {
                        final driverId = driver.id;
                        if (driverId != null &&
                            driverId.isNotEmpty &&
                            driverId != '0') {
                          if (Get.isRegistered<MessageController>()) {
                            Get.find<MessageController>().createChannel(
                              driverId,
                              tripDetails.id ?? '',
                            );
                          } else {
                            Get.put(MessageController(
                                    messageServiceInterface: Get.find()))
                                .createChannel(driverId, tripDetails.id ?? '');
                          }
                        } else {
                          showCustomSnackBar(
                              'driver_not_assigned_yet'.tr.isNotEmpty
                                  ? 'driver_not_assigned_yet'.tr
                                  : 'Driver not assigned yet');
                        }
                      },
                      icon: const Icon(Icons.chat_bubble_outline_rounded,
                          color: _primaryBlue, size: 20),
                      tooltip: 'message'.tr,
                    ),
                  ],
                ),
              ],
            ),
          )
        else if (tripDetails.isScheduledSubscription &&
            (status.toLowerCase() == 'pending' ||
                status.toLowerCase() == 'searching')) ...[
          _buildSearchingDriverBanner(),
        ],

        if (driver != null ||
            (tripDetails.isScheduledSubscription &&
                (status.toLowerCase() == 'pending' ||
                    status.toLowerCase() == 'searching')))
          const SizedBox(height: 14),

        /// 3.0. DRIVER ASSIGNED & UNPAID BANNER (PAYMOB)
        if (_canPayWithPaymob) ...[
          _buildDriverAssignedPayBanner(),
          const SizedBox(height: 14),
        ],

        /// 3.1. CO-PASSENGERS / ADDITIONAL PASSENGERS
        if (tripDetails.coPassengers != null &&
            tripDetails.coPassengers!.isNotEmpty) ...[
          _buildPassengersCard(tripDetails.coPassengers!),
          const SizedBox(height: 14),
        ],

        /// 3.2. EMERGENCY CONTACT CARD
        if (tripDetails.emergencyContact != null &&
            ((tripDetails.emergencyContact!.name?.isNotEmpty ?? false) ||
                (tripDetails.emergencyContact!.phone?.isNotEmpty ??
                    false))) ...[
          _buildEmergencyContactCard(tripDetails.emergencyContact!),
          const SizedBox(height: 14),
        ],

        /// 4. PAYMENT CARD
        _buildPaymentCard(context, fare),

        const SizedBox(height: 20),

        /// 5. ACTION BUTTON (VIEW TRIP / CANCEL REQUEST / CANCEL PARCEL)
        if (_canPayWithPaymob) ...[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isPaymobSubmitting
                  ? null
                  : () => _handlePaymobPayment(fare),
              icon: _isPaymobSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.payment_rounded,
                      size: 20, color: Colors.white),
              label: Text(
                _isPaymobSubmitting
                    ? 'Processing...'
                    : 'pay_now_via_paymob'.tr == 'pay_now_via_paymob'
                        ? 'Pay Now (Paymob)'
                        : 'pay_now_via_paymob'.tr,
                style: textBold.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A3EC),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (tripDetails.currentStatus == 'accepted' ||
              tripDetails.currentStatus == 'ongoing' ||
              tripDetails.driver != null) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  if (tripDetails.id != null) {
                    Get.to(
                        () => CarpoolActiveRideScreen(tripId: tripDetails.id!));
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _primaryBlue, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'View trip',
                  style: textBold.copyWith(
                    color: _primaryBlue,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ] else if (tripDetails.currentStatus == 'accepted' ||
            tripDetails.currentStatus == 'ongoing') ...[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (tripDetails.id != null) {
                  Get.to(
                      () => CarpoolActiveRideScreen(tripId: tripDetails.id!));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'View trip',
                style: textBold.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ] else if (tripDetails.isScheduledSubscription &&
            tripDetails.currentStatus?.toLowerCase() == 'pending') ...[
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () =>
                  _confirmCancelScheduledTrip(context, tripDetails),
              icon: const Icon(Icons.close_rounded,
                  size: 20, color: Color(0xFFD32F2F)),
              label: Text(
                'cancel_request'.tr == 'cancel_request'
                    ? 'Cancel Request'
                    : 'cancel_request'.tr,
                style: textBold.copyWith(
                  fontSize: 15,
                  color: const Color(0xFFD32F2F),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD32F2F),
                side: const BorderSide(color: Color(0xFFE57373), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ] else if ((tripDetails.type == 'parcel' ||
                tripDetails.parcelInformation != null) &&
            tripDetails.currentStatus?.toLowerCase() == 'pending') ...[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _confirmCancelParcel(context, tripDetails),
              icon: const Icon(Icons.close_rounded,
                  size: 20, color: Color(0xFFD32F2F)),
              label: Text(
                'cancel_parcel'.tr == 'cancel_parcel'
                    ? 'Cancel Parcel'
                    : 'cancel_parcel'.tr,
                style: textBold.copyWith(
                  fontSize: 15,
                  color: const Color(0xFFD32F2F),
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD32F2F),
                side: const BorderSide(color: Color(0xFFE57373), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        /// 6. READY TO GO NOTICE BANNER
        if (tripDetails.currentStatus?.toLowerCase() != 'cancelled')
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5F9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to go',
                  style: textBold.copyWith(
                    color: _textDark,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tripDetails.isScheduledSubscription
                      ? 'This scheduled subscription is saved in your Activity trips.'
                      : 'This trip is now saved in your Activity trips.',
                  style: textRegular.copyWith(
                    color: _textSubtle,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildScheduledSubscriptionHeader() {
    final ref = tripDetails.refId != null && tripDetails.refId!.isNotEmpty
        ? tripDetails.refId!
        : (tripDetails.id != null && tripDetails.id!.length >= 6
            ? tripDetails.id!.substring(0, 6)
            : '');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFDBEAFE),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stars_rounded,
                size: 18, color: Color(0xFF1D4ED8)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'scheduled_subscription'.tr == 'scheduled_subscription'
                      ? 'Scheduled Subscription'
                      : 'scheduled_subscription'.tr,
                  style: textBold.copyWith(
                    color: const Color(0xFF1E3A8A),
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Create Your Own Trip',
                  style: textRegular.copyWith(
                    color: const Color(0xFF3B82F6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (ref.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: Text(
                '#$ref',
                style: textBold.copyWith(
                  color: const Color(0xFF1D4ED8),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScheduledSubscriptionScheduleCard(BuildContext context) {
    final List<String> activeDates = tripDetails.selectedDates ?? [];
    final hasActiveDates = activeDates.isNotEmpty;
    final startDateStr =
        tripDetails.startDate != null && tripDetails.startDate!.isNotEmpty
            ? tripDetails.startDate!
            : (hasActiveDates ? activeDates.first : tripDetails.formattedDate);
    final endDateStr =
        tripDetails.endDate != null && tripDetails.endDate!.isNotEmpty
            ? tripDetails.endDate!
            : (hasActiveDates ? activeDates.last : '');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBEFF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F6FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calendar_month_rounded,
                    size: 18, color: _primaryBlue),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SUBSCRIPTION SCHEDULE',
                      style: textBold.copyWith(
                        color: _primaryBlue,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    // Text(
                    //   '${tripDetails.totalSubscriptionDays} Operating Days Scheduled',
                    //   style: textBold.copyWith(
                    //     color: _textDark,
                    //     fontSize: 14,
                    //   ),
                    // ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Text(
                  '${tripDetails.totalSubscriptionDays} Days',
                  style: textSemiBold.copyWith(
                    color: const Color(0xFF1D4ED8),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0F3F7)),
          const SizedBox(height: 14),

          /// Dates Row
          Row(
            children: [
              Expanded(
                child: _buildScheduleInfoItem(
                  icon: Icons.date_range_rounded,
                  label: 'START DATE',
                  value: _formatFriendlyDate(startDateStr),
                ),
              ),
              Container(width: 1, height: 36, color: const Color(0xFFF0F3F7)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: _buildScheduleInfoItem(
                    icon: Icons.event_available_rounded,
                    label: 'END DATE',
                    value: endDateStr.isNotEmpty
                        ? _formatFriendlyDate(endDateStr)
                        : 'Flexible',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Times Row (Outbound & Return)
          Row(
            children: [
              Expanded(
                child: _buildScheduleInfoItem(
                  icon: Icons.wb_sunny_rounded,
                  label: 'OUTBOUND TIME',
                  value: tripDetails.formattedTime.isNotEmpty
                      ? tripDetails.formattedTime
                      : '--',
                ),
              ),
              if (tripDetails.hasReturnTrip ||
                  tripDetails.formattedReturnTime.isNotEmpty) ...[
                Container(width: 1, height: 36, color: const Color(0xFFF0F3F7)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: _buildScheduleInfoItem(
                      icon: Icons.nights_stay_rounded,
                      label: 'RETURN TIME',
                      value: tripDetails.formattedReturnTime.isNotEmpty
                          ? tripDetails.formattedReturnTime
                          : '--',
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          /// Seats & Payment Responsibility Row
          Row(
            children: [
              Expanded(
                child: _buildScheduleInfoItem(
                  icon: Icons.event_seat_rounded,
                  label: 'SEATS BOOKED',
                  value:
                      '${tripDetails.seatsCount ?? ((tripDetails.coPassengers?.length ?? 0) + 1)} Seat${(tripDetails.seatsCount ?? 1) > 1 ? 's' : ''}',
                ),
              ),
              Container(width: 1, height: 36, color: const Color(0xFFF0F3F7)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: _buildScheduleInfoItem(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'PAYMENT POLICY',
                    value: tripDetails.paymentResponsibility == 'creator_only'
                        ? 'Creator Pays All'
                        : (tripDetails.paymentResponsibility == 'split_equally'
                            ? 'Split with Passengers'
                            : (tripDetails
                                    .paymentResponsibility?.capitalizeFirst ??
                                'Standard')),
                  ),
                ),
              ),
            ],
          ),

          if (tripDetails.estimatedDistance != null &&
              tripDetails.estimatedDistance! > 0) ...[
            const SizedBox(height: 12),
            _buildScheduleInfoItem(
              icon: Icons.route_rounded,
              label: 'EST. DISTANCE',
              value: '${tripDetails.estimatedDistance!.toStringAsFixed(1)} km',
            ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0F3F7)),
          const SizedBox(height: 12),

          /// Selected Recurring Days Section
          _buildOperatingWeekdaysSection(),
        ],
      ),
    );
  }

  Widget _buildOperatingWeekdaysSection() {
    final activeDayIds = tripDetails.selectedOperatingWeekdays.toSet();
    const days = [
      {'id': 7, 'label': 'Sun'},
      {'id': 1, 'label': 'Mon'},
      {'id': 2, 'label': 'Tue'},
      {'id': 3, 'label': 'Wed'},
      {'id': 4, 'label': 'Thu'},
      {'id': 5, 'label': 'Fri'},
      {'id': 6, 'label': 'Sat'},
    ];

    final activeLabels = days
        .where((d) => activeDayIds.contains(d['id']))
        .map((d) => (d['label'] as String).tr)
        .toList();

    final String summaryText = activeLabels.isEmpty
        ? 'No operating days selected'
        : activeLabels.length == 7
            ? 'Operates every day of the week'
            : 'Operates on: ${activeLabels.join(', ')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'OPERATING DAYS'.tr == 'OPERATING DAYS'
                  ? 'OPERATING DAYS'
                  : 'OPERATING DAYS'.tr,
              style: textSemiBold.copyWith(
                color: _textSubtle,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${activeDayIds.length} Days / Week',
                style: textSemiBold.copyWith(
                  color: const Color(0xFF1D4ED8),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((day) {
            final isActive = activeDayIds.contains(day['id']);
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF00A3EC)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF00A3EC)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFF00A3EC).withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (day['label'] as String).tr,
                      style: textBold.copyWith(
                        color:
                            isActive ? Colors.white : const Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Icon(
                      isActive
                          ? Icons.check_circle_rounded
                          : Icons.remove_circle_outline_rounded,
                      size: 11,
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.9)
                          : const Color(0xFFCBD5E1),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                size: 13, color: _primaryBlue),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                summaryText,
                style: textRegular.copyWith(
                  color: _textDark,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScheduleInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _textSubtle),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textSemiBold.copyWith(
                  color: _textSubtle,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textBold.copyWith(
                  color: _textDark,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatFriendlyDate(String dateStr) {
    try {
      final parsed = DateTime.tryParse(dateStr.trim());
      if (parsed != null) {
        return DateFormat('EEE, dd MMM yyyy').format(parsed);
      }
    } catch (_) {}
    return dateStr;
  }

  /// START TRIP CODE (OTP) CARD FOR UPCOMING TRIPS
  Widget _buildOtpCard(BuildContext context, String? otp) {
    final String cleanOtp = (otp != null && otp.trim().isNotEmpty)
        ? otp.trim().replaceAll(' ', '')
        : '';
    final bool hasValidCode = cleanOtp.isNotEmpty;
    final List<String> digits =
        hasValidCode ? cleanOtp.split('') : ['-', '-', '-', '-'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'start_trip_code'.tr == 'start_trip_code'
                          ? 'Start Trip Code'
                          : 'start_trip_code'.tr,
                      style: textBold.copyWith(
                        color: _textDark,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'give_otp_to_driver'.tr == 'give_otp_to_driver'
                          ? 'Share this code with your driver when they arrive.'
                          : 'give_otp_to_driver'.tr,
                      style: textRegular.copyWith(
                        color: _textSubtle,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'otp'.tr == 'otp' ? 'OTP' : 'otp'.tr,
                      style: textSemiBold.copyWith(
                        color: const Color(0xFF16A34A),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (digits.length <= 6)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: digits.map((char) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 42,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          char,
                          style: textBold.copyWith(
                            fontSize: 22,
                            color: hasValidCode ? _textDark : _textSubtle,
                          ),
                        ),
                      );
                    }).toList(),
                  )
                else
                  Text(
                    cleanOtp,
                    style: textBold.copyWith(
                      fontSize: 22,
                      color: _textDark,
                      letterSpacing: 4,
                    ),
                  ),
                if (hasValidCode)
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: cleanOtp));
                      showCustomSnackBar(
                        'code_copied'.tr == 'code_copied'
                            ? 'Code copied to clipboard'
                            : 'code_copied'.tr,
                        isError: false,
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F6FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.copy_rounded,
                              color: _primaryBlue, size: 15),
                          const SizedBox(width: 5),
                          Text(
                            'copy'.tr == 'copy' ? 'Copy' : 'copy'.tr,
                            style: textSemiBold.copyWith(
                              color: _primaryBlue,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                size: 14,
                color: _textSubtle,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hasValidCode
                      ? "Only share this code when you meet your driver to start the ride."
                      : "Your start trip code will be ready before pickup.",
                  style: textRegular.copyWith(
                    color: _textSubtle,
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

  Widget _buildSearchingDriverBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Color(0xFFD97706),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'searching_for_drivers'.tr == 'searching_for_drivers'
                      ? 'Searching for Drivers'
                      : 'searching_for_drivers'.tr,
                  style: textBold.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'request_distributed_to_drivers'.tr ==
                          'request_distributed_to_drivers'
                      ? 'Your subscription request has been distributed to available drivers.'
                      : 'request_distributed_to_drivers'.tr,
                  style: textRegular.copyWith(
                    fontSize: 11,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverAssignedPayBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFEDD5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEA580C).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFEA580C),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'driver_accepted_title'.tr.isNotEmpty &&
                              'driver_accepted_title'.tr !=
                                  'driver_accepted_title'
                          ? 'driver_accepted_title'.tr
                          : 'Driver Assigned! Please Pay',
                      style: textBold.copyWith(
                        fontSize: 14,
                        color: const Color(0xFF9A3412),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'complete_payment_within_30_min'.tr.isNotEmpty &&
                              'complete_payment_within_30_min'.tr !=
                                  'complete_payment_within_30_min'
                          ? 'complete_payment_within_30_min'.tr
                          : 'Complete payment via Paymob to confirm your trip.',
                      style: textRegular.copyWith(
                        fontSize: 12,
                        color: const Color(0xFFC2410C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassengersCard(List<Driver> passengers) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ADDITIONAL PASSENGERS',
                style: textSemiBold.copyWith(
                  color: _textSubtle,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${passengers.length} Passenger${passengers.length > 1 ? 's' : ''}',
                  style: textSemiBold.copyWith(
                    color: const Color(0xFF475569),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...passengers.map((p) {
            final pPhone = p.phone ?? '';
            final pName =
                p.displayName.isNotEmpty ? p.displayName : 'Passenger';
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFFE0F2FE),
                    child: Icon(Icons.person_rounded,
                        size: 16, color: Color(0xFF00A3EC)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pName,
                          style: textSemiBold.copyWith(
                            fontSize: 13,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        if (pPhone.isNotEmpty)
                          Text(
                            pPhone,
                            style: textRegular.copyWith(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (pPhone.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.call_rounded,
                          size: 18, color: Color(0xFF00A3EC)),
                      onPressed: () => _callPhone(pPhone),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactCard(EmergencyContact emergencyContact) {
    final phone = emergencyContact.phone ?? '';
    final name = emergencyContact.name ?? 'Emergency Contact';

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
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: Color(0xFFDC2626),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EMERGENCY CONTACT',
                  style: textSemiBold.copyWith(
                    color: _textSubtle,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: textBold.copyWith(
                    color: _textDark,
                    fontSize: 15,
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: textRegular.copyWith(
                      color: _textSubtle,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (phone.isNotEmpty)
            InkWell(
              onTap: () => _callPhone(phone),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.call_rounded,
                        size: 15, color: Color(0xFFDC2626)),
                    const SizedBox(width: 4),
                    Text(
                      'Call',
                      style: textBold.copyWith(
                        color: const Color(0xFFDC2626),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, double fare) {
    final isPaid = tripDetails.paymentStatus?.toLowerCase() == 'paid' ||
        (tripDetails.paidFare != null && tripDetails.paidFare! > 0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBEFF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PAYMENT METHOD',
                    style: textSemiBold.copyWith(
                      color: _textSubtle,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tripDetails.paymentMethod?.capitalizeFirst ?? 'Card',
                    style: textBold.copyWith(
                      color: _textDark,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPaid
                          ? Icons.check_circle_outline
                          : Icons.schedule_rounded,
                      size: 13,
                      color: isPaid
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFEF6C00),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPaid ? 'Paid' : 'Unpaid',
                      style: textBold.copyWith(
                        color: isPaid
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFEF6C00),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (tripDetails.isScheduledSubscription &&
              tripDetails.paymentResponsibility != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 14, color: _primaryBlue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      tripDetails.paymentResponsibility == 'creator_only'
                          ? 'Creator pays total subscription fare.'
                          : 'Payment is split among booked passengers.',
                      style: textMedium.copyWith(
                        color: const Color(0xFF475569),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // if (tripDetails.isScheduledSubscription &&
          //     tripDetails.returnFee != null &&
          //     tripDetails.returnFee! > 0) ...[
          //   const SizedBox(height: 14),
          //   const Divider(height: 1, color: Color(0xFFF0F3F7)),
          //   const SizedBox(height: 10),
          //   Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Text(
          //         'Outbound Rides',
          //         style: textRegular.copyWith(
          //           color: _textSubtle,
          //           fontSize: 13,
          //         ),
          //       ),
          //       Text(
          //         PriceConverter.convertPrice(
          //           fare > tripDetails.returnFee!
          //               ? fare - tripDetails.returnFee!
          //               : fare,
          //         ),
          //         style: textSemiBold.copyWith(
          //           color: _textDark,
          //           fontSize: 13,
          //         ),
          //       ),
          //     ],
          //   ),
          //   const SizedBox(height: 6),
          //   Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Text(
          //         'Return Rides Fee',
          //         style: textRegular.copyWith(
          //           color: _textSubtle,
          //           fontSize: 13,
          //         ),
          //       ),
          //       Text(
          //         PriceConverter.convertPrice(tripDetails.returnFee!),
          //         style: textSemiBold.copyWith(
          //           color: const Color(0xFF7C3AED),
          //           fontSize: 13,
          //         ),
          //       ),
          //     ],
          //   ),
          // ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0F3F7)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL FARE',
                style: textBold.copyWith(
                  color: _textDark,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                PriceConverter.convertPrice(fare),
                style: textBold.copyWith(
                  color: const Color(0xFF0077CC),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _callPhone(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _confirmCancelScheduledTrip(
      BuildContext context, TripDetails trip) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'cancel_request'.tr == 'cancel_request'
              ? 'Cancel Request'
              : 'cancel_request'.tr,
          style: textBold.copyWith(fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to cancel this scheduled request?'.tr,
          style: textRegular.copyWith(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'no'.tr,
              style: textSemiBold.copyWith(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'yes'.tr,
              style: textBold.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldCancel != true || trip.id == null) return;

    final response = await Get.find<RideController>().tripStatusUpdate(
      trip.id!,
      'cancelled',
      'scheduled_request_cancelled_successfully',
      '',
    );
    if (response?.statusCode == 200) {
      Get.find<TripController>().getTripList(1, reload: true);
      Get.back();
    }
  }

  Future<void> _confirmCancelParcel(
      BuildContext context, TripDetails trip) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'cancel_parcel'.tr == 'cancel_parcel'
              ? 'Cancel Parcel'
              : 'cancel_parcel'.tr,
          style: textBold.copyWith(fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to cancel this trip?'.tr,
          style: textRegular.copyWith(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'no'.tr,
              style: textSemiBold.copyWith(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'yes'.tr,
              style: textBold.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldCancel != true || trip.id == null) return;

    final response = await Get.find<RideController>().tripStatusUpdate(
      trip.id!,
      'cancelled',
      'parcel_request_cancelled_successfully',
      '',
    );
    if (response?.statusCode == 200) {
      Get.find<TripController>().getTripList(1, reload: true);
      Get.back();
    }
  }

  LatLng? _resolvePickupLatLng(TripDetails trip) {
    if (trip.carpoolRideLocation?.latitude != null &&
        trip.carpoolRideLocation?.longitude != null &&
        (trip.carpoolRideLocation!.latitude != 0.0 ||
            trip.carpoolRideLocation!.longitude != 0.0)) {
      return MapBoundHelper.toCorrectLatLng(
        trip.carpoolRideLocation!.latitude!,
        trip.carpoolRideLocation!.longitude!,
      );
    }
    if (trip.closestPcikupPoint != null &&
        trip.closestPcikupPoint!.length >= 2) {
      return MapBoundHelper.toCorrectLatLng(
        trip.closestPcikupPoint![0],
        trip.closestPcikupPoint![1],
      );
    }
    if (trip.customerRequestCoordinates?.coordinates != null &&
        trip.customerRequestCoordinates!.coordinates!.length >= 2) {
      return MapBoundHelper.toCorrectLatLng(
        trip.customerRequestCoordinates!.coordinates![0],
        trip.customerRequestCoordinates!.coordinates![1],
      );
    }
    if (trip.pickupCoordinates?.coordinates != null &&
        trip.pickupCoordinates!.coordinates!.length >= 2) {
      return MapBoundHelper.toCorrectLatLng(
        trip.pickupCoordinates!.coordinates![0],
        trip.pickupCoordinates!.coordinates![1],
      );
    }
    if (trip.pickupLocations != null && trip.pickupLocations!.isNotEmpty) {
      final loc = trip.pickupLocations!.first;
      if (loc.latitude != null &&
          loc.longitude != null &&
          (loc.latitude != 0.0 || loc.longitude != 0.0)) {
        return MapBoundHelper.toCorrectLatLng(loc.latitude!, loc.longitude!);
      }
    }
    if (trip.startCoordinates?.coordinates != null &&
        trip.startCoordinates!.coordinates!.length >= 2) {
      return MapBoundHelper.toCorrectLatLng(
        trip.startCoordinates!.coordinates![0],
        trip.startCoordinates!.coordinates![1],
      );
    }
    return MapBoundHelper.getPassengerPickup(trip) ??
        MapBoundHelper.getDriverStart(trip);
  }

  LatLng? _resolveDestinationLatLng(TripDetails trip) {
    if (trip.carpoolDropoffLocation?.latitude != null &&
        trip.carpoolDropoffLocation?.longitude != null &&
        (trip.carpoolDropoffLocation!.latitude != 0.0 ||
            trip.carpoolDropoffLocation!.longitude != 0.0)) {
      return MapBoundHelper.toCorrectLatLng(
        trip.carpoolDropoffLocation!.latitude!,
        trip.carpoolDropoffLocation!.longitude!,
      );
    }
    if (trip.destinationCoordinates?.coordinates != null &&
        trip.destinationCoordinates!.coordinates!.length >= 2) {
      return MapBoundHelper.toCorrectLatLng(
        trip.destinationCoordinates!.coordinates![0],
        trip.destinationCoordinates!.coordinates![1],
      );
    }
    if (trip.endCoordinates?.coordinates != null &&
        trip.endCoordinates!.coordinates!.length >= 2) {
      return MapBoundHelper.toCorrectLatLng(
        trip.endCoordinates!.coordinates![0],
        trip.endCoordinates!.coordinates![1],
      );
    }
    if (trip.destinationLocations != null &&
        trip.destinationLocations!.isNotEmpty) {
      final loc = trip.destinationLocations!.last;
      if (loc.latitude != null &&
          loc.longitude != null &&
          (loc.latitude != 0.0 || loc.longitude != 0.0)) {
        return MapBoundHelper.toCorrectLatLng(loc.latitude!, loc.longitude!);
      }
    }
    return MapBoundHelper.getPassengerDropoff(trip) ??
        MapBoundHelper.getDriverEnd(trip);
  }

  Future<void> _openGoogleMapsDirections({
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
        debugPrint('Geolocator error: $e');
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
      } else if (targetPos != null &&
          (targetPos.latitude != 0.0 || targetPos.longitude != 0.0)) {
        final fallbackUri = Uri.parse(
            'https://maps.google.com/maps?q=${targetPos.latitude},${targetPos.longitude}');
        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        } else {
          showCustomSnackBar('Could not open Google Maps'.tr);
        }
      } else {
        showCustomSnackBar('Could not open Google Maps'.tr);
      }
    } catch (e) {
      debugPrint('Error launching Google Maps directions: $e');
    }
  }
}

class _StatusCardConfig {
  final String title;
  final String subtitle;
  final String badgeText;
  final IconData icon;
  final Color cardBg;
  final Color primaryColor;

  const _StatusCardConfig({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.icon,
    required this.cardBg,
    required this.primaryColor,
  });
}
