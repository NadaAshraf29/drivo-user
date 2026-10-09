import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ride_sharing_user_app/features/auth/domain/enums/refund_status_enum.dart';
import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';

class _TripTime {
  final int hour;
  final int minute;
  const _TripTime(this.hour, this.minute);
}

class TripDetailsModel {
  TripDetails? data;

  TripDetailsModel({
    this.data,
  });

  TripDetailsModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawData = json['content'] ?? json['data'];
    data = (rawData != null && rawData is Map<String, dynamic>)
        ? TripDetails.fromJson(rawData)
        : null;
  }
}

class TripDetails {
  String? id;
  String? refId;
  Driver? driver;
  Vehicle? vehicle;
  VehicleCategory? vehicleCategory;
  double? estimatedFare;
  String? orgEstFare;
  String? estimatedTime;
  double? estimatedDistance;
  double? actualFare;
  double? discountActualFare;
  String? actualTime;
  String? carpoolType; //trip,north_coast,travel,routine
  String? actualDistance;
  String? waitingTime;
  String? idleTime;
  String? waitingFare;
  double? idleFee;
  double? delayFee;
  double? cancellationFee;
  double? distanceWiseFare;
  String? cancelledBy;
  double? vatTax;
  double? tips;
  String? additionalCharge;
  PickupCoordinates? pickupCoordinates;
  String? pickupAddress;
  PickupCoordinates? destinationCoordinates;
  String? destinationAddress;
  PickupCoordinates? startCoordinates;
  PickupCoordinates? endCoordinates;
  PickupCoordinates? customerRequestCoordinates;
  String? paymentMethod;
  double? couponAmount;
  double? discountAmount;
  String? note;
  String? totalFare;
  String? otp;
  int? riseRequestCount;
  String? type;
  String? createdAt;
  String? scheduledAt;
  String? departureTime;
  List<String>? selectedDates;
  String? startDate;
  String? startTime;
  String? pickupTime;
  String? date;
  String? time;
  String? entrance;
  String? intermediateAddresses;
  String? encodedPolyline;
  String? passengerPolyline;
  String? customerAvgRating;
  String? driverAvgRating;
  String? currentStatus;
  double? paidFare;
  bool? isPaused;
  ParcelInformation? parcelInformation;
  String? paymentStatus;
  bool? isLoading;
  bool? isReviewed;
  double? returnFee;
  double? dueAmount;
  String? returnTime;
  String? parcelCompleteTime;
  ParcelRefund? parcelRefund;
  CarpoolRideLocation? carpoolRideLocation;
  CarpoolRideLocation? carpoolDropoffLocation;
  CarpoolRideLocation? lastLocation;
  bool? isCarpool;
  String? distanceTexttt;
  List<Driver>? coPassengers;
  String? routeName;
  String? title;
  String? startAddress;
  String? endAddress;
  List<RouteStop>? stops;
  String? endDate;
  EmergencyContact? emergencyContact;
  List<TripLocationItem>? pickupLocations;
  List<TripLocationItem>? destinationLocations;
  List<int>? excludedWeekdays;
  int? seatsCount;
  String? paymentResponsibility;
  bool? isReturnTrip;
  Map<String, dynamic>? rawJson;

  bool get isScheduledSubscription =>
      type == 'scheduled_subscription' ||
      carpoolType == 'scheduled_subscription' ||
      type == 'subscription' ||
      carpoolType == 'subscription' ||
      (type != null && type!.toLowerCase().contains('subscri')) ||
      (carpoolType != null && carpoolType!.toLowerCase().contains('subscri')) ||
      type == 'special_request' ||
      carpoolType == 'special_request' ||
      type == 'special_trip' ||
      carpoolType == 'special_trip';

  bool get isCarpoolRide =>
      (isCarpool == true) ||
      type == 'carpool' ||
      carpoolType == 'carpool';

  int get totalSubscriptionDays {
    if (selectedDates != null && selectedDates!.isNotEmpty) {
      return selectedDates!.length;
    }
    return 1;
  }

  bool? hasReturnLeg;
  String? currentTripLeg;
  String? effectiveTripLeg;
  bool? canStartOutbound;
  bool? canStartReturn;
  bool? isReturnPending;

  bool get isReturnLeg {
    final leg = (effectiveTripLeg ?? currentTripLeg ?? '').toLowerCase().trim();
    return leg == 'return';
  }

  String get startAddressDisplay {
    final ct = (carpoolType ?? '').toLowerCase().trim();
    final t = (type ?? '').toLowerCase().trim();
    final isRoutine = ct == 'routine' ||
        t == 'routine' ||
        ct.contains('routine') ||
        t.contains('routine') ||
        isScheduledSubscription;

    // For routine / subscription trips, startAddress (from start_address key) takes highest priority
    if (isRoutine) {
      if (startAddress != null &&
          startAddress!.trim().isNotEmpty &&
          !isGenericPlaceholder(startAddress)) {
        return startAddress!.trim();
      }
    }

    if (carpoolRideLocation?.address != null &&
        carpoolRideLocation!.address!.trim().isNotEmpty &&
        !_isGenericPlaceholder(carpoolRideLocation!.address)) {
      return carpoolRideLocation!.address!.trim();
    }
    if (pickupAddress != null &&
        pickupAddress!.trim().isNotEmpty &&
        !_isGenericPlaceholder(pickupAddress)) {
      return pickupAddress!.trim();
    }
    if (pickupLocations != null && pickupLocations!.isNotEmpty) {
      final a = pickupLocations!.first.address;
      if (a != null && a.trim().isNotEmpty && !_isGenericPlaceholder(a)) {
        return a.trim();
      }
    }
    if (startAddress != null &&
        startAddress!.trim().isNotEmpty &&
        !isGenericPlaceholder(startAddress)) {
      return startAddress!.trim();
    }
    if (stops != null && stops!.isNotEmpty) {
      final a = stops!.first.address ?? stops!.first.name;
      if (a.trim().isNotEmpty && !isGenericPlaceholder(a)) {
        return a.trim();
      }
    }
    return '';
  }

  String get endAddressDisplay {
    final ct = (carpoolType ?? '').toLowerCase().trim();
    final t = (type ?? '').toLowerCase().trim();
    final isRoutine = ct == 'routine' ||
        t == 'routine' ||
        ct.contains('routine') ||
        t.contains('routine') ||
        isScheduledSubscription;

    // For routine / subscription trips, endAddress (from end_address key) takes highest priority
    if (isRoutine) {
      if (endAddress != null &&
          endAddress!.trim().isNotEmpty &&
          !isGenericPlaceholder(endAddress)) {
        return endAddress!.trim();
      }
    }

    if (carpoolDropoffLocation?.address != null &&
        carpoolDropoffLocation!.address!.trim().isNotEmpty &&
        !isGenericPlaceholder(carpoolDropoffLocation!.address)) {
      return carpoolDropoffLocation!.address!.trim();
    }
    if (destinationAddress != null &&
        destinationAddress!.trim().isNotEmpty &&
        !isGenericPlaceholder(destinationAddress)) {
      return destinationAddress!.trim();
    }
    if (destinationLocations != null && destinationLocations!.isNotEmpty) {
      final a = destinationLocations!.last.address;
      if (a != null && a.trim().isNotEmpty && !isGenericPlaceholder(a)) {
        return a.trim();
      }
    }
    if (endAddress != null &&
        endAddress!.trim().isNotEmpty &&
        !isGenericPlaceholder(endAddress)) {
      return endAddress!.trim();
    }
    if (stops != null && stops!.isNotEmpty) {
      final a = stops!.last.address ?? stops!.last.name;
      if (a.trim().isNotEmpty && !isGenericPlaceholder(a)) {
        return a.trim();
      }
    }
    return '';
  }

  static bool _isGenericPlaceholder(String? s) => isGenericPlaceholder(s);

  static bool isGenericPlaceholder(String? s) {
    if (s == null) return true;
    final c = s.trim().toLowerCase();
    if (c.isEmpty ||
        c == 'pickup' ||
        c == 'pick up' ||
        c == 'pickup location' ||
        c == 'pick up location' ||
        c == 'pickup_location' ||
        c == 'pick_up_location' ||
        c == 'start point' ||
        c == 'start address' ||
        c == 'start_point' ||
        c == 'start_address' ||
        c == 'destination' ||
        c == 'dropoff' ||
        c == 'drop off' ||
        c == 'dropoff location' ||
        c == 'drop off location' ||
        c == 'drop_off' ||
        c == 'dropoff_location' ||
        c == 'end point' ||
        c == 'end address' ||
        c == 'end_point' ||
        c == 'end_address' ||
        c == 'موقع الركوب' ||
        c == 'موقع الانطلاق' ||
        c == 'الوجهة' ||
        c == 'موقع الوصول' ||
        c == 'نقطة الانطلاق' ||
        c == 'نقطة الوصول' ||
        c == 'اختر موقعا' ||
        c == '--' ||
        c == '-') {
      return true;
    }
    try {
      if (c == 'pickup_location'.tr.toLowerCase() ||
          c == 'pickup'.tr.toLowerCase() ||
          c == 'destination'.tr.toLowerCase() ||
          c == 'drop_off'.tr.toLowerCase() ||
          c == 'end_address'.tr.toLowerCase() ||
          c == 'start_address'.tr.toLowerCase()) {
        return true;
      }
    } catch (_) {}
    return false;
  }

  String get routeNameDisplay {
    if (routeName != null && routeName!.trim().isNotEmpty) {
      return routeName!.trim();
    }
    if (title != null && title!.trim().isNotEmpty) {
      return title!.trim();
    }
    final p = pickupAddress?.split('-').first.trim() ?? '';
    final d = destinationAddress?.split('-').first.trim() ?? '';
    if (p.isNotEmpty && d.isNotEmpty) {
      return '$p → $d';
    }
    if (p.isNotEmpty) return p;
    if (d.isNotEmpty) return d;
    return '';
  }

