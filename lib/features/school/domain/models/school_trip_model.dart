import 'dart:convert';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/pool_ride_model.dart';

class SchoolTripModel {
  final String id;
  final String routeName;
  final String fromArea;
  final String toSchool;
  final String pickupPoint;
  final String destinationPoint;
  final String scheduleTime;
  final String returnTime;
  final double price;
  final int seatsLeft;
  final String driverName;
  final String driverAvatar;
  final String driverVehicle;
  final double driverRating;
  final String subscriptionType;
  final int subscriptionDurationDays;
  final String validUntil;
  final bool hasReturnRide;
  final String? encodedPolyline;
  final double? startLatitude;
  final double? startLongitude;
  final double? endLatitude;
  final double? endLongitude;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final List<dynamic>? restStops;

  const SchoolTripModel({
    required this.id,
    required this.routeName,
    required this.fromArea,
    required this.toSchool,
    required this.pickupPoint,
    required this.destinationPoint,
    required this.scheduleTime,
    required this.returnTime,
    required this.price,
    required this.seatsLeft,
    required this.driverName,
    this.driverAvatar = 'A',
    required this.driverVehicle,
    required this.driverRating,
    required this.subscriptionType,
    this.subscriptionDurationDays = 30,
    required this.validUntil,
    this.hasReturnRide = true,
    this.encodedPolyline,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
    this.pickupLatitude,
    this.pickupLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
    this.restStops,
  });

