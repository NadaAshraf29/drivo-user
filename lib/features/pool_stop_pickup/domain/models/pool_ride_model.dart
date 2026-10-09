import 'driver_model.dart';
import 'vehicle_model.dart';
import 'match_point_model.dart';
import 'boarding_point_model.dart';

class LocationPoint {
  final double lat;
  final double lng;
  final String placeName;

  LocationPoint({
    required this.lat,
    required this.lng,
    required this.placeName,
  });

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    try {
      return LocationPoint(
        lat: (json['lat'] ?? 0.0).toDouble(),
        lng: (json['lng'] ?? 0.0).toDouble(),
        placeName: json['place_name'] ?? '',
      );
    } catch (e) {
      print('Error parsing LocationPoint: $e');
      print('JSON data: $json');
      return LocationPoint(lat: 0.0, lng: 0.0, placeName: '');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'place_name': placeName,
    };
  }
}

class RecurringInfo {
  final String recurrenceType;
  final List<DateTime> selectedDates;
  final List<DateTime> availableDates;

  RecurringInfo({
    required this.recurrenceType,
    required this.selectedDates,
    required this.availableDates,
  });

  factory RecurringInfo.fromJson(Map<String, dynamic> json) {
    return RecurringInfo(
      recurrenceType: json['recurrence_type'] ?? '',
      selectedDates: (json['selected_dates'] as List?)
              ?.map((e) => DateTime.parse(e))
              .toList() ??
          [],
      availableDates: (json['available_dates'] as List?)
              ?.map((e) => DateTime.parse(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recurrence_type': recurrenceType,
      'selected_dates': selectedDates.map((e) => e.toIso8601String()).toList(),
      'available_dates':
          availableDates.map((e) => e.toIso8601String()).toList(),
    };
  }
}

class PoolRide {
  final int routeId;
  final String? title;
  final Driver driver;
  final Vehicle vehicle;
  final String? category;
  final String startTime;
  final int seatsAvailable;
  final bool isAc;
  final bool isSmokingAllowed;
  final MatchPoint pickupMatchPoint;
  final MatchPoint dropoffMatchPoint;
  final String pickupAddress;
  final String dropoffAddress;
  final int price;
  final int? dailyPricePerSeat;
  final bool hasMusic;
  final bool hasScreenEntertainment;
  final bool allowLuggage;
  final String allowedGender;
  final int? allowedAgeMin;
  final int? allowedAgeMax;
  final String? encodedPolyline;
  final MatchPoint? routeStartPoint;
  final MatchPoint? routeEndPoint;
  final LocationPoint? closestPickup;
  final LocationPoint? closestDropoff;
  final bool? isRecurring;
  final RecurringInfo? recurringInfo;
  final String? carpoolType;
  final String? carpoolTypeLabel;
  final String? carpoolTypeLabelAr;
  final BoardingPoint? boardingPointStart;
  final BoardingPoint? boardingPointEnd;
  final String? departureTime;
  final String? returnTime;
  final double? distanceFromUserKm;

  PoolRide({
    required this.routeId,
    required this.driver,
    required this.vehicle,
    this.category,
    required this.startTime,
    required this.seatsAvailable,
    required this.isAc,
    required this.isSmokingAllowed,
    required this.pickupMatchPoint,
    required this.dropoffMatchPoint,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.price,
    this.dailyPricePerSeat,
    required this.hasMusic,
    required this.hasScreenEntertainment,
    required this.allowLuggage,
    required this.allowedGender,
    this.allowedAgeMin,
    this.allowedAgeMax,
    this.encodedPolyline,
    this.routeStartPoint,
    this.routeEndPoint,
    this.closestPickup,
    this.closestDropoff,
    this.isRecurring,
    this.recurringInfo,
    this.carpoolType,
    this.carpoolTypeLabel,
    this.carpoolTypeLabelAr,
    this.boardingPointStart,
    this.boardingPointEnd,
    this.departureTime,
    this.returnTime,
    this.title,
    this.distanceFromUserKm,
  });

  factory PoolRide.fromJson(Map<String, dynamic> json) {
    try {
      final String? poly = (json['encoded_polyline'] != null &&
              json['encoded_polyline'].toString().isNotEmpty)
          ? json['encoded_polyline'].toString()
          : (json['driver_encoded_polyline'] ??
                  json['driver_polyline'] ??
                  json['route_polyline'] ??
                  json['full_encoded_polyline'] ??
                  json['full_polyline'] ??
                  json['passenger_polyline'])
              ?.toString();

      final dynamic startRaw = json['route_start_point'] ??
          json['driver_start_point'] ??
          json['driver_start_location'] ??
          json['start_coordinates'] ??
          json['start_location'] ??
          json['pickup_coordinates'];

      final dynamic endRaw = json['route_end_point'] ??
          json['driver_end_point'] ??
          json['driver_end_location'] ??
          json['end_coordinates'] ??
          json['end_location'] ??
          json['destination_coordinates'];

      final dynamic pickupRaw = json['pickup_match_point'] ??
          json['boarding_point_start'] ??
          json['passenger_pickup'] ??
          startRaw;

      final dynamic dropoffRaw = json['dropoff_match_point'] ??
          json['boarding_point_end'] ??
          json['passenger_dropoff'] ??
          endRaw;

      final String parsedPickupAddress = (json['pickup_address'] ??
              json['start_address'] ??
              json['pickup_location'] ??
              json['start_location'] ??
              json['from_location'] ??
              json['from_address'] ??
              json['from'] ??
              json['origin'] ??
              json['start_name'] ??
              json['pickup_name'] ??
              json['route_start_address'] ??
              json['route_start_name'] ??
              json['driver_start_address'] ??
              (startRaw is Map ? (startRaw['address'] ?? startRaw['name'] ?? startRaw['place_name'] ?? startRaw['title']) : null) ??
              '')
          .toString();

      final String parsedDropoffAddress = (json['dropoff_address'] ??
              json['end_address'] ??
              json['dropoff_location'] ??
              json['end_location'] ??
              json['to_location'] ??
              json['to_address'] ??
              json['to'] ??
              json['destination'] ??
              json['end_name'] ??
              json['dropoff_name'] ??
              json['route_end_address'] ??
              json['route_end_name'] ??
              json['driver_end_address'] ??
              (endRaw is Map ? (endRaw['address'] ?? endRaw['name'] ?? endRaw['place_name'] ?? endRaw['title']) : null) ??
              '')
          .toString();

      return PoolRide(
        routeId: (json['route_id'] as num?)?.toInt() ??
            (json['id'] as num?)?.toInt() ??
            0,
        title: json['title']?.toString() ??
            json['name']?.toString() ??
            json['route_name']?.toString(),
        driver: Driver.fromJson(json['driver'] ?? {}),
        vehicle: Vehicle.fromJson(json['vehicle'] ?? {}),
        category: json['category'],
        startTime: json['start_time'] ?? json['departure_time'] ?? '',
        seatsAvailable: (json['seats_available'] as num?)?.toInt() ??
            (json['available_seats'] as num?)?.toInt() ??
            0,
        isAc: json['is_ac'] ?? json['ac'] ?? false,
        isSmokingAllowed:
            json['is_smoking_allowed'] ?? json['smoking_allowed'] ?? false,
        pickupMatchPoint: MatchPoint.fromJson(pickupRaw ?? {}),
        dropoffMatchPoint: MatchPoint.fromJson(dropoffRaw ?? {}),
        pickupAddress: parsedPickupAddress,
        dropoffAddress: parsedDropoffAddress,
        price: (json['price'] as num?)?.toInt() ?? 0,
        dailyPricePerSeat: (json['daily_price_per_seat'] as num?)?.toInt(),
        hasMusic: json['has_music'] ?? false,
        hasScreenEntertainment: json['has_screen_entertainment'] ?? false,
        allowLuggage: json['allow_luggage'] ?? false,
        allowedGender: json['allowed_gender'] ?? '',
        allowedAgeMin: (json['allowed_age_min'] as num?)?.toInt(),
        allowedAgeMax: (json['allowed_age_max'] as num?)?.toInt(),
        encodedPolyline: poly,
        routeStartPoint:
            startRaw != null ? MatchPoint.fromJson(startRaw) : null,
        routeEndPoint: endRaw != null ? MatchPoint.fromJson(endRaw) : null,
        closestPickup: json['closest_pickup'] != null
            ? LocationPoint.fromJson(json['closest_pickup'])
            : null,
        closestDropoff: json['closest_dropoff'] != null
            ? LocationPoint.fromJson(json['closest_dropoff'])
            : null,
        isRecurring: json['is_recurring'],
        recurringInfo: json['recurring_info'] != null
            ? RecurringInfo.fromJson(json['recurring_info'])
            : null,
        carpoolType: json['carpool_type'],
        carpoolTypeLabel: json['carpool_type_label'],
        carpoolTypeLabelAr: json['carpool_type_label_ar'],
        boardingPointStart: json['boarding_point_start'] != null
            ? BoardingPoint.fromJson(json['boarding_point_start'])
            : null,
        boardingPointEnd: json['boarding_point_end'] != null
            ? BoardingPoint.fromJson(json['boarding_point_end'])
            : null,
        departureTime: json['departure_time'],
        returnTime: json['return_time'],
        distanceFromUserKm:
            (json['distance_from_user_km'] as num?)?.toDouble(),
      );
    } catch (e) {
      print('Error parsing PoolRide: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'driver': driver.toJson(),
      'vehicle': vehicle.toJson(),
      'category': category,
      'start_time': startTime,
      'seats_available': seatsAvailable,
      'is_ac': isAc,
      'is_smoking_allowed': isSmokingAllowed,
      'pickup_match_point': pickupMatchPoint.toJson(),
      'dropoff_match_point': dropoffMatchPoint.toJson(),
      'pickup_address': pickupAddress,
      'dropoff_address': dropoffAddress,
      'price': price,
      'daily_price_per_seat': dailyPricePerSeat,
      'has_music': hasMusic,
      'has_screen_entertainment': hasScreenEntertainment,
      'allow_luggage': allowLuggage,
      'allowed_gender': allowedGender,
      'allowed_age_min': allowedAgeMin,
      'allowed_age_max': allowedAgeMax,
      'encoded_polyline': encodedPolyline,
      'route_start_point': routeStartPoint?.toJson(),
      'route_end_point': routeEndPoint?.toJson(),
      'closest_pickup': closestPickup?.toJson(),
      'closest_dropoff': closestDropoff?.toJson(),
      'is_recurring': isRecurring,
      'recurring_info': recurringInfo?.toJson(),
      'carpool_type': carpoolType,
      'carpool_type_label': carpoolTypeLabel,
      'carpool_type_label_ar': carpoolTypeLabelAr,
      'boarding_point_start': boardingPointStart?.toJson(),
      'boarding_point_end': boardingPointEnd?.toJson(),
      'departure_time': departureTime,
      'return_time': returnTime,
      'distance_from_user_km': distanceFromUserKm,
    };
  }

  PoolRide copyWith({
    int? routeId,
    String? title,
    Driver? driver,
    Vehicle? vehicle,
    String? category,
    String? startTime,
    int? seatsAvailable,
    bool? isAc,
    bool? isSmokingAllowed,
    MatchPoint? pickupMatchPoint,
    MatchPoint? dropoffMatchPoint,
    String? pickupAddress,
    String? dropoffAddress,
    int? price,
    int? dailyPricePerSeat,
    bool? hasMusic,
    bool? hasScreenEntertainment,
    bool? allowLuggage,
    String? allowedGender,
    int? allowedAgeMin,
    int? allowedAgeMax,
    String? encodedPolyline,
    MatchPoint? routeStartPoint,
    MatchPoint? routeEndPoint,
    LocationPoint? closestPickup,
    LocationPoint? closestDropoff,
    bool? isRecurring,
    RecurringInfo? recurringInfo,
    String? carpoolType,
    String? carpoolTypeLabel,
    String? carpoolTypeLabelAr,
    BoardingPoint? boardingPointStart,
    BoardingPoint? boardingPointEnd,
    String? departureTime,
    String? returnTime,
    double? distanceFromUserKm,
  }) {
    return PoolRide(
      routeId: routeId ?? this.routeId,
      title: title ?? this.title,
      driver: driver ?? this.driver,
      vehicle: vehicle ?? this.vehicle,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      seatsAvailable: seatsAvailable ?? this.seatsAvailable,
      isAc: isAc ?? this.isAc,
      isSmokingAllowed: isSmokingAllowed ?? this.isSmokingAllowed,
      pickupMatchPoint: pickupMatchPoint ?? this.pickupMatchPoint,
      dropoffMatchPoint: dropoffMatchPoint ?? this.dropoffMatchPoint,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      price: price ?? this.price,
      dailyPricePerSeat: dailyPricePerSeat ?? this.dailyPricePerSeat,
      hasMusic: hasMusic ?? this.hasMusic,
      hasScreenEntertainment:
          hasScreenEntertainment ?? this.hasScreenEntertainment,
      allowLuggage: allowLuggage ?? this.allowLuggage,
      allowedGender: allowedGender ?? this.allowedGender,
      allowedAgeMin: allowedAgeMin ?? this.allowedAgeMin,
      allowedAgeMax: allowedAgeMax ?? this.allowedAgeMax,
      encodedPolyline: encodedPolyline ?? this.encodedPolyline,
      routeStartPoint: routeStartPoint ?? this.routeStartPoint,
      routeEndPoint: routeEndPoint ?? this.routeEndPoint,
      closestPickup: closestPickup ?? this.closestPickup,
      closestDropoff: closestDropoff ?? this.closestDropoff,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringInfo: recurringInfo ?? this.recurringInfo,
      carpoolType: carpoolType ?? this.carpoolType,
      carpoolTypeLabel: carpoolTypeLabel ?? this.carpoolTypeLabel,
      carpoolTypeLabelAr: carpoolTypeLabelAr ?? this.carpoolTypeLabelAr,
      boardingPointStart: boardingPointStart ?? this.boardingPointStart,
      boardingPointEnd: boardingPointEnd ?? this.boardingPointEnd,
      departureTime: departureTime ?? this.departureTime,
      returnTime: returnTime ?? this.returnTime,
      distanceFromUserKm: distanceFromUserKm ?? this.distanceFromUserKm,
    );
  }
}