  List<double>? closestPcikupPoint;
  String get distanceTextt {
    // 1. If the API already provides a distance text, use it directly
    // if (distanceTexttt != null && distanceTexttt!.isNotEmpty) {
    //   return distanceTexttt!;
    // }

    // 2. Fallback: Calculate distance using start and end coordinates
    try {
      final startLat = pickupCoordinates?.coordinates?[1];
      final startLng = pickupCoordinates?.coordinates?[0];
      final endLat = destinationCoordinates?.coordinates?[1];
      final endLng = destinationCoordinates?.coordinates?[0];

      // If any essential coordinate point is missing, we can't calculate
      if (startLat == null ||
          startLng == null ||
          endLat == null ||
          endLng == null) {
        return '';
      }

      // Haversine formula implementation
      const double earthRadius = 6371000; // Earth radius in meters

      final double dLat = _degToRad(endLat - startLat);
      final double dLng = _degToRad(endLng - startLng);

      final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
          math.cos(_degToRad(startLat)) *
              math.cos(_degToRad(endLat)) *
              math.sin(dLng / 2) *
              math.sin(dLng / 2);

      final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
      final double distanceInMeters = earthRadius * c;

      // 3. Adaptive Formatting (e.g., "950 m" vs "1.5 km")
      if (distanceInMeters < 1000) {
        return '${distanceInMeters.toStringAsFixed(0)} m';
      } else {
        final double distanceInKm = distanceInMeters / 1000;
        return '${distanceInKm.toStringAsFixed(1)} km';
      }
    } catch (e) {
      print('Error calculating distanceRealText: $e');
      return '';
    }
  }

  // Helper method to convert degrees to radians
  double _degToRad(double degree) {
    return degree * (3.1415926535897932 / 180);
  }

  TripDetails(
      {this.id,
      this.refId,
      this.driver,
      this.vehicle,
      this.vehicleCategory,
      this.estimatedFare,
      this.orgEstFare,
      this.closestPcikupPoint,
      this.estimatedTime,
      this.estimatedDistance,
      this.actualFare,
      this.actualTime,
      this.actualDistance,
      this.waitingTime,
      this.idleTime,
      this.waitingFare,
      this.idleFee,
      this.delayFee,
      this.cancellationFee,
      this.distanceWiseFare,
      this.cancelledBy,
      this.vatTax,
      this.tips,
      this.additionalCharge,
      this.pickupCoordinates,
      this.pickupAddress,
      this.destinationCoordinates,
      this.destinationAddress,
      this.startCoordinates,
      this.endCoordinates,
      this.customerRequestCoordinates,
      this.paymentMethod,
      this.couponAmount,
      this.discountAmount,
      this.discountActualFare,
      this.note,
      this.totalFare,
      this.otp,
      this.riseRequestCount,
      this.type,
      this.createdAt,
      this.scheduledAt,
      this.departureTime,
      this.selectedDates,
      this.startDate,
      this.startTime,
      this.pickupTime,
      this.date,
      this.time,
      this.entrance,
      this.encodedPolyline,
      this.passengerPolyline,
      this.customerAvgRating,
      this.driverAvgRating,
      this.currentStatus,
      this.paidFare,
      this.isPaused,
      this.parcelInformation,
      this.paymentStatus,
      this.isLoading,
      this.isReviewed,
      this.returnFee,
      this.dueAmount,
      this.returnTime,
      this.parcelCompleteTime,
      this.parcelRefund,
      this.carpoolRideLocation,
      this.carpoolDropoffLocation,
      this.lastLocation,
      this.isCarpool,
      this.distanceTexttt,
      this.coPassengers,
      this.routeName,
      this.title,
      this.startAddress,
      this.endAddress});
  String get formatedEstamitedTimeInMinutes {
    int parsedDate = (double.tryParse(estimatedTime ?? '0') ?? 0).floor();
    return '$parsedDate min';
  }

  String get realEstamitedTimeText {
    try {
      // 1. Determine driver position (live position if available, otherwise driver route start location)
      LatLng? driverPos;
      if (lastLocation?.latitude != null && lastLocation?.longitude != null) {
        driverPos = MapBoundHelper.toCorrectLatLng(
          lastLocation!.latitude!,
          lastLocation!.longitude!,
        );
      } else if (driver?.lastLocations?.latitude != null &&
          driver?.lastLocations?.longitude != null) {
        driverPos = MapBoundHelper.toCorrectLatLng(
          driver!.lastLocations!.latitude!,
          driver!.lastLocations!.longitude!,
        );
      } else {
        driverPos = _resolveDriverStartLatLng();
      }

      // 2. Determine passenger pickup position
      final LatLng? pickupPos = _resolveUserPickupLatLng();

      if (driverPos == null || pickupPos == null) {
        int fallbackMins = estimatedMinutesFromStartToPickup;
        return '$fallbackMins min';
      }

      final double directDistance = _computeDistanceMeters(driverPos, pickupPos);

      // If driver is right at the pickup point (less than 150m away)
      if (directDistance < 150) {
        return '1 min';
      }

      double distanceMeters = 0.0;

      // 3. Compute distance along encoded polyline if available AND points are distinct
      if (encodedPolyline != null && encodedPolyline!.isNotEmpty && directDistance > 200) {
        final decoded = MapBoundHelper.decodePolyline(encodedPolyline!);
        if (decoded.length >= 2) {
          final int driverIdx = _findClosestPolylineIndex(decoded, driverPos);
          final int pickupIdx = _findClosestPolylineIndex(decoded, pickupPos);

          if (pickupIdx > driverIdx && (pickupIdx - driverIdx) >= 2) {
            for (int i = driverIdx; i < pickupIdx; i++) {
              distanceMeters += _computeDistanceMeters(decoded[i], decoded[i + 1]);
            }
          } else if (driverIdx > pickupIdx && (driverIdx - pickupIdx) >= 2) {
            for (int i = pickupIdx; i < driverIdx; i++) {
              distanceMeters += _computeDistanceMeters(decoded[i], decoded[i + 1]);
            }
          }
        }
      }

      // 4. Fallback to Haversine direct road distance (1.35x multiplier for city road network geometry)
      if (distanceMeters <= 0.0) {
        distanceMeters = directDistance * 1.35;
      }

      // 5. Calculate ETA in minutes based on average city driving speed (~30 km/h = 500 m/min)
      const double metersPerMinute = 500.0;
      final int timeInMinutes = (distanceMeters / metersPerMinute).round();

      if (timeInMinutes < 1) {
        return '1 min';
      }
      return '$timeInMinutes min';
    } catch (e) {
      print('Error calculating realEstamitedTimeText: $e');
      return '10 min';
    }
  }

  String get formatedEstamitedTime {
    int parsedtime = (double.tryParse(estimatedTime ?? '0') ?? 0).floor();

    DateTime parsedDate = DateTime.parse(
        DateTime.now().add(Duration(minutes: parsedtime)).toIso8601String());
    return '${parsedDate.hour}:${parsedDate.minute}';
  }

  /// Calculates estimated duration in minutes from Driver Start Point -> User Pickup Point
  int get estimatedMinutesFromStartToPickup {
    try {
      final pickup = _resolveUserPickupLatLng();

      if (encodedPolyline != null && encodedPolyline!.isNotEmpty) {
        final decoded = MapBoundHelper.decodePolyline(encodedPolyline!);
        if (decoded.length >= 2) {
          final startPoint = decoded.first;

          if (pickup != null) {
            final pickupIdx = _findClosestPolylineIndex(decoded, pickup);
            if (pickupIdx > 0) {
              double distMeters = 0.0;
              for (int i = 0; i < pickupIdx; i++) {
                distMeters += _computeDistanceMeters(decoded[i], decoded[i + 1]);
              }
              // ~30 km/h average speed in city driving = 500 meters/minute
              final mins = (distMeters / (30.0 * 1000 / 60)).round();
              if (mins > 0) {
                return mins.clamp(2, 180);
              }
            }

            // If pickupIdx was 0, check direct distance from startPoint to pickup
            final direct = _computeDistanceMeters(startPoint, pickup);
            if (direct > 250) {
              final mins = ((direct * 1.35) / (30.0 * 1000 / 60)).round();
              if (mins > 0) return mins.clamp(2, 180);
            }
          }
        }
      }

      final start = _resolveDriverStartLatLng();
      if (start != null && pickup != null) {
        final direct = _computeDistanceMeters(start, pickup);
        if (direct > 250) {
          final mins = ((direct * 1.35) / (30.0 * 1000 / 60)).round();
          return mins.clamp(2, 180);
        }
      }

      return 12;
    } catch (_) {
      return 12;
    }
  }

  /// Calculates estimated duration in minutes from Driver Start Point -> User Drop-off Point
  int get estimatedMinutesFromStartToDropoff {
    try {
      final pickupMins = estimatedMinutesFromStartToPickup;
      final dropoff = _resolveUserDropoffLatLng();

      if (encodedPolyline != null && encodedPolyline!.isNotEmpty) {
        final decoded = MapBoundHelper.decodePolyline(encodedPolyline!);
        if (decoded.length >= 2) {
          int dropoffIdx = decoded.length - 1;

          if (dropoff != null) {
            final idx = _findClosestPolylineIndex(decoded, dropoff);
            if (idx > 0) {
              dropoffIdx = idx;
            }
          }

          double distMeters = 0.0;
          for (int i = 0; i < dropoffIdx; i++) {
            distMeters += _computeDistanceMeters(decoded[i], decoded[i + 1]);
          }

          final mins = (distMeters / (30.0 * 1000 / 60)).round();
          if (mins > pickupMins) {
            return mins.clamp(pickupMins + 5, 240);
          }
        }
      }

      final start = _resolveDriverStartLatLng();
      if (start != null && dropoff != null) {
        final direct = _computeDistanceMeters(start, dropoff);
        if (direct > 250) {
          final mins = ((direct * 1.35) / (30.0 * 1000 / 60)).round();
          return mins.clamp(pickupMins + 5, 240);
        }
      }

      return pickupMins + 25;
    } catch (_) {
      return estimatedMinutesFromStartToPickup + 25;
    }
  }