  factory SchoolTripModel.fromJson(Map<String, dynamic> json) {
    String drvName = 'Ahmed Samir';
    String drvAvatar = 'A';
    double drvRating = 4.9;

    if (json['driver'] != null && json['driver'] is Map) {
      drvName = json['driver']['name']?.toString() ??
          json['driver']['full_name']?.toString() ??
          drvName;
      drvAvatar = json['driver']['avatar']?.toString() ??
          (drvName.isNotEmpty ? drvName[0].toUpperCase() : 'A');
      if (json['driver']['rating'] != null) {
        drvRating = double.tryParse(json['driver']['rating'].toString()) ?? 4.9;
      }
    } else {
      drvName = json['driver_name']?.toString() ?? drvName;
      drvAvatar = json['driver_avatar']?.toString() ??
          (drvName.isNotEmpty ? drvName[0].toUpperCase() : 'A');
      if (json['driver_rating'] != null) {
        drvRating = double.tryParse(json['driver_rating'].toString()) ?? 4.9;
      }
    }

    String drvVehicle = parseVehicleName(
      json['vehicle'],
      driverData: json['driver'],
    );
    if (drvVehicle.isEmpty) {
      drvVehicle = parseVehicleName(json['driver_vehicle']);
    }
    if (drvVehicle.isEmpty) {
      drvVehicle = parseVehicleName(json['vehicle_model']);
    }
    if (drvVehicle.isEmpty) {
      drvVehicle = 'Unknown';
    }

    double parsedPrice = 1450.0;
    if (json['price'] != null) {
      parsedPrice = double.tryParse(json['price'].toString()) ?? 1450.0;
    } else if (json['daily_price_per_seat'] != null) {
      parsedPrice =
          double.tryParse(json['daily_price_per_seat'].toString()) ?? 1450.0;
    } else if (json['monthly_price'] != null) {
      parsedPrice = double.tryParse(json['monthly_price'].toString()) ?? 1450.0;
    }

    final rawSeats = json['seats_left'] ?? json['seats_available'];
    final seats = rawSeats != null ? int.tryParse(rawSeats.toString()) ?? 6 : 6;

    final fromA = json['from_area']?.toString() ??
        json['start_address']?.toString() ??
        json['pickup_address']?.toString() ??
        'Nasr City';

    final toSch = json['to_school']?.toString() ??
        json['school_name']?.toString() ??
        json['end_address']?.toString() ??
        json['dropoff_address']?.toString() ??
        json['title']?.toString() ??
        'Cairo school';

    final pPoint = json['pickup_point']?.toString() ??
        json['start_address']?.toString() ??
        json['pickup_address']?.toString() ??
        'Abbas El Akkad';

    final dPoint = json['destination_point']?.toString() ??
        json['destination']?.toString() ??
        json['dropoff_address']?.toString() ??
        '$toSch Main Gate';

    final sTime = json['schedule_time']?.toString() ??
        json['departure_time']?.toString() ??
        '7:00 AM';

    final rTime = json['return_time']?.toString() ?? '7:00 PM';

    final rName = json['route_name']?.toString() ??
        json['title']?.toString() ??
        'Route name';

    final subType = json['subscription_type']?.toString() ?? 'monthly';
    final subDays = json['subscription_duration_days'] != null
        ? int.tryParse(json['subscription_duration_days'].toString()) ?? 30
        : 30;

    final vUntil = json['valid_until']?.toString() ?? 'Sep 30, 2026';

    final hasRet = json['has_return'] != null
        ? (json['has_return'] == true ||
            json['has_return'].toString().toLowerCase() == 'true')
        : (rTime.isNotEmpty && rTime != 'null');

    final String? poly = (json['encoded_polyline'] ??
            json['polyline'] ??
            json['driver_encoded_polyline'] ??
            json['route_polyline'] ??
            json['full_encoded_polyline'])
        ?.toString();

    double? startLat;
    double? startLng;
    final startRaw = json['route_start_point'] ??
        json['driver_start_point'] ??
        json['start_coordinates'] ??
        json['start_location'] ??
        json['pickup_coordinates'];
    if (startRaw is Map) {
      startLat = double.tryParse((startRaw['lat'] ?? startRaw['latitude'])?.toString() ?? '');
      startLng = double.tryParse((startRaw['lng'] ?? startRaw['longitude'])?.toString() ?? '');
    }

    double? endLat;
    double? endLng;
    final endRaw = json['route_end_point'] ??
        json['driver_end_point'] ??
        json['end_coordinates'] ??
        json['end_location'] ??
        json['destination_coordinates'];
    if (endRaw is Map) {
      endLat = double.tryParse((endRaw['lat'] ?? endRaw['latitude'])?.toString() ?? '');
      endLng = double.tryParse((endRaw['lng'] ?? endRaw['longitude'])?.toString() ?? '');
    }

    double? pLat;
    double? pLng;
    final pRaw = json['pickup_match_point'] ??
        json['boarding_point_start'] ??
        json['passenger_pickup'] ??
        json['pickup_point_coordinates'];
    if (pRaw is Map) {
      pLat = double.tryParse((pRaw['lat'] ?? pRaw['latitude'])?.toString() ?? '');
      pLng = double.tryParse((pRaw['lng'] ?? pRaw['longitude'])?.toString() ?? '');
    }

    double? dLat;
    double? dLng;
    final dRaw = json['dropoff_match_point'] ??
        json['boarding_point_end'] ??
        json['passenger_dropoff'] ??
        json['dropoff_point_coordinates'];
    if (dRaw is Map) {
      dLat = double.tryParse((dRaw['lat'] ?? dRaw['latitude'])?.toString() ?? '');
      dLng = double.tryParse((dRaw['lng'] ?? dRaw['longitude'])?.toString() ?? '');
    }

    return SchoolTripModel(
      id: json['id']?.toString() ??
          'trip_${DateTime.now().millisecondsSinceEpoch}',
      routeName: rName,
      fromArea: fromA,
      toSchool: toSch,
      pickupPoint: pPoint,
      destinationPoint: dPoint,
      scheduleTime: sTime,
      returnTime: rTime,
      price: parsedPrice,
      seatsLeft: seats,
      driverName: drvName,
      driverAvatar: drvAvatar,
      driverVehicle: drvVehicle,
      driverRating: drvRating,
      subscriptionType: subType,
      subscriptionDurationDays: subDays,
      validUntil: vUntil,
      hasReturnRide: hasRet,
      encodedPolyline: poly,
      startLatitude: startLat,
      startLongitude: startLng,
      endLatitude: endLat,
      endLongitude: endLng,
      pickupLatitude: pLat,
      pickupLongitude: pLng,
      destinationLatitude: dLat,
      destinationLongitude: dLng,
      restStops: () {
        final raw = json['rest_stops'] ?? json['restStops'] ?? json['stops'];
        if (raw is List) return raw;
        return null;
      }(),
    );
  }

