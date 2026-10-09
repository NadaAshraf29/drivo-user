import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/domain/models/passenger_model.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/domain/models/special_trip_fare_model.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/domain/models/trip_location_point.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';

enum SpecialTripStatus {
  pending,
  accepted,
  waitingForPayment,
  paid,
  confirmed,
  cancelled,
  expired,
  completed;

  String get readableName {
    switch (this) {
      case SpecialTripStatus.pending:
        return 'Pending Driver';
      case SpecialTripStatus.accepted:
        return 'Driver Accepted';
      case SpecialTripStatus.waitingForPayment:
        return 'Waiting for Payment';
      case SpecialTripStatus.paid:
        return 'Paid';
      case SpecialTripStatus.confirmed:
        return 'Confirmed';
      case SpecialTripStatus.cancelled:
        return 'Cancelled';
      case SpecialTripStatus.expired:
        return 'Expired';
      case SpecialTripStatus.completed:
        return 'Completed';
    }
  }

  Color get statusColor {
    switch (this) {
      case SpecialTripStatus.pending:
        return const Color(0xFFF59E0B);
      case SpecialTripStatus.accepted:
        return const Color(0xFF0284C7);
      case SpecialTripStatus.waitingForPayment:
        return const Color(0xFFEA580C);
      case SpecialTripStatus.paid:
      case SpecialTripStatus.confirmed:
      case SpecialTripStatus.completed:
        return const Color(0xFF16A34A);
      case SpecialTripStatus.cancelled:
      case SpecialTripStatus.expired:
        return const Color(0xFFDC2626);
    }
  }
}

class SpecialTripDriverModel {
  final String id;
  final String name;
  final String phone;
  final String? avatar;
  final double rating;
  final String vehicleName;
  final String licensePlate;
  final double? latitude;
  final double? longitude;

  SpecialTripDriverModel({
    required this.id,
    required this.name,
    required this.phone,
    this.avatar,
    this.rating = 4.9,
    required this.vehicleName,
    required this.licensePlate,
    this.latitude,
    this.longitude,
  });

  factory SpecialTripDriverModel.fromJson(Map<String, dynamic> json) {
    return SpecialTripDriverModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Driver',
      phone: json['phone']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? json['profile_image']?.toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      vehicleName: json['vehicle_name']?.toString() ?? 'Toyota Corolla - White',
      licensePlate: json['license_plate']?.toString() ?? 'ABC 1234',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      if (avatar != null) 'avatar': avatar,
      'rating': rating,
      'vehicle_name': vehicleName,
      'license_plate': licensePlate,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}

class SpecialTripRequestModel {
  final String id;
  final String? refId;
  final String? customerId;
  final String? type;
  final String? currentStatus;
  final String paymentStatus;
  final List<TripLocationPoint> pickupPoints;
  final List<TripLocationPoint> destinationPoints;
  final DateTime startDate;
  final DateTime endDate;
  final List<int> operatingWeekdays;
  final TimeOfDay outboundTime;
  final bool hasReturnRide;
  final TimeOfDay? returnTime;
  final int seatsCount;
  final List<SpecialTripPassengerModel> passengers;
  final PaymentResponsibility paymentResponsibility;
  final SpecialTripFareModel? fare;
  SpecialTripStatus status;
  SpecialTripDriverModel? driver;
  DateTime? paymentExpiresAt;
  final DateTime createdAt;
  final double? estimatedFare;
  final double? driverNetFare;
  final List<String> activeDates;
  final String? otp;

  SpecialTripRequestModel({
    required this.id,
    this.refId,
    this.customerId,
    this.type,
    this.currentStatus,
    this.paymentStatus = 'unpaid',
    required this.pickupPoints,
    required this.destinationPoints,
    required this.startDate,
    required this.endDate,
    required this.operatingWeekdays,
    required this.outboundTime,
    this.hasReturnRide = false,
    this.returnTime,
    required this.seatsCount,
    required this.passengers,
    required this.paymentResponsibility,
    this.fare,
    this.status = SpecialTripStatus.pending,
    this.driver,
    this.paymentExpiresAt,
    DateTime? createdAt,
    this.estimatedFare,
    this.driverNetFare,
    this.activeDates = const [],
    this.otp,
  }) : createdAt = createdAt ?? DateTime.now();