  /// Estimated clock arrival time at user pickup location
  String get estimatedPickupTime {
    final baseTime = _getTripTimeOfDay();
    if (baseTime == null) {
      if (formattedTime.isNotEmpty) return formattedTime;
      return '07:45 AM';
    }
    final mins = estimatedMinutesFromStartToPickup;
    final dt = DateTime(2026, 1, 1, baseTime.hour, baseTime.minute)
        .add(Duration(minutes: mins));
    return DateFormat('hh:mm a').format(dt);
  }

  /// Estimated clock arrival time at user drop-off location
  String get estimatedDropoffTime {
    final baseTime = _getTripTimeOfDay();
    if (baseTime == null) {
      return '08:20 AM';
    }
    final mins = estimatedMinutesFromStartToDropoff;
    final dt = DateTime(2026, 1, 1, baseTime.hour, baseTime.minute)
        .add(Duration(minutes: mins));
    return DateFormat('hh:mm a').format(dt);
  }

  /// Estimated clock arrival time at return pickup location
  String get estimatedReturnPickupTime {
    final baseTime = _getReturnTripTimeOfDay();
    if (baseTime == null) {
      if (formattedReturnTime.isNotEmpty) return formattedReturnTime;
      return '05:45 PM';
    }
    final mins = estimatedMinutesFromStartToPickup;
    final dt = DateTime(2026, 1, 1, baseTime.hour, baseTime.minute)
        .add(Duration(minutes: mins));
    return DateFormat('hh:mm a').format(dt);
  }

  /// Estimated clock arrival time at return drop-off location
  String get estimatedReturnDropoffTime {
    final baseTime = _getReturnTripTimeOfDay();
    if (baseTime == null) {
      return '06:20 PM';
    }
    final mins = estimatedMinutesFromStartToDropoff;
    final dt = DateTime(2026, 1, 1, baseTime.hour, baseTime.minute)
        .add(Duration(minutes: mins));
    return DateFormat('hh:mm a').format(dt);
  }

  LatLng? _resolveDriverStartLatLng() {
    if (!isReturnLeg &&
        startCoordinates?.coordinates != null &&
        startCoordinates!.coordinates!.length >= 2) {
      return MapBoundHelper.toCorrectLatLng(
        startCoordinates!.coordinates![0],
        startCoordinates!.coordinates![1],
      );
    }
    final driverStartFromHelper = MapBoundHelper.getDriverStart(this);
    if (!isReturnLeg && driverStartFromHelper != null) {
      return driverStartFromHelper;
    }
    if (encodedPolyline != null && encodedPolyline!.isNotEmpty) {
      final decoded = MapBoundHelper.decodePolyline(encodedPolyline!);
      if (decoded.isNotEmpty) {
        return isReturnLeg ? decoded.last : decoded.first;
      }
    }
    if (lastLocation?.latitude != null && lastLocation?.longitude != null) {
      return MapBoundHelper.toCorrectLatLng(
        lastLocation!.latitude!,
        lastLocation!.longitude!,
      );
    }
    return null;
  }

  LatLng? _resolveUserPickupLatLng() {
    if (carpoolRideLocation?.latitude != null &&
        carpoolRideLocation?.longitude != null &&
        (carpoolRideLocation!.latitude != 0.0 ||
            carpoolRideLocation!.longitude != 0.0)) {
      return MapBoundHelper.toCorrectLatLng(
        carpoolRideLocation!.latitude!,
        carpoolRideLocation!.longitude!,
      );
    }
    if (closestPcikupPoint != null && closestPcikupPoint!.length >= 2) {
      return MapBoundHelper.toCorrectLatLng(
        closestPcikupPoint![0],
        closestPcikupPoint![1],
      );
    }
    if (customerRequestCoordinates?.coordinates != null &&
        customerRequestCoordinates!.coordinates!.length >= 2) {
      return MapBoundHelper.toCorrectLatLng(
        customerRequestCoordinates!.coordinates![0],
        customerRequestCoordinates!.coordinates![1],
      );
    }
    if (pickupCoordinates?.coordinates != null &&
        pickupCoordinates!.coordinates!.length >= 2) {
      return MapBoundHelper.toCorrectLatLng(
        pickupCoordinates!.coordinates![0],
        pickupCoordinates!.coordinates![1],
      );
    }
    return null;
  }

  LatLng? _resolveUserDropoffLatLng() {
    if (carpoolDropoffLocation?.latitude != null &&
        carpoolDropoffLocation?.longitude != null &&
        (carpoolDropoffLocation!.latitude != 0.0 ||
            carpoolDropoffLocation!.longitude != 0.0)) {
      return MapBoundHelper.toCorrectLatLng(
        carpoolDropoffLocation!.latitude!,
        carpoolDropoffLocation!.longitude!,
      );
    }
    if (destinationCoordinates?.coordinates != null &&
        destinationCoordinates!.coordinates!.length >= 2) {
      return MapBoundHelper.toCorrectLatLng(
        destinationCoordinates!.coordinates![1],
        destinationCoordinates!.coordinates![0],
      );
    }
    if (endCoordinates?.coordinates != null &&
        endCoordinates!.coordinates!.length >= 2) {
      return MapBoundHelper.toCorrectLatLng(
        endCoordinates!.coordinates![1],
        endCoordinates!.coordinates![0],
      );
    }
    if (encodedPolyline != null && encodedPolyline!.isNotEmpty) {
      final decoded = MapBoundHelper.decodePolyline(encodedPolyline!);
      if (decoded.isNotEmpty) {
        return MapBoundHelper.toCorrectLatLng(
          decoded.last.latitude,
          decoded.last.longitude,
        );
      }
    }
    return null;
  }

  double _computeDistanceMeters(LatLng p1, LatLng p2) {
    const double earthRadius = 6371000;
    final double dLat = _degToRad(p2.latitude - p1.latitude);
    final double dLng = _degToRad(p2.longitude - p1.longitude);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(p1.latitude)) *
            math.cos(_degToRad(p2.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  int _findClosestPolylineIndex(List<LatLng> polyline, LatLng target) {
    final cTarget =
        MapBoundHelper.toCorrectLatLng(target.latitude, target.longitude);
    int closestIdx = 0;
    double minD = double.infinity;
    for (int i = 0; i < polyline.length; i++) {
      final p = MapBoundHelper.toCorrectLatLng(
          polyline[i].latitude, polyline[i].longitude);
      final dLat = p.latitude - cTarget.latitude;
      final dLng = p.longitude - cTarget.longitude;
      final d = dLat * dLat + dLng * dLng;
      if (d < minD) {
        minD = d;
        closestIdx = i;
      }
    }
    return closestIdx;
  }

  _TripTime? _getReturnTripTimeOfDay() {
    if (returnTime == null || returnTime!.trim().isEmpty) return null;
    final clean = returnTime!.trim();

    final amPmMatch =
        RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM|am|pm)$').firstMatch(clean);
    if (amPmMatch != null) {
      int hour = int.tryParse(amPmMatch.group(1)!) ?? 0;
      final int minute = int.tryParse(amPmMatch.group(2)!) ?? 0;
      final String period = amPmMatch.group(3)!.toUpperCase();
      if (period == 'PM' && hour < 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      return _TripTime(hour, minute);
    }

    final hourMinMatch =
        RegExp(r'^(\d{1,2}):(\d{2})(?::\d{2})?$').firstMatch(clean);
    if (hourMinMatch != null) {
      final int hour = int.tryParse(hourMinMatch.group(1)!) ?? 0;
      final int minute = int.tryParse(hourMinMatch.group(2)!) ?? 0;
      return _TripTime(hour, minute);
    }

    final parsedDate = DateTime.tryParse(clean);
    if (parsedDate != null) {
      final local = parsedDate.toLocal();
      return _TripTime(local.hour, local.minute);
    }

    return null;
  }

  _TripTime? _getTripTimeOfDay() {
    final candidates = [
      formattedTime,
      startTime,
      departureTime,
      pickupTime,
      time,
      scheduledAt,
      createdAt,
    ];

    for (final raw in candidates) {
      if (raw == null || raw.trim().isEmpty) continue;
      final clean = raw.trim();

      final amPmMatch =
          RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM|am|pm)$').firstMatch(clean);
      if (amPmMatch != null) {
        int hour = int.tryParse(amPmMatch.group(1)!) ?? 0;
        final int minute = int.tryParse(amPmMatch.group(2)!) ?? 0;
        final String period = amPmMatch.group(3)!.toUpperCase();
        if (period == 'PM' && hour < 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;
        return _TripTime(hour, minute);
      }

      final hourMinMatch =
          RegExp(r'^(\d{1,2}):(\d{2})(?::\d{2})?$').firstMatch(clean);
      if (hourMinMatch != null) {
        final int hour = int.tryParse(hourMinMatch.group(1)!) ?? 0;
        final int minute = int.tryParse(hourMinMatch.group(2)!) ?? 0;
        return _TripTime(hour, minute);
      }

      final parsedDate = DateTime.tryParse(clean);
      if (parsedDate != null) {
        final local = parsedDate.toLocal();
        return _TripTime(local.hour, local.minute);
      }
    }

    return null;
  }

  // 1. Getter for trip start date (Returns incoming trip date: today if before trip time, tomorrow if after trip time)
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tripTime = _getTripTimeOfDay();

    // 1. If selectedDates is provided
    if (selectedDates != null && selectedDates!.isNotEmpty) {
      List<DateTime> validDates = [];
      for (final s in selectedDates!) {
        try {
          final d = DateTime.tryParse(s.trim())?.toLocal();
          if (d != null) {
            validDates.add(DateTime(d.year, d.month, d.day));
          }
        } catch (_) {}
      }
      validDates.sort();

      for (final d in validDates) {
        final tripDateTime = DateTime(
          d.year,
          d.month,
          d.day,
          tripTime?.hour ?? 0,
          tripTime?.minute ?? 0,
        );
        if (tripDateTime.isAfter(now)) {
          return DateFormat('yyyy-MM-dd').format(d);
        }
      }
    }

    // 2. Check if a future start date was set (greater than today)
    DateTime? baseDate;
    final dateCandidates = [startDate, date, scheduledAt];
    for (final s in dateCandidates) {
      if (s != null && s.trim().isNotEmpty) {
        try {
          final d = DateTime.tryParse(s.trim())?.toLocal();
          if (d != null) {
            baseDate = DateTime(d.year, d.month, d.day);
            break;
          }
        } catch (_) {}
      }
    }

    if (baseDate != null && baseDate.isAfter(today)) {
      return DateFormat('yyyy-MM-dd').format(baseDate);
    }

    // 3. For today or repeating daily trips:
    // If trip time has not passed today, show today's date; otherwise show next day (tomorrow)
    if (tripTime != null) {
      final todayTripDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        tripTime.hour,
        tripTime.minute,
      );

      if (now.isBefore(todayTripDateTime)) {
        return DateFormat('yyyy-MM-dd').format(today);
      } else {
        final tomorrow = today.add(const Duration(days: 1));
        return DateFormat('yyyy-MM-dd').format(tomorrow);
      }
    }

    if (baseDate != null) {
      return DateFormat('yyyy-MM-dd').format(baseDate);
    }

    return DateFormat('yyyy-MM-dd').format(today);
  }