  factory SchoolTripModel.fromPoolRide(PoolRide ride) {
    String drvName = ride.driver.fullName.trim();
    if (drvName.isEmpty) drvName = 'Driver';
    String drvAvatar = drvName.isNotEmpty ? drvName[0].toUpperCase() : 'D';
    String drvVehicle = parseVehicleName({
      'brand': ride.vehicle.brand,
      'model': ride.vehicle.model,
      'plate_number': ride.vehicle.plateNumber,
    });
    if (drvVehicle.isEmpty) drvVehicle = 'Bus / Van';
    double drvRating = ride.driver.rating ?? 5.0;

    final double price = ride.dailyPricePerSeat != null
        ? ride.dailyPricePerSeat!.toDouble()
        : (ride.price.toDouble());

    final int seats = ride.seatsAvailable;

    String pickup = ride.pickupAddress.trim();
    if (ride.boardingPointStart != null &&
        ride.boardingPointStart!.name.trim().isNotEmpty) {
      pickup = ride.boardingPointStart!.name.trim();
    }

    String toSchool = ride.dropoffAddress.trim();
    if (toSchool.isEmpty && ride.title != null) {
      toSchool = ride.title!.trim();
    }

    final String schedule =
        (ride.departureTime != null && ride.departureTime!.isNotEmpty)
            ? ride.departureTime!
            : (ride.startTime.isNotEmpty ? ride.startTime : '7:00 AM');

    final String retTime =
        (ride.returnTime != null && ride.returnTime!.isNotEmpty)
            ? ride.returnTime!
            : '4:00 PM';

    final startPt = ride.routeStartPoint;
    final endPt = ride.routeEndPoint;
    final pPt = ride.pickupMatchPoint;
    final dPt = ride.dropoffMatchPoint;

    return SchoolTripModel(
      id: ride.routeId.toString(),
      routeName: (ride.title != null && ride.title!.isNotEmpty)
          ? ride.title!
          : 'Route name',
      fromArea: pickup.isNotEmpty ? pickup : 'Nasr City',
      toSchool: toSchool.isNotEmpty ? toSchool : 'Cairo school',
      pickupPoint: pickup.isNotEmpty ? pickup : 'Abbas El Akkad',
      destinationPoint: toSchool.isNotEmpty
          ? '$toSchool Main Gate'
          : 'Cairo school Main Gate',
      scheduleTime: schedule,
      returnTime: retTime,
      price: price,
      seatsLeft: seats,
      driverName: drvName,
      driverAvatar: drvAvatar,
      driverVehicle: drvVehicle,
      driverRating: drvRating,
      subscriptionType: 'monthly',
      subscriptionDurationDays: 30,
      validUntil: 'Sep 30, 2026',
      hasReturnRide: true,
      encodedPolyline: ride.encodedPolyline,
      startLatitude: startPt?.lat != null && startPt!.lat != 0 ? startPt.lat : null,
      startLongitude: startPt?.lng != null && startPt!.lng != 0 ? startPt.lng : null,
      endLatitude: endPt?.lat != null && endPt!.lat != 0 ? endPt.lat : null,
      endLongitude: endPt?.lng != null && endPt!.lng != 0 ? endPt.lng : null,
      pickupLatitude: pPt.lat != 0 ? pPt.lat : ride.closestPickup?.lat,
      pickupLongitude: pPt.lng != 0 ? pPt.lng : ride.closestPickup?.lng,
      destinationLatitude: dPt.lat != 0 ? dPt.lat : ride.closestDropoff?.lat,
      destinationLongitude: dPt.lng != 0 ? dPt.lng : ride.closestDropoff?.lng,
      restStops: ride.restStops,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route_name': routeName,
      'from_area': fromArea,
      'to_school': toSchool,
      'pickup_point': pickupPoint,
      'destination_point': destinationPoint,
      'schedule_time': scheduleTime,
      'return_time': returnTime,
      'price': price,
      'seats_left': seatsLeft,
      'driver': {
        'name': driverName,
        'avatar': driverAvatar,
        'vehicle': driverVehicle,
        'rating': driverRating,
      },
      'subscription_type': subscriptionType,
      'subscription_duration_days': subscriptionDurationDays,
      'valid_until': validUntil,
      'has_return': hasReturnRide,
    };
  }