  SpecialTripRequestModel copyWith({
    String? id,
    String? refId,
    String? customerId,
    String? type,
    String? currentStatus,
    String? paymentStatus,
    List<TripLocationPoint>? pickupPoints,
    List<TripLocationPoint>? destinationPoints,
    DateTime? startDate,
    DateTime? endDate,
    List<int>? operatingWeekdays,
    TimeOfDay? outboundTime,
    bool? hasReturnRide,
    TimeOfDay? returnTime,
    int? seatsCount,
    List<SpecialTripPassengerModel>? passengers,
    PaymentResponsibility? paymentResponsibility,
    SpecialTripFareModel? fare,
    SpecialTripStatus? status,
    SpecialTripDriverModel? driver,
    DateTime? paymentExpiresAt,
    DateTime? createdAt,
    double? estimatedFare,
    double? driverNetFare,
    List<String>? activeDates,
    String? otp,
  }) {
    return SpecialTripRequestModel(
      id: id ?? this.id,
      refId: refId ?? this.refId,
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      currentStatus: currentStatus ?? this.currentStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      pickupPoints: pickupPoints ?? this.pickupPoints,
      destinationPoints: destinationPoints ?? this.destinationPoints,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      operatingWeekdays: operatingWeekdays ?? this.operatingWeekdays,
      outboundTime: outboundTime ?? this.outboundTime,
      hasReturnRide: hasReturnRide ?? this.hasReturnRide,
      returnTime: returnTime ?? this.returnTime,
      seatsCount: seatsCount ?? this.seatsCount,
      passengers: passengers ?? this.passengers,
      paymentResponsibility:
          paymentResponsibility ?? this.paymentResponsibility,
      fare: fare ?? this.fare,
      status: status ?? this.status,
      driver: driver ?? this.driver,
      paymentExpiresAt: paymentExpiresAt ?? this.paymentExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      driverNetFare: driverNetFare ?? this.driverNetFare,
      activeDates: activeDates ?? this.activeDates,
      otp: otp ?? this.otp,
    );
  }

  int get totalTripDays {
    if (activeDates.isNotEmpty) return activeDates.length;
    if (fare != null && fare!.activeDates.isNotEmpty) {
      return fare!.activeDates.length;
    }
    if (fare != null && fare!.totalActiveDays > 0) {
      return fare!.totalActiveDays;
    }
    int count = 0;
    DateTime current = startDate;
    while (!current.isAfter(endDate)) {
      if (operatingWeekdays.isEmpty ||
          operatingWeekdays.contains(current.weekday)) {
        count++;
      }
      current = current.add(const Duration(days: 1));
    }
    return count > 0 ? count : 1;
  }

  List<int> get activeWeekdays {
    final dates =
        activeDates.isNotEmpty ? activeDates : (fare?.activeDates ?? []);
    if (dates.isNotEmpty) {
      final Set<int> set = {};
      for (var d in dates) {
        final dt = DateTime.tryParse(d.trim());
        if (dt != null) set.add(dt.weekday);
      }
      if (set.isNotEmpty) return set.toList()..sort();
    }
    return operatingWeekdays;
  }

  String? get rawStatus => currentStatus;