  // 2. Getter for trip start time (Prioritizes start time / departure time / pickup time, fallbacks to created_at)
  String get formattedTime {
    // 0. For scheduled subscription, scheduledAt has the exact scheduled outbound time (e.g. 2026-10-08T14:00:00.000000Z -> 02:00 PM)
    if (isScheduledSubscription) {
      if (scheduledAt != null &&
          scheduledAt!.trim().isNotEmpty &&
          scheduledAt != 'null') {
        final res = _parseTimeString(scheduledAt!.trim());
        if (res.isNotEmpty) return res;
      }
    }
    // 1. Try startTime
    if (startTime != null &&
        startTime!.trim().isNotEmpty &&
        startTime != 'null' &&
        startTime != '00:00' &&
        startTime != '00:00:00') {
      final res = _parseTimeString(startTime!.trim());
      if (res.isNotEmpty) return res;
    }
    // 2. Try departureTime
    if (departureTime != null &&
        departureTime!.trim().isNotEmpty &&
        departureTime != 'null' &&
        departureTime != '00:00' &&
        departureTime != '00:00:00') {
      final res = _parseTimeString(departureTime!.trim());
      if (res.isNotEmpty) return res;
    }
    // 3. Try pickupTime
    if (pickupTime != null &&
        pickupTime!.trim().isNotEmpty &&
        pickupTime != 'null' &&
        pickupTime != '00:00' &&
        pickupTime != '00:00:00') {
      final res = _parseTimeString(pickupTime!.trim());
      if (res.isNotEmpty) return res;
    }
    // 4. Try time field
    if (time != null &&
        time!.trim().isNotEmpty &&
        time != 'null' &&
        time != '00:00' &&
        time != '00:00:00') {
      final res = _parseTimeString(time!.trim());
      if (res.isNotEmpty) return res;
    }
    // 5. Try scheduledAt
    if (scheduledAt != null &&
        scheduledAt!.trim().isNotEmpty &&
        scheduledAt != 'null') {
      final res = _parseTimeString(scheduledAt!.trim());
      if (res.isNotEmpty) return res;
    }
    // 6. Fallback to createdAt only for normal non-subscription on-demand rides
    if (!isScheduledSubscription &&
        createdAt != null &&
        createdAt!.trim().isNotEmpty &&
        createdAt != 'null') {
      final res = _parseTimeString(createdAt!.trim());
      if (res.isNotEmpty) return res;
    }
    return '';
  }

  // 3. Getter for trip return time
  String get formattedReturnTime {
    if (returnTime != null &&
        returnTime!.trim().isNotEmpty &&
        returnTime != 'null' &&
        returnTime != '00:00' &&
        returnTime != '00:00:00') {
      final res = _parseTimeString(returnTime!.trim());
      if (res.isNotEmpty) return res;
    }
    if (isReturnLeg &&
        departureTime != null &&
        departureTime!.trim().isNotEmpty &&
        departureTime != 'null' &&
        departureTime != '00:00' &&
        departureTime != '00:00:00') {
      final res = _parseTimeString(departureTime!.trim());
      if (res.isNotEmpty) return res;
    }
    return '';
  }

  String get activeLegFormattedTime {
    if (isReturnLeg) {
      final ret = formattedReturnTime;
      if (ret.isNotEmpty) return ret;
      if (departureTime != null && departureTime!.trim().isNotEmpty) {
        final res = _parseTimeString(departureTime!.trim());
        if (res.isNotEmpty) return res;
      }
    }
    return formattedTime;
  }

  List<int> get selectedOperatingWeekdays {
    const allWeekdays = [7, 1, 2, 3, 4, 5, 6];
    if (excludedWeekdays != null && excludedWeekdays!.isNotEmpty) {
      final excluded = excludedWeekdays!
          .map((d) => d == 0 ? 7 : d)
          .toSet();
      final active = allWeekdays.where((d) => !excluded.contains(d)).toList();
      if (active.isNotEmpty) return active;
    }
    if (selectedDates != null && selectedDates!.isNotEmpty) {
      final days = <int>{};
      for (final dateStr in selectedDates!) {
        final dt = DateTime.tryParse(dateStr.trim());
        if (dt != null) {
          days.add(dt.weekday);
        }
      }
      if (days.isNotEmpty) {
        return allWeekdays.where((d) => days.contains(d)).toList();
      }
    }
    return [7, 1, 2, 3, 4];
  }

  bool get hasReturnTrip {
    return (isReturnTrip == true) ||
        (returnTime != null &&
        returnTime!.trim().isNotEmpty &&
        returnTime != 'null' &&
        returnTime != '00:00' &&
        returnTime != '00:00:00') ||
        (returnFee != null && returnFee! > 0);
  }