  SchoolTripModel copyWith({
    String? id,
    String? routeName,
    String? fromArea,
    String? toSchool,
    String? pickupPoint,
    String? destinationPoint,
    String? scheduleTime,
    String? returnTime,
    double? price,
    int? seatsLeft,
    String? driverName,
    String? driverAvatar,
    String? driverVehicle,
    double? driverRating,
    String? subscriptionType,
    int? subscriptionDurationDays,
    String? validUntil,
    bool? hasReturnRide,
  }) {
    return SchoolTripModel(
      id: id ?? this.id,
      routeName: routeName ?? this.routeName,
      fromArea: fromArea ?? this.fromArea,
      toSchool: toSchool ?? this.toSchool,
      pickupPoint: pickupPoint ?? this.pickupPoint,
      destinationPoint: destinationPoint ?? this.destinationPoint,
      scheduleTime: scheduleTime ?? this.scheduleTime,
      returnTime: returnTime ?? this.returnTime,
      price: price ?? this.price,
      seatsLeft: seatsLeft ?? this.seatsLeft,
      driverName: driverName ?? this.driverName,
      driverAvatar: driverAvatar ?? this.driverAvatar,
      driverVehicle: driverVehicle ?? this.driverVehicle,
      driverRating: driverRating ?? this.driverRating,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      subscriptionDurationDays:
          subscriptionDurationDays ?? this.subscriptionDurationDays,
      validUntil: validUntil ?? this.validUntil,
      hasReturnRide: hasReturnRide ?? this.hasReturnRide,
    );
  }