  static TimeOfDay? _parseTimeOfDay(dynamic raw) {
    if (raw == null) return null;
    final str = raw.toString().trim();
    if (str.isEmpty || str == 'null' || str == '00:00:00') return null;

    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(str);
    if (match != null) {
      int hour = int.tryParse(match.group(1)!) ?? 0;
      final int minute = int.tryParse(match.group(2)!) ?? 0;
      final lower = str.toLowerCase();
      if (lower.contains('pm') && hour < 12) {
        hour += 12;
      } else if (lower.contains('am') && hour == 12) {
        hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    }
    return null;
  }

  factory SpecialTripRequestModel.fromJson(
    Map<String, dynamic> json, {
    SpecialTripRequestModel? fallback,
  }) {
    // Unwrap nested response if present
    Map<String, dynamic> data = json;
    if (json['trip'] is Map<String, dynamic>) {
      data = json['trip'];
    } else if (json['subscription'] is Map<String, dynamic>) {
      data = json['subscription'];
    } else if (json['scheduled_ride'] is Map<String, dynamic>) {
      data = json['scheduled_ride'];
    } else if (json['ride_request'] is Map<String, dynamic>) {
      data = json['ride_request'];
    } else if (json['ride'] is Map<String, dynamic>) {
      data = json['ride'];
    }

    SpecialTripStatus status = SpecialTripStatus.pending;
    final statusStr =
        (data['current_status'] ?? data['status'])?.toString().toLowerCase();
    if (statusStr == 'accepted_pending_payment') {
      status = SpecialTripStatus.waitingForPayment;
    } else if (statusStr == 'pending') {
      status = SpecialTripStatus.pending;
    } else if (statusStr == 'accepted' || statusStr == 'driver_assigned') {
      status = SpecialTripStatus.accepted;
    } else if (statusStr == 'confirmed' || statusStr == 'paid') {
      status = SpecialTripStatus.confirmed;
    } else if (statusStr == 'cancelled') {
      status = SpecialTripStatus.cancelled;
    } else if (statusStr == 'expired') {
      status = SpecialTripStatus.expired;
    } else if (statusStr == 'completed') {
      status = SpecialTripStatus.completed;
    } else if (statusStr != null) {
      for (var s in SpecialTripStatus.values) {
        if (s.name.toLowerCase() == statusStr ||
            s.readableName.toLowerCase() == statusStr) {
          status = s;
          break;
        }
      }
    } else if (fallback != null) {
      status = fallback.status;
    }

    PaymentResponsibility responsibility = PaymentResponsibility.creatorPays;
    final respStr = data['payment_responsibility']?.toString().toLowerCase();
    if (respStr == 'eachpassengerpays' ||
        respStr == 'each_passenger_pays' ||
        respStr == 'split_equally' ||
        respStr == 'split') {
      responsibility = PaymentResponsibility.eachPassengerPays;
    } else if (respStr == 'creator_only' ||
        respStr == 'creatoronly' ||
        respStr == 'creator_pays') {
      responsibility = PaymentResponsibility.creatorPays;
    } else if (fallback != null) {
      responsibility = fallback.paymentResponsibility;
    }

    List<TripLocationPoint> pPoints = [];
    List<TripLocationPoint> dPoints = [];

    if (data['stops'] is List && (data['stops'] as List).isNotEmpty) {
      final List stopsList = List.from(data['stops'] as List);
      stopsList.sort((a, b) {
        final orderA =
            (a is Map ? (a['sort_order'] as num?)?.toInt() : null) ?? 0;
        final orderB =
            (b is Map ? (b['sort_order'] as num?)?.toInt() : null) ?? 0;
        return orderA.compareTo(orderB);
      });

      for (var s in stopsList) {
        if (s is Map<String, dynamic>) {
          final stopType = s['stop_type']?.toString().toLowerCase() ?? 'pickup';
          final point = TripLocationPoint.fromStop(s);
          if (stopType == 'destination') {
            dPoints.add(point);
          } else {
            pPoints.add(point);
          }
        }
      }
    } else {
      final rawPickups =
          (data['pickup_points'] ?? data['pickup_locations']) as List?;
      if (rawPickups != null) {
        for (var e in rawPickups) {
          if (e is Map<String, dynamic>) {
            pPoints.add(TripLocationPoint.fromJson(e));
          }
        }
      }
      final rawDests = (data['destination_points'] ??
          data['destination_locations']) as List?;
      if (rawDests != null) {
        for (var e in rawDests) {
          if (e is Map<String, dynamic>) {
            dPoints.add(TripLocationPoint.fromJson(e));
          }
        }
      }
    }

    if (pPoints.isEmpty) {
      final startAddr =
          (data['start_address'] ?? data['pickup_address'])?.toString().trim();
      if (startAddr != null && startAddr.isNotEmpty) {
        pPoints.add(TripLocationPoint(
          id: 'start_0',
          name: startAddr,
          address: startAddr,
          latitude: 30.0444,
          longitude: 31.2357,
          type: TripLocationType.pickup,
          order: 1,
        ));
      }
    }
    if (dPoints.isEmpty) {
      final endAddr = (data['end_address'] ?? data['destination_address'])
          ?.toString()
          .trim();
      if (endAddr != null && endAddr.isNotEmpty) {
        dPoints.add(TripLocationPoint(
          id: 'dest_0',
          name: endAddr,
          address: endAddr,
          latitude: 30.0444,
          longitude: 31.2357,
          type: TripLocationType.destination,
          order: 1,
        ));
      }
    }

    if (pPoints.isEmpty &&
        fallback != null &&
        fallback.pickupPoints.isNotEmpty) {
      pPoints = List.from(fallback.pickupPoints);
    }
    if (dPoints.isEmpty &&
        fallback != null &&
        fallback.destinationPoints.isNotEmpty) {
      dPoints = List.from(fallback.destinationPoints);
    }

    List<SpecialTripPassengerModel> passList = [];
    final rawSchedPass = data['scheduled_passengers'] ?? data['co_passengers'];
    if (rawSchedPass is List && rawSchedPass.isNotEmpty) {
      for (var sp in rawSchedPass) {
        if (sp is Map<String, dynamic>) {
          passList.add(SpecialTripPassengerModel.fromScheduledPassenger(sp));
        }
      }
    } else if (data['passengers'] is List &&
        (data['passengers'] as List).isNotEmpty) {
      for (var p in data['passengers']) {
        if (p is Map<String, dynamic>) {
          passList.add(SpecialTripPassengerModel.fromJson(p));
        }
      }
    } else if (data['additional_passengers'] is List &&
        (data['additional_passengers'] as List).isNotEmpty) {
      for (var p in data['additional_passengers']) {
        if (p is Map<String, dynamic>) {
          passList.add(SpecialTripPassengerModel.fromJson(p));
        }
      }
    } else if (fallback != null && fallback.passengers.isNotEmpty) {
      passList = List.from(fallback.passengers);
    }

    List<int> weekdays = [];
    final excludedRaw = data['excluded_weekdays'];
    if (excludedRaw is List && excludedRaw.isNotEmpty) {
      final excluded = <int>{};
      for (var e in excludedRaw) {
        final val = int.tryParse(e.toString());
        if (val != null) excluded.add(val);
      }
      weekdays =
          [1, 2, 3, 4, 5, 6, 7].where((d) => !excluded.contains(d)).toList();
    } else {
      final opDaysRaw =
          data['operating_weekdays'] ?? data['days_of_week'] ?? data['days'];
      if (opDaysRaw is List && opDaysRaw.isNotEmpty) {
        final Map<String, int> dayNameToNum = {
          'mon': 1,
          'monday': 1,
          'tue': 2,
          'tuesday': 2,
          'wed': 3,
          'wednesday': 3,
          'thu': 4,
          'thursday': 4,
          'fri': 5,
          'friday': 5,
          'sat': 6,
          'saturday': 6,
          'sun': 7,
          'sunday': 7,
        };
        for (var e in opDaysRaw) {
          final str = e.toString().toLowerCase().trim();
          final numVal = int.tryParse(str);
          if (numVal != null && numVal >= 1 && numVal <= 7) {
            if (!weekdays.contains(numVal)) weekdays.add(numVal);
          } else if (dayNameToNum.containsKey(str)) {
            final mapped = dayNameToNum[str]!;
            if (!weekdays.contains(mapped)) weekdays.add(mapped);
          }
        }
      }
    }
    if (weekdays.isEmpty &&
        fallback != null &&
        fallback.operatingWeekdays.isNotEmpty) {
      weekdays = List.from(fallback.operatingWeekdays);
    }

    final List<String> activeDatesList = [];
    final rawDates = data['active_dates'] ??
        data['operating_dates'] ??
        data['explicit_operating_dates'] ??
        data['working_dates'] ??
        data['trip_dates'] ??
        data['dates'] ??
        data['selected_dates'];
    if (rawDates is List) {
      for (var d in rawDates) {
        if (d != null && d.toString().trim().isNotEmpty) {
          activeDatesList.add(d.toString().trim());
        }
      }
    }
    if (activeDatesList.isEmpty &&
        fallback != null &&
        fallback.activeDates.isNotEmpty) {
      activeDatesList.addAll(fallback.activeDates);
    }

    final startStr = (data['start_date'] ??
            data['start_at'] ??
            data['start'] ??
            data['scheduled_date'] ??
            data['first_date'] ??
            data['date'])
        ?.toString();
    final endStr =
        (data['end_date'] ?? data['end_at'] ?? data['end'] ?? data['last_date'])
            ?.toString();

    DateTime? parsedStartDate;
    if (startStr != null && startStr.isNotEmpty && startStr != 'null') {
      parsedStartDate = DateTime.tryParse(startStr);
    }
    if (parsedStartDate == null && activeDatesList.isNotEmpty) {
      parsedStartDate = DateTime.tryParse(activeDatesList.first);
    }
    if (parsedStartDate == null && fallback != null) {
      parsedStartDate = fallback.startDate;
    }

    DateTime? parsedEndDate;
    if (endStr != null && endStr.isNotEmpty && endStr != 'null') {
      parsedEndDate = DateTime.tryParse(endStr);
    }
    if (parsedEndDate == null && activeDatesList.isNotEmpty) {
      parsedEndDate = DateTime.tryParse(activeDatesList.last);
    }
    if (parsedEndDate == null && fallback != null) {
      parsedEndDate = fallback.endDate;
    }

    final rawSeats = data['seats_count'] ??
        data['seats'] ??
        data['required_seats'] ??
        data['total_seats'] ??
        data['passengers_count'];
    int? parsedSeats;
    if (rawSeats is num) {
      parsedSeats = rawSeats.toInt();
    } else if (rawSeats != null &&
        rawSeats.toString().trim().isNotEmpty &&
        rawSeats.toString() != 'null') {
      parsedSeats = int.tryParse(rawSeats.toString().trim());
    }
    if ((parsedSeats == null || parsedSeats <= 0) && fallback != null) {
      parsedSeats = fallback.seatsCount;
    }

    TimeOfDay? parsedOutboundTime = _parseTimeOfDay(data['start_time'] ??
        data['outbound_time'] ??
        data['pickup_time'] ??
        data['requested_pickup_time']);
    if (parsedOutboundTime == null && fallback != null) {
      parsedOutboundTime = fallback.outboundTime;
    }

    TimeOfDay? parsedReturnTime = _parseTimeOfDay(data['return_time'] ??
        data['return_trip_time'] ??
        data['evening_time']);
    if (parsedReturnTime == null && fallback != null) {
      parsedReturnTime = fallback.returnTime;
    }

    bool? parsedHasReturn;
    if (data.containsKey('is_return_trip') ||
        data.containsKey('has_return_ride') ||
        data.containsKey('return_ride')) {
      parsedHasReturn = data['is_return_trip'] == true ||
          data['is_return_trip'] == 1 ||
          data['is_return_trip'] == '1' ||
          data['is_return_trip'] == 'true' ||
          data['has_return_ride'] == true ||
          data['has_return_ride'] == 1 ||
          data['has_return_ride'] == '1' ||
          data['return_ride'] == 1 ||
          data['return_ride'] == '1' ||
          data['return_ride'] == true;
    }
    if (parsedHasReturn == null && parsedReturnTime != null) {
      parsedHasReturn = true;
    }
    if (parsedHasReturn == null && fallback != null) {
      parsedHasReturn = fallback.hasReturnRide;
    }

    final String parsedId = (data['id'] ??
                data['trip_request_id'] ??
                data['trip_id'] ??
                data['ride_id'] ??
                data['subscription_id'])
            ?.toString() ??
        (fallback?.id ?? '');

    final String? parsedRef = (data['ref_id'] ??
                data['reference_id'] ??
                data['request_number'] ??
                data['ref'] ??
                data['trip_ref'])
            ?.toString() ??
        fallback?.refId;

    // Fare parsing
    SpecialTripFareModel? fareModel;
    if (data['fare'] is Map<String, dynamic>) {
      fareModel = SpecialTripFareModel.fromJson(data['fare']);
    } else if (data['estimated_fare'] != null) {
      final double estFare =
          (double.tryParse(data['estimated_fare'].toString())) ?? 0.0;
      fareModel = SpecialTripFareModel(
        baseFare: estFare,
        totalFare: estFare,
        driverNetFare:
            (double.tryParse(data['driver_net_fare']?.toString() ?? '')) ??
                estFare,
        totalActiveDays: weekdays.isNotEmpty ? weekdays.length : 1,
        activeDates: activeDatesList,
        creatorAmount: estFare,
        passengerAmount: estFare,
      );
    } else if (fallback?.fare != null) {
      fareModel = fallback!.fare;
    }

    if (activeDatesList.isEmpty &&
        fareModel != null &&
        fareModel.activeDates.isNotEmpty) {
      activeDatesList.addAll(fareModel.activeDates);
    }

    final expStr =
        (data['payment_expires_at'] ?? data['expires_at'])?.toString();
    final driverData = data['driver'] ?? data['assigned_driver'];
    final parsedOtp = (data['otp'] ??
            data['otp_key'] ??
            data['start_otp'] ??
            data['pin'] ??
            data['key'] ??
            data['start_trip_otp'] ??
            data['verification_code'] ??
            (data['trip_request'] is Map ? data['trip_request']['otp'] : null) ??
            (data['ride_request'] is Map ? data['ride_request']['otp'] : null) ??
            (data['subscription'] is Map ? data['subscription']['otp'] : null) ??
            fallback?.otp)
        ?.toString();

    return SpecialTripRequestModel(
      id: parsedId,
      refId: parsedRef,
      customerId: (data['customer_id'] ?? data['user_id'])?.toString() ??
          fallback?.customerId,
      type: data['type']?.toString() ?? fallback?.type,
      currentStatus: data['current_status']?.toString() ?? statusStr,
      paymentStatus: data['payment_status']?.toString() ??
          (fallback?.paymentStatus ?? 'unpaid'),
      pickupPoints: pPoints,
      destinationPoints: dPoints,
      startDate: parsedStartDate ?? DateTime.now(),
      endDate: parsedEndDate ?? (parsedStartDate ?? DateTime.now()),
      operatingWeekdays: weekdays,
      outboundTime: parsedOutboundTime ?? const TimeOfDay(hour: 8, minute: 0),
      hasReturnRide: parsedHasReturn ?? false,
      returnTime: (parsedHasReturn == true) ? parsedReturnTime : null,
      seatsCount: (parsedSeats != null && parsedSeats > 0) ? parsedSeats : 1,
      passengers: passList,
      paymentResponsibility: responsibility,
      fare: fareModel,
      status: status,
      driver: driverData is Map<String, dynamic>
          ? SpecialTripDriverModel.fromJson(driverData)
          : fallback?.driver,
      paymentExpiresAt: expStr != null
          ? DateTime.tryParse(expStr)
          : fallback?.paymentExpiresAt,
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'].toString())
          : (fallback?.createdAt ?? DateTime.now()),
      estimatedFare:
          (double.tryParse(data['estimated_fare']?.toString() ?? '')) ??
              fallback?.estimatedFare,
      driverNetFare:
          (double.tryParse(data['driver_net_fare']?.toString() ?? '')) ??
              fallback?.driverNetFare,
      activeDates: activeDatesList,
      otp: parsedOtp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (refId != null) 'ref_id': refId,
      if (customerId != null) 'customer_id': customerId,
      if (type != null) 'type': type,
      if (currentStatus != null) 'current_status': currentStatus,
      'payment_status': paymentStatus,
      'pickup_points': pickupPoints.map((e) => e.toJson()).toList(),
      'destination_points': destinationPoints.map((e) => e.toJson()).toList(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'operating_weekdays': operatingWeekdays,
      'outbound_time':
          '${outboundTime.hour.toString().padLeft(2, '0')}:${outboundTime.minute.toString().padLeft(2, '0')}',
      'has_return_ride': hasReturnRide,
      if (returnTime != null)
        'return_time':
            '${returnTime!.hour.toString().padLeft(2, '0')}:${returnTime!.minute.toString().padLeft(2, '0')}',
      'seats_count': seatsCount,
      'passengers': passengers.map((e) => e.toJson()).toList(),
      'payment_responsibility':
          paymentResponsibility == PaymentResponsibility.creatorPays
              ? 'creator_only'
              : 'split',
      if (fare != null) 'fare': fare!.toJson(),
      'status': status.name,
      if (driver != null) 'driver': driver!.toJson(),
      if (paymentExpiresAt != null)
        'payment_expires_at': paymentExpiresAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      if (estimatedFare != null) 'estimated_fare': estimatedFare,
      if (driverNetFare != null) 'driver_net_fare': driverNetFare,
      if (activeDates.isNotEmpty) 'active_dates': activeDates,
      if (otp != null) 'otp': otp,
    };
  }

  factory SpecialTripRequestModel.fromTripDetails(TripDetails trip) {
    final st = (trip.currentStatus ?? '').toLowerCase();
    SpecialTripStatus status = SpecialTripStatus.pending;
    if (st == 'accepted_pending_payment' ||
        st == 'waiting_for_payment' ||
        st == 'waiting_payment') {
      status = SpecialTripStatus.waitingForPayment;
    } else if (st == 'pending') {
      status = SpecialTripStatus.pending;
    } else if (st == 'accepted' ||
        st == 'driver_assigned' ||
        st == 'assigned') {
      final isPaid = trip.paymentStatus?.toLowerCase() == 'paid' ||
          (trip.paidFare != null && trip.paidFare! > 0);
      if (!isPaid && trip.driver != null) {
        status = SpecialTripStatus.waitingForPayment;
      } else {
        status = SpecialTripStatus.accepted;
      }
    } else if (st == 'confirmed' ||
        st == 'paid' ||
        st == 'completed' ||
        st == 'complete') {
      status = SpecialTripStatus.confirmed;
    } else if (st == 'cancelled' || st == 'canceled') {
      status = SpecialTripStatus.cancelled;
    } else if (st == 'expired') {
      status = SpecialTripStatus.expired;
    }

    final List<TripLocationPoint> pPoints = [];
    if (trip.pickupLocations != null && trip.pickupLocations!.isNotEmpty) {
      for (int i = 0; i < trip.pickupLocations!.length; i++) {
        final l = trip.pickupLocations![i];
        final rawLat = l.latitude ?? 30.0444;
        final rawLng = l.longitude ?? 31.2357;
        final corrected = MapBoundHelper.toCorrectLatLng(rawLat, rawLng);
        pPoints.add(TripLocationPoint(
          id: 'p_$i',
          name: l.address ?? 'Pickup',
          address: l.address ?? '',
          latitude: corrected.latitude,
          longitude: corrected.longitude,
          type: TripLocationType.pickup,
          order: i + 1,
        ));
      }
    } else if (trip.stops != null && trip.stops!.isNotEmpty) {
      int pIdx = 0;
      for (var s in trip.stops!) {
        final rawLat =
            s.location.latitude != 0.0 ? s.location.latitude : 30.0444;
        final rawLng =
            s.location.longitude != 0.0 ? s.location.longitude : 31.2357;
        final corrected = MapBoundHelper.toCorrectLatLng(rawLat, rawLng);
        pPoints.add(TripLocationPoint(
          id: s.id ?? 'p_${pIdx++}',
          name: s.name.isNotEmpty ? s.name : (s.address ?? 'Pickup'),
          address: s.address ?? s.name,
          latitude: corrected.latitude,
          longitude: corrected.longitude,
          type: TripLocationType.pickup,
          order: pIdx,
        ));
      }
    }
    if (pPoints.isEmpty) {
      final double rawPLat = trip.pickupLocations?.firstOrNull?.latitude ??
          trip.carpoolRideLocation?.latitude ??
          (trip.pickupCoordinates?.coordinates != null &&
                  trip.pickupCoordinates!.coordinates!.length >= 2
              ? trip.pickupCoordinates!.coordinates![1]
              : null) ??
          30.0444;
      final double rawPLng = trip.pickupLocations?.firstOrNull?.longitude ??
          trip.carpoolRideLocation?.longitude ??
          (trip.pickupCoordinates?.coordinates != null &&
                  trip.pickupCoordinates!.coordinates!.length >= 2
              ? trip.pickupCoordinates!.coordinates![0]
              : null) ??
          31.2357;
      final correctedP = MapBoundHelper.toCorrectLatLng(rawPLat, rawPLng);
      final pAddr = (trip.startAddress != null &&
              trip.startAddress!.trim().isNotEmpty &&
              !TripDetails.isGenericPlaceholder(trip.startAddress))
          ? trip.startAddress!.trim()
          : (trip.startAddressDisplay.isNotEmpty
              ? trip.startAddressDisplay
              : (trip.pickupAddress ?? 'Pickup Location'));
      pPoints.add(TripLocationPoint(
        id: 'p_0',
        name: pAddr,
        address: pAddr,
        latitude: correctedP.latitude,
        longitude: correctedP.longitude,
        type: TripLocationType.pickup,
        order: 1,
      ));
    }

    final List<TripLocationPoint> dPoints = [];
    if (trip.destinationLocations != null &&
        trip.destinationLocations!.isNotEmpty) {
      for (int i = 0; i < trip.destinationLocations!.length; i++) {
        final l = trip.destinationLocations![i];
        final rawLat = l.latitude ?? 30.0444;
        final rawLng = l.longitude ?? 31.2357;
        final corrected = MapBoundHelper.toCorrectLatLng(rawLat, rawLng);
        dPoints.add(TripLocationPoint(
          id: 'd_$i',
          name: l.address ?? 'Destination',
          address: l.address ?? '',
          latitude: corrected.latitude,
          longitude: corrected.longitude,
          type: TripLocationType.destination,
          order: i + 1,
        ));
      }
    }
    if (dPoints.isEmpty) {
      final double rawDLat = trip.destinationLocations?.firstOrNull?.latitude ??
          trip.carpoolDropoffLocation?.latitude ??
          (trip.destinationCoordinates?.coordinates != null &&
                  trip.destinationCoordinates!.coordinates!.length >= 2
              ? trip.destinationCoordinates!.coordinates![1]
              : null) ??
          30.0444;
      final double rawDLng =
          trip.destinationLocations?.firstOrNull?.longitude ??
              trip.carpoolDropoffLocation?.longitude ??
              (trip.destinationCoordinates?.coordinates != null &&
                      trip.destinationCoordinates!.coordinates!.length >= 2
                  ? trip.destinationCoordinates!.coordinates![0]
                  : null) ??
              31.2357;
      final correctedD = MapBoundHelper.toCorrectLatLng(rawDLat, rawDLng);
      final dAddr = (trip.endAddress != null &&
              trip.endAddress!.trim().isNotEmpty &&
              !TripDetails.isGenericPlaceholder(trip.endAddress))
          ? trip.endAddress!.trim()
          : (trip.endAddressDisplay.isNotEmpty
              ? trip.endAddressDisplay
              : (trip.destinationAddress ?? 'Destination'));
      dPoints.add(TripLocationPoint(
        id: 'd_0',
        name: dAddr,
        address: dAddr,
        latitude: correctedD.latitude,
        longitude: correctedD.longitude,
        type: TripLocationType.destination,
        order: 1,
      ));
    }

    SpecialTripDriverModel? driverModel;
    if (trip.driver != null) {
      final d = trip.driver!;
      driverModel = SpecialTripDriverModel(
        id: d.id ?? '',
        name: '${d.firstName ?? ''} ${d.lastName ?? ''}'.trim().isNotEmpty
            ? '${d.firstName ?? ''} ${d.lastName ?? ''}'.trim()
            : 'Driver',
        phone: d.phone ?? '',
        avatar: d.profileImage,
        rating: double.tryParse(trip.driverAvgRating ?? '4.9') ?? 4.9,
        vehicleName:
            '${trip.vehicle?.model?.name ?? 'Car'}${trip.vehicle?.vehicleColor != null ? ' - ${trip.vehicle!.vehicleColor}' : ''}',
        licensePlate: trip.vehicle?.licencePlateNumber ?? '',
        latitude: trip.lastLocation?.latitude,
        longitude: trip.lastLocation?.longitude,
      );
    }

    final double total = (trip.actualFare ??
            trip.estimatedFare ??
            trip.paidFare ??
            double.tryParse(trip.totalFare ?? '0') ??
            0.0)
        .toDouble();
    final int seats = trip.seatsCount ?? 1;
    final fareModel = SpecialTripFareModel(
      baseFare: total,
      totalFare: total,
      totalActiveDays:
          trip.totalSubscriptionDays > 0 ? trip.totalSubscriptionDays : 1,
      creatorAmount: total,
      passengerAmount: seats > 0 ? (total / seats) : total,
      seatsCount: seats,
      activeDates: trip.selectedDates ?? [],
      isReturnTrip: trip.isReturnTrip,
    );

    final startDt =
        DateTime.tryParse(trip.startDate ?? trip.date ?? '') ?? DateTime.now();
    final endDt = DateTime.tryParse(trip.endDate ?? '') ??
        startDt.add(const Duration(days: 30));
    final outTime = _parseTimeOfDay(trip.departureTime ??
            trip.pickupTime ??
            trip.startTime ??
            trip.time) ??
        const TimeOfDay(hour: 8, minute: 0);
    final retTime = _parseTimeOfDay(trip.returnTime);

    return SpecialTripRequestModel(
      id: trip.id ?? '',
      refId: trip.refId,
      customerId: null,
      type: trip.type,
      currentStatus: trip.currentStatus,
      paymentStatus: trip.paymentStatus ?? 'unpaid',
      pickupPoints: pPoints,
      destinationPoints: dPoints,
      startDate: startDt,
      endDate: endDt,
      operatingWeekdays:
          trip.excludedWeekdays != null && trip.excludedWeekdays!.isNotEmpty
              ? [1, 2, 3, 4, 5, 6, 7]
                  .where((d) => !trip.excludedWeekdays!.contains(d))
                  .toList()
              : [1, 2, 3, 4, 5],
      outboundTime: outTime,
      hasReturnRide: trip.isReturnTrip == true || (retTime != null),
      returnTime: retTime,
      seatsCount: seats,
      passengers: (trip.coPassengers != null && trip.coPassengers!.isNotEmpty)
          ? trip.coPassengers!
              .map((cp) => SpecialTripPassengerModel(
                    name: '${cp.firstName ?? ''} ${cp.lastName ?? ''}'.trim(),
                    phone: cp.phone ?? '',
                    isCurrentUser: false,
                    paymentStatus: PassengerPaymentStatus.unpaid,
                  ))
              .toList()
          : [
              SpecialTripPassengerModel(
                name: 'You',
                phone: '',
                isCurrentUser: true,
                paymentStatus: trip.paymentStatus?.toLowerCase() == 'paid'
                    ? PassengerPaymentStatus.paid
                    : PassengerPaymentStatus.unpaid,
              ),
            ],
      paymentResponsibility:
          trip.paymentResponsibility?.toLowerCase().contains('each') == true
              ? PaymentResponsibility.eachPassengerPays
              : PaymentResponsibility.creatorPays,
      fare: fareModel,
      status: status,
      driver: driverModel,
      estimatedFare: trip.estimatedFare?.toDouble(),
      activeDates: trip.selectedDates ?? [],
      otp: trip.otp,
    );
  }
}

typedef ScheduledRideResponse = SpecialTripRequestModel;
typedef ScheduledRideRequest = SpecialTripRequestModel;