  static String parseDateString(String raw) {
    try {
      if (raw.isEmpty) return '';
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) {
        return raw;
      }
      final parsedDate = DateTime.parse(raw).toLocal();
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      if (raw.length <= 12) return raw;
      return '';
    }
  }

  static String _parseTimeString(String raw) {
    try {
      if (raw.isEmpty) return '';
      if (RegExp(r'^\d{1,2}:\d{2}\s*(AM|PM|am|pm)$').hasMatch(raw)) {
        return raw.toUpperCase();
      }
      if (RegExp(r'^\d{1,2}:\d{2}(:\d{2})?$').hasMatch(raw)) {
        final parts = raw.split(':');
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        final dt = DateTime(2026, 1, 1, hour, minute);
        return DateFormat('hh:mm a').format(dt);
      }
      // Check for ISO timestamp with wall-clock time like 2026-10-08T14:00:00.000000Z
      final isoMatch = RegExp(r'[T ](\d{1,2}):(\d{2})').firstMatch(raw);
      if (isoMatch != null) {
        final hour = int.tryParse(isoMatch.group(1)!) ?? 0;
        final minute = int.tryParse(isoMatch.group(2)!) ?? 0;
        final dt = DateTime(2026, 1, 1, hour, minute);
        return DateFormat('hh:mm a').format(dt);
      }
      final parsedDate = DateTime.parse(raw);
      return DateFormat('hh:mm a').format(parsedDate);
    } catch (e) {
      return raw;
    }
  }

  String get driverRating {
    if (driverAvgRating == null || (driverAvgRating?.isEmpty ?? true)) {
      return 'N/A';
    }
    try {
      final parsedRating = double.parse(driverAvgRating ?? '0');
      return parsedRating.toStringAsFixed(1); // أو asFixed(2) حسب الرغبة
    } catch (e) {
      return ''; // في حال كان التنسيق غير صحيح
    }
  }

  String get driverRatingText {
    if (driverAvgRating != null &&
        driverAvgRating!.isNotEmpty &&
        driverAvgRating != '0') {
      return driverAvgRating!;
    }
    if (driver?.rating != null) {
      return driver!.rating!.toStringAsFixed(1);
    }
    return "5.0";
  }

  String get carpoolTypeString {
    if (type == 'carpool') {
      //only first char is uppercase and capitalize rest of the letters
      final carpoolTtype = carpoolType ?? '';
      return carpoolTtype
          .trim() // إزالة المسافات الزائدة من البداية والنهاية
          .replaceAll('_', ' ')
          .split(' ')
          .where((e) =>
              e.isNotEmpty) // فلترة وإلغاء أي عناصر فارغة لتجنب الـ RangeError
          .map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase())
          .join(' ');
    }
    return '';
  }

  bool get isTravelOrNorthCoast {
    final ct = (carpoolType ?? '').toLowerCase().trim();
    final t = (type ?? '').toLowerCase().trim();
    final rName = (routeName ?? '').toLowerCase();
    final ttl = (title ?? '').toLowerCase();

    return ct == 'travel' ||
        ct == 'north_coast' ||
        ct == 'sahel' ||
        t == 'travel' ||
        t == 'north_coast' ||
        t == 'sahel' ||
        rName.contains('north coast') ||
        rName.contains('north_coast') ||
        rName.contains('sahel') ||
        rName.contains('travel') ||
        rName.contains('الساحل') ||
        rName.contains('سفر') ||
        ttl.contains('north coast') ||
        ttl.contains('north_coast') ||
        ttl.contains('sahel') ||
        ttl.contains('travel') ||
        ttl.contains('الساحل') ||
        ttl.contains('سفر');
  }

  TripDetails.fromJson(Map<String, dynamic> json) {
    print('=== TripDetails.fromJson called ===');
    print('JSON keys: ${json.keys.toList()}');
    rawJson = json;

    try {
      id = json['id'];
      print('id: $id');

      refId = json['ref_id']?.toString() ?? '';
      print('refId: $refId');

      driver = json['driver'] != null ? Driver.fromJson(json['driver']) : null;
      print('driver: ${driver != null ? 'parsed' : 'null'}');

      vehicle =
          json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null;
      print('vehicle: ${vehicle != null ? 'parsed' : 'null'}');

      vehicleCategory = json['vehicle_category'] != null
          ? VehicleCategory.fromJson(json['vehicle_category'])
          : null;
      print('vehicleCategory: ${vehicleCategory != null ? 'parsed' : 'null'}');

      estimatedFare = json['estimated_fare'] != null
          ? double.tryParse(json['estimated_fare'].toString()) ?? 0.0
          : 0.0;
      print('estimatedFare: $estimatedFare');

      orgEstFare = json['org_est_fare']?.toString() ?? '';
      print('orgEstFare: $orgEstFare');

      estimatedTime = json['estimated_time']?.toString() ??
          (json['duration_minutes'] != null
              ? json['duration_minutes'].toString()
              : '');
      print('estimatedTime: $estimatedTime');

      estimatedDistance = json['estimated_distance'] != null
          ? double.tryParse(json['estimated_distance']
                  .toString()
                  .replaceAll('km', '')
                  .trim()) ??
              0.0
          : (json['distance_km'] != null
              ? double.tryParse(json['distance_km'].toString()) ?? 0.0
              : 0.0);
      print('estimatedDistance: $estimatedDistance');

      actualFare = json['actual_fare'] != null
          ? double.tryParse(json['actual_fare'].toString()) ?? 0.0
          : (json['paid_amount'] != null
              ? double.tryParse(json['paid_amount'].toString()) ?? 0.0
              : 0.0);
      print('actualFare: $actualFare');

      discountActualFare = json['discount_actual_fare']?.toDouble() ?? 0.0;
      print('discountActualFare: $discountActualFare');

      actualTime = json['actual_time']?.toString() ?? '';
      print('actualTime: $actualTime');

      actualDistance = json['actual_distance']?.toString() ?? '';
      print('actualDistance: $actualDistance');

      waitingTime = json['waiting_time']?.toString() ?? '';
      print('waitingTime: $waitingTime');

      idleTime = json['idle_time']?.toString() ?? '';
      print('idleTime: $idleTime');

      waitingFare = json['waiting_fare']?.toString() ?? '';
      print('waitingFare: $waitingFare');

      if (json['idle_fee'] != null) {
        idleFee = json['idle_fee'].toDouble();
      }
      if (json['delay_fee'] != null) {
        delayFee = json['delay_fee'].toDouble();
      }
      if (json['cancellation_fee'] != null) {
        cancellationFee = json['cancellation_fee'].toDouble();
      }
      if (json['distance_wise_fare'] != null) {
        distanceWiseFare = json['distance_wise_fare'].toDouble();
      }
      if (json['return_fee'] != null) {
        try {
          returnFee = json['return_fee'].toDouble();
        } catch (_) {
          returnFee = double.tryParse(json['return_fee'].toString()) ?? 0.0;
        }
      }
      dueAmount = json['due_amount']?.toDouble() ?? 0.0;

      cancelledBy = json['cancelled_by'];
      if (json['vat_tax'] != null) {
        vatTax = json['vat_tax'].toDouble();
      }

      if (json['tips'] != null) {
        tips = json['tips'].toDouble();
      }
      additionalCharge = json['additional_charge']?.toString() ?? '';
      pickupCoordinates = _parseCoordinates(
        json['pickup_coordinates'] ??
            json['carpool_ride_location'] ??
            json['pickup_location'] ??
            json['pickup_point_coordinates'] ??
            json['customer_pickup_coordinates'] ??
            json['school_pickup_coordinates'] ??
            json['uni_pickup_coordinates'] ??
            (json['pickup_latitude'] != null && json['pickup_longitude'] != null
                ? {'latitude': json['pickup_latitude'], 'longitude': json['pickup_longitude']}
                : (json['pickup_lat'] != null && json['pickup_lng'] != null
                    ? {'latitude': json['pickup_lat'], 'longitude': json['pickup_lng']}
                    : (json['from_latitude'] != null && json['from_longitude'] != null
                        ? {'latitude': json['from_latitude'], 'longitude': json['from_longitude']}
                        : (json['from_lat'] != null && json['from_lng'] != null
                            ? {'latitude': json['from_lat'], 'longitude': json['from_lng']}
                            : null)))),
      );
      carpoolType = json['carpool_type']?.toString() ?? json['type']?.toString();
      startAddress = json['start_address']?.toString() ??
          json['start_point']?.toString() ??
          json['start_location']?.toString() ??
          json['pickup_address']?.toString() ??
          json['from_address']?.toString() ??
          json['from_point']?.toString() ??
          (json['carpool_ride_location'] is Map
              ? (json['carpool_ride_location']['address']?.toString() ??
                  json['carpool_ride_location']['name']?.toString() ??
                  json['carpool_ride_location']['location_name']?.toString())
              : null);
      pickupAddress = json['pickup_address']?.toString() ??
          json['start_address']?.toString() ??
          json['from_address']?.toString() ??
          json['from_area']?.toString() ??
          json['pickup_point']?.toString() ??
          (json['carpool_ride_location'] is Map
              ? (json['carpool_ride_location']['address']?.toString() ??
                  json['carpool_ride_location']['name']?.toString() ??
                  json['carpool_ride_location']['location_name']?.toString())
              : null) ??
          json['meeting_point']?.toString() ??
          json['pickup_location_name']?.toString() ??
          startAddress;
      startAddress ??= pickupAddress;
      pickupAddress ??= startAddress;
      destinationCoordinates = _parseCoordinates(
        json['destination_coordinates'] ??
            json['carpool_dropoff_location'] ??
            json['destination_location'] ??
            json['dropoff_coordinates'] ??
            json['dropoff_location'] ??
            json['customer_destination_coordinates'] ??
            json['customer_dropoff_coordinates'] ??
            json['school_coordinates'] ??
            json['university_coordinates'] ??
            json['uni_coordinates'] ??
            (json['destination_latitude'] != null && json['destination_longitude'] != null
                ? {'latitude': json['destination_latitude'], 'longitude': json['destination_longitude']}
                : (json['destination_lat'] != null && json['destination_lng'] != null
                    ? {'latitude': json['destination_lat'], 'longitude': json['destination_lng']}
                    : (json['school_latitude'] != null && json['school_longitude'] != null
                        ? {'latitude': json['school_latitude'], 'longitude': json['school_longitude']}
                        : (json['school_lat'] != null && json['school_lng'] != null
                            ? {'latitude': json['school_lat'], 'longitude': json['school_lng']}
                            : (json['university_latitude'] != null && json['university_longitude'] != null
                                ? {'latitude': json['university_latitude'], 'longitude': json['university_longitude']}
                                : (json['university_lat'] != null && json['university_lng'] != null
                                    ? {'latitude': json['university_lat'], 'longitude': json['university_lng']}
                                    : (json['dropoff_latitude'] != null && json['dropoff_longitude'] != null
                                        ? {'latitude': json['dropoff_latitude'], 'longitude': json['dropoff_longitude']}
                                        : (json['to_latitude'] != null && json['to_longitude'] != null
                                            ? {'latitude': json['to_latitude'], 'longitude': json['to_longitude']}
                                            : null)))))))),
      );
      endAddress = json['end_address']?.toString() ??
          json['end_point']?.toString() ??
          json['end_location']?.toString() ??
          json['destination_address']?.toString() ??
          json['to_address']?.toString() ??
          json['to_point']?.toString() ??
          (json['carpool_dropoff_location'] is Map
              ? (json['carpool_dropoff_location']['address']?.toString() ??
                  json['carpool_dropoff_location']['name']?.toString() ??
                  json['carpool_dropoff_location']['location_name']?.toString())
              : null) ??
          json['dropoff_address']?.toString() ??
          json['to_school']?.toString();
      destinationAddress = json['destination_address']?.toString() ??
          json['end_address']?.toString() ??
          json['to_school']?.toString() ??
          json['to_university']?.toString() ??
          json['destination_point']?.toString() ??
          json['dropoff_address']?.toString() ??
          (json['carpool_dropoff_location'] is Map
              ? (json['carpool_dropoff_location']['address']?.toString() ??
                  json['carpool_dropoff_location']['name']?.toString() ??
                  json['carpool_dropoff_location']['location_name']?.toString())
              : null) ??
          json['dropoff_location_name']?.toString() ??
          endAddress;
      endAddress ??= destinationAddress;
      destinationAddress ??= endAddress;

      final rawPickups = json['pickup_locations'] ?? json['pickup_points'];
      if (rawPickups is List) {
        pickupLocations = rawPickups
            .map((loc) => TripLocationItem.fromJson(loc))
            .where((loc) => loc.address != null && loc.address!.trim().isNotEmpty)
            .toList();
      }
      final rawDests = json['destination_locations'] ?? json['destination_points'];
      if (rawDests is List) {
        destinationLocations = rawDests
            .map((loc) => TripLocationItem.fromJson(loc))
            .where((loc) => loc.address != null && loc.address!.trim().isNotEmpty)
            .toList();
      }

      if ((pickupLocations == null || pickupLocations!.isEmpty) &&
          (destinationLocations == null || destinationLocations!.isEmpty) &&
          json['stops'] is List) {
        final stopsList = json['stops'] as List;
        final pList = <TripLocationItem>[];
        final dList = <TripLocationItem>[];
        for (var s in stopsList) {
          if (s is Map) {
            final stopType = s['stop_type']?.toString().toLowerCase() ?? 'pickup';
            final locItem = TripLocationItem.fromJson(s);
            if (locItem.address != null && locItem.address!.trim().isNotEmpty) {
              if (stopType == 'destination' || stopType == 'dropoff') {
                dList.add(locItem);
              } else {
                pList.add(locItem);
              }
            }
          }
        }
        if (pList.isNotEmpty) pickupLocations = pList;
        if (dList.isNotEmpty) destinationLocations = dList;
      }

      // Deduplicate pickup locations while preserving order
      if (pickupLocations != null && pickupLocations!.isNotEmpty) {
        final seen = <String>{};
        pickupLocations = pickupLocations!.where((loc) {
          final a = (loc.address ?? '').trim().toLowerCase();
          return a.isNotEmpty && seen.add(a);
        }).toList();
      }

      // Deduplicate destination locations while preserving order
      if (destinationLocations != null && destinationLocations!.isNotEmpty) {
        final seen = <String>{};
        destinationLocations = destinationLocations!.where((loc) {
          final a = (loc.address ?? '').trim().toLowerCase();
          return a.isNotEmpty && seen.add(a);
        }).toList();
      }

      if (pickupAddress == null || pickupAddress!.isEmpty) {
        if (pickupLocations != null && pickupLocations!.isNotEmpty) {
          pickupAddress = pickupLocations!.first.address;
          startAddress ??= pickupAddress;
        } else if (json['pickup_locations'] is List &&
            (json['pickup_locations'] as List).isNotEmpty) {
          final firstLoc = (json['pickup_locations'] as List).first;
          if (firstLoc is Map) {
            pickupAddress = firstLoc['address']?.toString();
            startAddress ??= pickupAddress;
          }
        }
      }
      if (destinationAddress == null || destinationAddress!.isEmpty) {
        if (destinationLocations != null && destinationLocations!.isNotEmpty) {
          destinationAddress = destinationLocations!.last.address;
          endAddress ??= destinationAddress;
        } else if (json['destination_locations'] is List &&
            (json['destination_locations'] as List).isNotEmpty) {
          final lastLoc = (json['destination_locations'] as List).last;
          if (lastLoc is Map) {
            destinationAddress = lastLoc['address']?.toString();
            endAddress ??= destinationAddress;
          }
        }
      }

      if (pickupLocations != null && pickupLocations!.isNotEmpty) {
        for (var loc in pickupLocations!) {
          if (loc.latitude != null && loc.longitude != null) {
            final corrected = MapBoundHelper.toCorrectLatLng(loc.latitude!, loc.longitude!);
            loc.latitude = corrected.latitude;
            loc.longitude = corrected.longitude;
          }
        }
      }

      if (pickupLocations == null || pickupLocations!.isEmpty) {
        if (pickupAddress != null && pickupAddress!.isNotEmpty) {
          double? lat;
          double? lng;
          if (pickupCoordinates?.coordinates != null &&
              pickupCoordinates!.coordinates!.length >= 2) {
            final c = MapBoundHelper.toCorrectLatLng(
              pickupCoordinates!.coordinates![0],
              pickupCoordinates!.coordinates![1],
            );
            lat = c.latitude;
            lng = c.longitude;
          }
          pickupLocations = [
            TripLocationItem(
              address: pickupAddress,
              latitude: lat,
              longitude: lng,
            ),
          ];
        }
      } else if (pickupLocations!.isNotEmpty &&
          pickupLocations!.first.latitude == null &&
          pickupCoordinates?.coordinates != null &&
          pickupCoordinates!.coordinates!.length >= 2) {
        final c = MapBoundHelper.toCorrectLatLng(
          pickupCoordinates!.coordinates![0],
          pickupCoordinates!.coordinates![1],
        );
        pickupLocations!.first.latitude = c.latitude;
        pickupLocations!.first.longitude = c.longitude;
      }

      if (destinationLocations != null && destinationLocations!.isNotEmpty) {
        for (var loc in destinationLocations!) {
          if (loc.latitude != null && loc.longitude != null) {
            final corrected = MapBoundHelper.toCorrectLatLng(loc.latitude!, loc.longitude!);
            loc.latitude = corrected.latitude;
            loc.longitude = corrected.longitude;
          }
        }
      }

      if (destinationLocations == null || destinationLocations!.isEmpty) {
        if (destinationAddress != null && destinationAddress!.isNotEmpty) {
          double? lat;
          double? lng;
          if (destinationCoordinates?.coordinates != null &&
              destinationCoordinates!.coordinates!.length >= 2) {
            final c = MapBoundHelper.toCorrectLatLng(
              destinationCoordinates!.coordinates![0],
              destinationCoordinates!.coordinates![1],
            );
            lat = c.latitude;
            lng = c.longitude;
          }
          destinationLocations = [
            TripLocationItem(
              address: destinationAddress,
              latitude: lat,
              longitude: lng,
            ),
          ];
        }
      } else if (destinationLocations!.isNotEmpty &&
          destinationLocations!.last.latitude == null &&
          destinationCoordinates?.coordinates != null &&
          destinationCoordinates!.coordinates!.length >= 2) {
        final c = MapBoundHelper.toCorrectLatLng(
          destinationCoordinates!.coordinates![0],
          destinationCoordinates!.coordinates![1],
        );
        destinationLocations!.last.latitude = c.latitude;
        destinationLocations!.last.longitude = c.longitude;
      }
      startCoordinates = _parseCoordinates(json['start_coordinates'] ??
          json['route_start_point'] ??
          json['driver_start_point'] ??
          json['driver_start_location'] ??
          json['start_location'] ??
          (json['start_latitude'] != null && json['start_longitude'] != null
              ? {'latitude': json['start_latitude'], 'longitude': json['start_longitude']}
              : (json['start_lat'] != null && json['start_lng'] != null
                  ? {'latitude': json['start_lat'], 'longitude': json['start_lng']}
                  : null)));
      endCoordinates = _parseCoordinates(json['end_coordinates'] ??
          json['route_end_point'] ??
          json['driver_end_point'] ??
          json['driver_end_location'] ??
          json['end_location'] ??
          (json['end_latitude'] != null && json['end_longitude'] != null
              ? {'latitude': json['end_latitude'], 'longitude': json['end_longitude']}
              : (json['end_lat'] != null && json['end_lng'] != null
                  ? {'latitude': json['end_lat'], 'longitude': json['end_lng']}
                  : null)));
      customerRequestCoordinates = json['customer_request_coordinates'] != null
          ? PickupCoordinates.fromJson(json['customer_request_coordinates'])
          : null;

      carpoolRideLocation = json['carpool_ride_location'] != null
          ? CarpoolRideLocation.fromJson(json['carpool_ride_location'])
          : null;
      carpoolDropoffLocation = json['carpool_dropoff_location'] != null
          ? CarpoolRideLocation.fromJson(json['carpool_dropoff_location'])
          : (json['carpool_destination_location'] != null
              ? CarpoolRideLocation.fromJson(json['carpool_destination_location'])
              : null);
      lastLocation = json['last_location'] != null
          ? CarpoolRideLocation.fromJson(json['last_location'])
          : (json['last_locations'] != null
              ? CarpoolRideLocation.fromJson(json['last_locations'])
              : (json['driver_last_location'] != null
                  ? CarpoolRideLocation.fromJson(json['driver_last_location'])
                  : (json['driver_last_locations'] != null
                      ? CarpoolRideLocation.fromJson(json['driver_last_locations'])
                      : (json['driver_location'] != null
                          ? CarpoolRideLocation.fromJson(json['driver_location'])
                          : (json['current_location'] != null
                              ? CarpoolRideLocation.fromJson(json['current_location'])
                              : (json['driver_coordinates'] != null
                                  ? CarpoolRideLocation.fromJson(json['driver_coordinates'])
                                  : (json['driver'] is Map &&
                                          json['driver']['last_locations'] != null
                                      ? CarpoolRideLocation.fromJson(
                                          json['driver']['last_locations'])
                                      : (json['driver'] is Map &&
                                              json['driver']['last_location'] != null
                                          ? CarpoolRideLocation.fromJson(
                                              json['driver']['last_location'])
                                          : (json['driver'] is Map &&
                                                  json['driver']['location'] != null
                                              ? CarpoolRideLocation.fromJson(
                                                  json['driver']['location'])
                                              : (json['driver'] is Map &&
                                                      json['driver']['coordinates'] != null
                                                  ? CarpoolRideLocation.fromJson(
                                                      json['driver']['coordinates'])
                                                  : (json['driver_lat'] != null && json['driver_lng'] != null
                                                      ? CarpoolRideLocation(
                                                          latitude: CarpoolRideLocation._parseCoordinate(json['driver_lat']),
                                                          longitude: CarpoolRideLocation._parseCoordinate(json['driver_lng']),
                                                        )
                                                      : (json['driver_latitude'] != null && json['driver_longitude'] != null
                                                          ? CarpoolRideLocation(
                                                              latitude: CarpoolRideLocation._parseCoordinate(json['driver_latitude']),
                                                              longitude: CarpoolRideLocation._parseCoordinate(json['driver_longitude']),
                                                            )
                                                          : null))))))))))));

      paymentMethod = json['payment_method'];
      if (json['coupon_amount'] != null) {
        try {
          couponAmount = json['coupon_amount'].toDouble();
        } catch (e) {
          couponAmount = double.parse(json['coupon_amount'].toString());
        }
      }

      discountAmount =
          double.tryParse(json['discount_amount']?.toString() ?? '0') ?? 0.0;
      note = json['note'];
      totalFare = json['total_fare']?.toString() ?? '';
      otp = json['otp']?.toString() ??
          json['otp_key']?.toString() ??
          json['key']?.toString() ??
          json['start_otp']?.toString() ??
          json['trip_otp']?.toString() ??
          json['otp_code']?.toString() ??
          json['start_trip_otp']?.toString() ??
          json['start_trip_code']?.toString() ??
          json['verification_code']?.toString() ??
          json['pin']?.toString() ??
          json['ride_otp']?.toString() ??
          (json['trip_request'] is Map
              ? (json['trip_request']['otp']?.toString() ??
                  json['trip_request']['otp_key']?.toString())
              : null) ??
          (json['ride_request'] is Map
              ? (json['ride_request']['otp']?.toString() ??
                  json['ride_request']['otp_key']?.toString())
              : null) ??
          (json['routine_trip'] is Map
              ? (json['routine_trip']['otp']?.toString() ??
                  json['routine_trip']['otp_key']?.toString())
              : null) ??
          (json['subscription'] is Map
              ? (json['subscription']['otp']?.toString() ??
                  json['subscription']['otp_key']?.toString())
              : null) ??
          (json['carpool_trip'] is Map
              ? (json['carpool_trip']['otp']?.toString() ??
                  json['carpool_trip']['otp_key']?.toString())
              : null) ??
          (json['trip'] is Map
              ? (json['trip']['otp']?.toString() ??
                  json['trip']['otp_key']?.toString())
              : null) ??
          (json['passenger'] is Map
              ? (json['passenger']['otp']?.toString() ??
                  json['passenger']['otp_key']?.toString())
              : null) ??
          (json['booking'] is Map
              ? (json['booking']['otp']?.toString() ??
                  json['booking']['otp_key']?.toString())
              : null);
      riseRequestCount = json['rise_request_count'];
      type = json['type'];
      routeName = json['route_name']?.toString() ??
          json['routine_name']?.toString() ??
          json['route_title']?.toString() ??
          json['title']?.toString() ??
          json['name']?.toString() ??
          json['carpool_route_name']?.toString() ??
          json['carpool_type_label']?.toString();
      title = json['title']?.toString() ?? json['route_name']?.toString();
        createdAt = json['created_at']?.toString();
        scheduledAt = json['scheduled_at']?.toString();
        departureTime = json['departure_time']?.toString() ??
            json['start_time']?.toString() ??
            json['pickup_time']?.toString() ??
            json['time']?.toString();
        selectedDates = (json['selected_dates'] as List?)
            ?.map((date) => date.toString())
            .toList();
        startDate = json['start_date']?.toString() ??
            json['scheduled_date']?.toString() ??
            json['date']?.toString() ??
            json['trip_date']?.toString() ??
            (selectedDates != null && selectedDates!.isNotEmpty
                ? selectedDates!.first
                : null);
        endDate = json['end_date']?.toString() ??
            (selectedDates != null && selectedDates!.isNotEmpty
                ? selectedDates!.last
                : null);
        startTime = json['start_time']?.toString() ??
            json['outbound_time']?.toString() ??
            json['departure_time']?.toString() ??
            json['pickup_time']?.toString() ??
            json['time']?.toString() ??
            json['trip_time']?.toString() ??
            json['scheduled_time']?.toString();
        pickupTime = json['pickup_time']?.toString();
        date = json['date']?.toString();
        time = json['time']?.toString();
        if (departureTime == null || departureTime!.isEmpty) {
          departureTime = startTime;
        }
      entrance = json['entrance'];
      intermediateAddresses = json['intermediate_addresses'];
      stops = MapBoundHelper.getDriverStops(json);
      closestPcikupPoint = json['closest_pickup_point'] != null
          ? (json['closest_pickup_point'] as List<dynamic>)
              .map((e) => (e as num).toDouble())
              .toList()
          : null;
      passengerPolyline = json['passenger_polyline']?.toString();
      encodedPolyline = (json['encoded_polyline'] != null &&
              json['encoded_polyline'].toString().isNotEmpty)
          ? json['encoded_polyline'].toString()
          : (json['driver_encoded_polyline'] ??
                  json['driver_polyline'] ??
                  json['route_polyline'] ??
                  json['full_encoded_polyline'] ??
                  json['full_polyline'] ??
                  json['passenger_polyline'])
              ?.toString();
      customerAvgRating = json['customer_avg_rating'];
      driverAvgRating = json['driver_avg_rating'];
      currentStatus = json['current_status'];
      if (json['paid_fare'] != null) {
        try {
          paidFare = json['paid_fare'].toDouble();
        } catch (e) {
          paidFare = double.parse(json['paid_fare'].toString());
        }
      }

      parcelRefund = json['parcel_refund'] != null
          ? ParcelRefund.fromJson(json['parcel_refund'])
          : null;

      isPaused = json['is_paused'];
      parcelInformation = json['parcel_information'] != null
          ? ParcelInformation.fromJson(json['parcel_information'])
          : null;
      paymentStatus = json['payment_status'];
      isLoading = false;
      isReviewed = json['driver_review'];
      returnTime = json['return_time']?.toString() ??
          json['return_trip_time']?.toString() ??
          json['evening_time']?.toString() ??
          json['return_time_str']?.toString() ??
          json['return_departure_time']?.toString();
      if (returnTime == 'null' || returnTime == '00:00' || returnTime == '00:00:00') {
        returnTime = null;
      }
      parcelCompleteTime = json['parcel_complete_time'];
      isCarpool = json['is_carpool'] == true || json['is_carpool'] == 1;
      distanceTexttt = json['distance_text']?.toString();
      isReturnTrip = json['is_return_trip'] == true ||
          json['is_return_trip'] == 1 ||
          json['is_return_trip'] == '1' ||
          json['is_return_trip'] == 'true' ||
          json['has_return_ride'] == true ||
          (returnTime != null && returnTime!.trim().isNotEmpty);
      if (json['excluded_weekdays'] is List) {
        excludedWeekdays = (json['excluded_weekdays'] as List)
            .map((e) => int.tryParse(e.toString()) ?? -1)
            .where((e) => e >= 0)
            .toList();
      }
      if (json['seats_count'] != null) {
        seatsCount = int.tryParse(json['seats_count'].toString());
      }
      paymentResponsibility = json['payment_responsibility']?.toString();

      hasReturnLeg = json['has_return_leg'] == true || json['has_return_leg'] == 1;
      currentTripLeg = json['current_trip_leg']?.toString();
      effectiveTripLeg = json['effective_trip_leg']?.toString();
      canStartOutbound = json['can_start_outbound'] == true;
      canStartReturn = json['can_start_return'] == true;
      isReturnPending = json['is_return_pending'] == true;

      if (json['co_passengers'] != null && json['co_passengers'] is List) {
        coPassengers = (json['co_passengers'] as List)
            .map((e) => Driver.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (json['emergency_contact'] != null &&
          json['emergency_contact'] is Map) {
        emergencyContact = EmergencyContact.fromJson(
            Map<String, dynamic>.from(json['emergency_contact']));
      }

      if (coPassengers == null || coPassengers!.isEmpty) {
        if (json['scheduled_passengers'] is List &&
            (json['scheduled_passengers'] as List).isNotEmpty) {
          coPassengers ??= [];
          for (var p in json['scheduled_passengers']) {
            if (p is Map) {
              coPassengers!.add(Driver(
                id: p['id']?.toString() ?? p['user_id']?.toString(),
                name: p['name']?.toString() ?? p['user']?['name']?.toString(),
                phone:
                    p['phone']?.toString() ?? p['user']?['phone']?.toString(),
              ));
            }
          }
        } else if (json['additional_passengers'] is List &&
            (json['additional_passengers'] as List).isNotEmpty) {
          coPassengers ??= [];
          for (var p in json['additional_passengers']) {
            if (p is Map) {
              coPassengers!.add(Driver(
                name: p['name']?.toString(),
                phone: p['phone']?.toString(),
              ));
            }
          }
        }
      }

      print('=== TripDetails.fromJson completed successfully ===');
    } catch (e) {
      print('=== Error in TripDetails.fromJson: $e ===');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  PickupCoordinates? _parseCoordinates(dynamic value) {
    if (value == null) return null;
    if (value is PickupCoordinates) return value;
    if (value is Map<String, dynamic>) {
      return PickupCoordinates.fromJson(value);
    }
    if (value is Map) {
      return PickupCoordinates.fromJson(Map<String, dynamic>.from(value));
    }
    if (value is List && value.length >= 2) {
      final a = (value[0] as num).toDouble();
      final b = (value[1] as num).toDouble();
      final corrected = MapBoundHelper.toCorrectLatLng(a, b);
      return PickupCoordinates(
        coordinates: [corrected.longitude, corrected.latitude],
      );
    }
    return null;
  }
}

class Driver {
  String? id;
  String? name;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? identificationNumber;
  String? identificationType;
  String? profileImage;
  double? rating;
  Vehicle? vehicle;
  CarpoolRideLocation? lastLocations;

  String get displayName {
    if (name != null && name!.trim().isNotEmpty) {
      return name!.trim();
    }
    final fn = firstName ?? '';
    final ln = lastName ?? '';
    final combined = '$fn $ln'.trim();
    return combined.isNotEmpty ? combined : '';
  }

  Driver(
      {this.id,
      this.name,
      this.firstName,
      this.lastName,
      this.email,
      this.phone,
      this.identificationNumber,
      this.identificationType,
      this.profileImage,
      this.rating,
      this.vehicle,
      this.lastLocations});

  Driver.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    firstName = json['first_name']?.toString();
    lastName = json['last_name']?.toString();
    if (name != null &&
        name!.trim().isNotEmpty &&
        (firstName == null || firstName!.isEmpty)) {
      var parts = name!.trim().split(' ');
      firstName = parts.isNotEmpty ? parts.first : '';
      lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }
    email = json['email']?.toString();
    phone = json['phone']?.toString();
    identificationNumber = json['identification_number']?.toString();
    identificationType = json['identification_type']?.toString();
    profileImage = (json['profile_image']?.toString() ?? '');
    rating = json['rating'] != null
        ? double.tryParse(json['rating'].toString())
        : null;
    vehicle =
        json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null;
    if (json['last_locations'] != null) {
      lastLocations = CarpoolRideLocation.fromJson(json['last_locations']);
    } else if (json['last_location'] != null) {
      lastLocations = CarpoolRideLocation.fromJson(json['last_location']);
    } else if (json['location'] != null) {
      lastLocations = CarpoolRideLocation.fromJson(json['location']);
    }
  }
}

class Vehicle {
  Model? model;
  String? brand;
  String? licencePlateNumber;
  String? licenceExpireDate;
  String? vinNumber;
  String? transmission;
  String? fuelType;
  String? ownership;
  List<String>? documents;
  int? isActive;
  String? createdAt;
  String? vehicleColor;

  String get displayName {
    final b = brand ?? model?.brand ?? '';
    final m = model?.name ?? '';
    final combined = '$b $m'.trim();
    if (combined.isNotEmpty) return combined;
    return licencePlateNumber ?? '';
  }

  Vehicle(
      {this.model,
      this.brand,
      this.licencePlateNumber,
      this.licenceExpireDate,
      this.vinNumber,
      this.transmission,
      this.fuelType,
      this.ownership,
      this.documents,
      this.isActive,
      this.vehicleColor,
      this.createdAt});

  Vehicle.fromJson(Map<String, dynamic> json) {
    if (json['model'] is Map<String, dynamic>) {
      model = Model.fromJson(json['model']);
    } else if (json['model'] is String) {
      model = Model(name: json['model'], brand: json['brand']?.toString());
    }
    brand = json['brand']?.toString() ?? model?.brand;
    licencePlateNumber = json['licence_plate_number']?.toString();
    licenceExpireDate = json['licence_expire_date']?.toString();
    vinNumber = json['vin_number']?.toString();
    transmission = json['transmission']?.toString();
    fuelType = json['fuel_type']?.toString();
    ownership = json['ownership']?.toString();
    documents = json['documents']?.cast<String>();
    isActive = json['is_active'] != null
        ? (json['is_active'] is bool
            ? (json['is_active'] ? 1 : 0)
            : int.tryParse(json['is_active'].toString()))
        : null;
    createdAt = json['created_at']?.toString();
    vehicleColor = json['parcel_weight_capacity']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (model != null) {
      data['model'] = model!.toJson();
    }
    data['brand'] = brand;
    data['licence_plate_number'] = licencePlateNumber;
    data['licence_expire_date'] = licenceExpireDate;
    data['vin_number'] = vinNumber;
    data['transmission'] = transmission;
    data['fuel_type'] = fuelType;
    data['ownership'] = ownership;
    data['documents'] = documents;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['parcel_weight_capacity'] = vehicleColor;
    return data;
  }
}

class Model {
  String? id;
  String? name;
  String? brand;
  int? seatCapacity;
  int? maximumWeight;
  int? hatchBagCapacity;
  String? engine;
  String? description;
  String? image;
  int? isActive;
  String? createdAt;

  Model(
      {this.id,
      this.name,
      this.brand,
      this.seatCapacity,
      this.maximumWeight,
      this.hatchBagCapacity,
      this.engine,
      this.description,
      this.image,
      this.isActive,
      this.createdAt});

  Model.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    brand = json['brand']?.toString();
    seatCapacity = json['seat_capacity'] != null
        ? int.tryParse(json['seat_capacity'].toString())
        : null;
    maximumWeight = json['maximum_weight'] != null
        ? int.tryParse(json['maximum_weight'].toString())
        : null;
    hatchBagCapacity = json['hatch_bag_capacity'] != null
        ? int.tryParse(json['hatch_bag_capacity'].toString())
        : null;
    engine = json['engine']?.toString();
    description = json['description']?.toString();
    image = json['image']?.toString();
    isActive = json['is_active'] != null
        ? (json['is_active'] is bool
            ? (json['is_active'] ? 1 : 0)
            : int.tryParse(json['is_active'].toString()))
        : null;
    createdAt = json['created_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['seat_capacity'] = seatCapacity;
    data['maximum_weight'] = maximumWeight;
    data['hatch_bag_capacity'] = hatchBagCapacity;
    data['engine'] = engine;
    data['description'] = description;
    data['image'] = image;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    return data;
  }
}

class PickupCoordinates {
  String? type;
  List<double>? coordinates;

  PickupCoordinates({this.type, this.coordinates});

  PickupCoordinates.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['latitude'] != null && json['longitude'] != null) {
      double lat = (json['latitude'] as num).toDouble();
      double lng = (json['longitude'] as num).toDouble();
      coordinates = [lng, lat];
    } else if (json['coordinates'] != null) {
      coordinates = (json['coordinates'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList();
    } else {
      coordinates = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['coordinates'] = coordinates;
    return data;
  }
}

class ParcelInformation {
  String? parcelCategoryId;
  String? parcelCategoryName;
  String? payer;
  double? weight;

  ParcelInformation(
      {this.parcelCategoryId,
      this.payer,
      this.weight,
      this.parcelCategoryName});

  ParcelInformation.fromJson(Map<String, dynamic> json) {
    parcelCategoryId = json['parcel_category_id'];
    parcelCategoryName = json['parcel_category_name'];
    payer = json['payer'];
    weight = json['weight'].toDouble();
  }
}

class VehicleCategory {
  String? id;
  String? name;
  String? image;
  String? type;

  VehicleCategory({this.id, this.name, this.image, this.type});

  VehicleCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    type = json['type'];
  }
}

class ParcelRefund {
  List<Attachments>? attachments;
  String? readableId;
  double? parcelApproximatePrice;
  String? reason;
  RefundStatus? status;
  String? approvalNote;
  String? denyNote;
  String? note;
  double? refundAmountByAdmin;
  String? refundMethod;
  String? customerNote;
  bool? isCouponUsed;

  ParcelRefund(
      {this.attachments,
      this.readableId,
      this.parcelApproximatePrice,
      this.reason,
      this.status,
      this.approvalNote,
      this.denyNote,
      this.note,
      this.refundAmountByAdmin,
      this.refundMethod,
      this.customerNote,
      this.isCouponUsed});

  ParcelRefund.fromJson(Map<String, dynamic> json) {
    if (json['attachments'] != null) {
      attachments = <Attachments>[];
      json['attachments'].forEach((v) {
        attachments!.add(Attachments.fromJson(v));
      });
    }
    readableId = json['readable_id'];
    parcelApproximatePrice = json['parcel_approximate_price'].toDouble();
    reason = json['reason'];
    status = _getStatusType(json['status']);
    approvalNote = json['approval_note'];
    denyNote = json['deny_note'];
    note = json['note'];
    refundAmountByAdmin = json['refund_amount_by_admin'].toDouble();
    refundMethod = json['refund_method'];
    customerNote = json['customer_note'];
    isCouponUsed = json['coupon_setup_used'];
  }
}

RefundStatus _getStatusType(String value) {
  switch (value) {
    case 'pending':
      {
        return RefundStatus.pending;
      }
    case 'refunded':
      {
        return RefundStatus.refunded;
      }
    case 'denied':
      {
        return RefundStatus.denied;
      }
    default:
      {
        return RefundStatus.approved;
      }
  }
}

class Attachments {
  String? file;

  Attachments({this.file});

  Attachments.fromJson(Map<String, dynamic> json) {
    file = json['file'];
  }
}

class CarpoolRideLocation {
  double? latitude;
  double? longitude;
  String? address;
  String? name;

  CarpoolRideLocation({
    this.latitude,
    this.longitude,
    this.address,
    this.name,
  });

  CarpoolRideLocation.fromJson(dynamic json) {
    if (json is Map) {
      latitude = _parseCoordinate(json['latitude'] ?? json['lat'] ?? json['latitud']);
      longitude = _parseCoordinate(json['longitude'] ?? json['lng'] ?? json['long'] ?? json['lon']);
      address = json['address']?.toString() ??
          json['name']?.toString() ??
          json['location_name']?.toString() ??
          json['formatted_address']?.toString() ??
          json['title']?.toString();
      name = json['name']?.toString() ?? json['title']?.toString();
      if ((latitude == null || longitude == null) &&
          json['coordinates'] != null &&
          json['coordinates'] is List &&
          (json['coordinates'] as List).length >= 2) {
        final a = ((json['coordinates'] as List)[0] as num).toDouble();
        final b = ((json['coordinates'] as List)[1] as num).toDouble();
        final corrected = MapBoundHelper.toCorrectLatLng(a, b);
        latitude = corrected.latitude;
        longitude = corrected.longitude;
      }
    } else if (json is List && json.length >= 2) {
      final a = (json[0] as num).toDouble();
      final b = (json[1] as num).toDouble();
      final corrected = MapBoundHelper.toCorrectLatLng(a, b);
      latitude = corrected.latitude;
      longitude = corrected.longitude;
    }
  }

  static double? _parseCoordinate(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class EmergencyContact {
  String? name;
  String? phone;

  EmergencyContact({this.name, this.phone});

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
    };
  }
}

class TripLocationItem {
  String? address;
  double? latitude;
  double? longitude;

  TripLocationItem({
    this.address,
    this.latitude,
    this.longitude,
  });

  factory TripLocationItem.fromJson(dynamic json) {
    if (json is! Map) return TripLocationItem();

    double? lat = CarpoolRideLocation._parseCoordinate(
        json['latitude'] ?? json['lat'] ?? json['latitud'] ?? json['pickup_latitude'] ?? json['destination_latitude']);
    double? lng = CarpoolRideLocation._parseCoordinate(
        json['longitude'] ?? json['lng'] ?? json['long'] ?? json['lon'] ?? json['pickup_longitude'] ?? json['destination_longitude']);

    if ((lat == null || lng == null) && json['coordinates'] != null) {
      final coords = json['coordinates'];
      if (coords is List && coords.length >= 2) {
        lng ??= CarpoolRideLocation._parseCoordinate(coords[0]);
        lat ??= CarpoolRideLocation._parseCoordinate(coords[1]);
      } else if (coords is Map) {
        lat ??= CarpoolRideLocation._parseCoordinate(coords['latitude'] ?? coords['lat']);
        lng ??= CarpoolRideLocation._parseCoordinate(coords['longitude'] ?? coords['lng'] ?? coords['long']);
      }
    }

    if ((lat == null || lng == null) && json['location'] is Map) {
      final loc = json['location'] as Map;
      lat ??= CarpoolRideLocation._parseCoordinate(loc['latitude'] ?? loc['lat']);
      lng ??= CarpoolRideLocation._parseCoordinate(loc['longitude'] ?? loc['lng'] ?? loc['long']);
    }

    if ((lat == null || lng == null) && json['point'] is Map) {
      final pt = json['point'] as Map;
      lat ??= CarpoolRideLocation._parseCoordinate(pt['latitude'] ?? pt['lat']);
      lng ??= CarpoolRideLocation._parseCoordinate(pt['longitude'] ?? pt['lng'] ?? pt['long']);
    }

    if (lat != null && lng != null && (lat != 0.0 || lng != 0.0)) {
      final corrected = MapBoundHelper.toCorrectLatLng(lat, lng);
      lat = corrected.latitude;
      lng = corrected.longitude;
    }

    return TripLocationItem(
      address: json['address']?.toString() ??
          json['name']?.toString() ??
          json['location_name']?.toString() ??
          json['formatted_address']?.toString() ??
          json['title']?.toString(),
      latitude: lat,
      longitude: lng,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