  static String parseVehicleName(dynamic vehicleData, {dynamic driverData}) {
    if (driverData != null && driverData is Map) {
      final directDriverVehicle = driverData['vehicle_model'] ??
          driverData['vehicle_name'] ??
          driverData['car_model'] ??
          driverData['model_name'];
      if (directDriverVehicle != null) {
        final dStr = directDriverVehicle.toString().trim();
        if (dStr.isNotEmpty && !dStr.startsWith('{')) {
          return dStr;
        }
      }
      if (driverData['vehicle'] != null &&
          driverData['vehicle'] != vehicleData) {
        final fromDrv = parseVehicleName(driverData['vehicle']);
        if (fromDrv.isNotEmpty) return fromDrv;
      }
    }

    if (vehicleData == null) return '';

    if (vehicleData is Map) {
      final directName = vehicleData['name'] ??
          vehicleData['vehicle_name'] ??
          vehicleData['vehicle_model'] ??
          vehicleData['car_model'] ??
          vehicleData['title'];

      String brandStr = '';
      if (vehicleData['brand'] != null) {
        if (vehicleData['brand'] is Map) {
          brandStr = vehicleData['brand']['name']?.toString() ??
              vehicleData['brand']['title']?.toString() ??
              '';
        } else {
          final b = vehicleData['brand'].toString().trim();
          if (!b.startsWith('{')) brandStr = b;
        }
      }

      String modelStr = '';
      if (vehicleData['model'] != null) {
        if (vehicleData['model'] is Map) {
          modelStr = vehicleData['model']['name']?.toString() ??
              vehicleData['model']['model_name']?.toString() ??
              vehicleData['model']['title']?.toString() ??
              '';
        } else {
          final m = vehicleData['model'].toString().trim();
          if (!m.startsWith('{')) modelStr = m;
        }
      }

      if (directName != null) {
        final dStr = directName.toString().trim();
        if (dStr.isNotEmpty && !dStr.startsWith('{')) {
          if (brandStr.isNotEmpty &&
              !dStr.toLowerCase().contains(brandStr.toLowerCase())) {
            return '$brandStr $dStr'.trim();
          }
          return dStr;
        }
      }

      if (brandStr.isNotEmpty && modelStr.isNotEmpty) {
        if (modelStr.toLowerCase().contains(brandStr.toLowerCase())) {
          return modelStr;
        }
        return '$brandStr $modelStr'.trim();
      }
      if (modelStr.isNotEmpty) return modelStr;
      if (brandStr.isNotEmpty) return brandStr;

      final plate =
          vehicleData['plate_number'] ?? vehicleData['licence_plate_number'];
      if (plate != null &&
          plate.toString().trim().isNotEmpty &&
          !plate.toString().trim().startsWith('{')) {
        return plate.toString().trim();
      }

      return '';
    }

    final str = vehicleData.toString().trim();
    if (str.isEmpty || str == 'null') return '';

    if (!str.contains('{') && !str.contains('}')) {
      return _formatVehicleName(str);
    }

    // Extract all JSON objects enclosed in { ... } (handles concatenated JSON strings like "{...} {...}")
    List<Map<String, dynamic>> extractedObjects = [];
    int depth = 0;
    int start = -1;
    for (int i = 0; i < str.length; i++) {
      if (str[i] == '{') {
        if (depth == 0) start = i;
        depth++;
      } else if (str[i] == '}') {
        depth--;
        if (depth == 0 && start != -1) {
          final jsonChunk = str.substring(start, i + 1);
          try {
            final decoded = jsonDecode(jsonChunk);
            if (decoded is Map<String, dynamic>) {
              extractedObjects.add(decoded);
            } else if (decoded is Map) {
              extractedObjects.add(Map<String, dynamic>.from(decoded));
            }
          } catch (_) {}
          start = -1;
        }
      }
    }

    if (extractedObjects.isNotEmpty) {
      String brandName = '';
      String modelName = '';

      for (var obj in extractedObjects) {
        final n = (obj['name'] ??
                obj['vehicle_name'] ??
                obj['vehicle_model'] ??
                obj['car_model'] ??
                obj['title'] ??
                '')
            .toString()
            .trim();
        if (n.isEmpty) continue;

        if (obj.containsKey('brand_id') ||
            obj.containsKey('seat_capacity') ||
            obj.containsKey('maximum_weight')) {
          modelName = n;
        } else {
          brandName = n;
        }
      }

      if (brandName.isNotEmpty && modelName.isNotEmpty) {
        if (modelName.toLowerCase().contains(brandName.toLowerCase())) {
          return _formatVehicleName(modelName);
        }
        if (brandName.toLowerCase().contains(modelName.toLowerCase())) {
          return _formatVehicleName(brandName);
        }
        final firstWordBrand =
            brandName.split(RegExp(r'[\s\-_]+')).first.toLowerCase();
        final firstWordModel =
            modelName.split(RegExp(r'[\s\-_]+')).first.toLowerCase();
        if (firstWordBrand.isNotEmpty && firstWordBrand == firstWordModel) {
          return _formatVehicleName(brandName);
        }
        return _formatVehicleName('$brandName $modelName'.trim());
      }
      if (brandName.isNotEmpty) return _formatVehicleName(brandName);
      if (modelName.isNotEmpty) return _formatVehicleName(modelName);
    }

    // Fallback: Regex extraction for quoted name
    final quotedNameMatches =
        RegExp(r'"name"\s*:\s*"([^"]+)"').allMatches(str).toList();
    if (quotedNameMatches.isNotEmpty) {
      final firstName = quotedNameMatches.first.group(1)?.trim() ?? '';
      if (firstName.isNotEmpty) {
        return _formatVehicleName(firstName);
      }
    }

    String extractedBrand = '';
    String extractedModel = '';

    final brandMatch =
        RegExp(r'(?:brand|brand_name)["\s:]+([^,}\]"\r\n]+)').firstMatch(str);
    if (brandMatch != null) {
      extractedBrand = brandMatch.group(1)?.trim().replaceAll('"', '') ?? '';
    }

    final modelMatch =
        RegExp(r'(?:model|name|vehicle_model)["\s:]+([^,}\]"\r\n]+)')
            .firstMatch(str);
    if (modelMatch != null) {
      extractedModel = modelMatch.group(1)?.trim().replaceAll('"', '') ?? '';
    }

    if (extractedBrand.isNotEmpty || extractedModel.isNotEmpty) {
      if (extractedModel
          .toLowerCase()
          .contains(extractedBrand.toLowerCase())) {
        return _formatVehicleName(extractedModel);
      }
      return _formatVehicleName('$extractedBrand $extractedModel'.trim());
    }

    return '';
  }

  static String _formatVehicleName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return trimmed;
    final words = trimmed.split(RegExp(r'\s+'));
    return words.map((w) {
      if (w.length <= 3) return w.toUpperCase();
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).join(' ');
  }
}
