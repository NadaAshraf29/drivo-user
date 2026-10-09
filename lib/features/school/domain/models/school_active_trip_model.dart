class SchoolActiveTripModel {
  final String id;
  final String routeName;
  final String schoolName;
  final String pickupPoint;
  final String pickupAddress;
  final String destinationAddress;
  final String pickupTime;
  final String departureTime;
  final String estimatedArrival;
  final String subscriptionType;
  final String validUntil;
  final bool hasReturnRide;
  final String status;
  final String statusText;
  final String seatLabel;
  final String routeSubtitle;
  final int pickupEtaMinutes;
  final SchoolActiveTripDriver driver;
  final String startTripCode;
  final List<SchoolActiveTripPassenger> passengers;
  final int additionalPassengersCount;
  final String totalPassengersText;
  final double pickupLatitude;
  final double pickupLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final double? driverLatitude;
  final double? driverLongitude;
  final bool isOtpGiven;

  const SchoolActiveTripModel({
    required this.id,
    required this.routeName,
    required this.schoolName,
    required this.pickupPoint,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupTime,
    required this.departureTime,
    required this.estimatedArrival,
    required this.subscriptionType,
    required this.validUntil,
    this.hasReturnRide = true,
    this.status = 'on_route',
    this.statusText = 'On route',
    this.seatLabel = 'Seat 2 of 4',
    this.routeSubtitle = 'Route to Downtown',
    this.pickupEtaMinutes = 8,
    required this.driver,
    this.startTripCode = '4821',
    this.passengers = const [],
    this.additionalPassengersCount = 1,
    this.totalPassengersText = '3 passengers sharing this route',
    this.pickupLatitude = 30.0601,
    this.pickupLongitude = 31.3411,
    this.destinationLatitude = 30.0444,
    this.destinationLongitude = 31.2357,
    this.driverLatitude = 30.0528,
    this.driverLongitude = 31.2915,
    this.isOtpGiven = false,
  });

  factory SchoolActiveTripModel.fromJson(Map<String, dynamic> json) {
    var passList = <SchoolActiveTripPassenger>[];
    if (json['passengers'] != null && json['passengers'] is List) {
      json['passengers'].forEach((v) {
        passList.add(SchoolActiveTripPassenger.fromJson(v));
      });
    }

    return SchoolActiveTripModel(
      id: json['id']?.toString() ?? 'active_sch_1',
      routeName: json['route_name']?.toString() ?? 'Route name',
      schoolName: json['school_name']?.toString() ??
          json['to_school']?.toString() ??
          'Cairo school',
      pickupPoint: json['pickup_point']?.toString() ?? 'Abbas El Akkad',
      pickupAddress:
          json['pickup_address']?.toString() ?? 'Madinat Al-Amal, Nasr City',
      destinationAddress: json['destination_address']?.toString() ??
          json['dropoff_address']?.toString() ??
          'Downtown Cairo',
      pickupTime: json['pickup_time']?.toString() ?? '7:00 AM',
      departureTime: json['departure_time']?.toString() ??
          json['today_schedule']?.toString() ??
          '07:30 AM',
      estimatedArrival: json['estimated_arrival']?.toString() ??
          json['destination_eta_time']?.toString() ??
          '08:25 AM',
      subscriptionType: json['subscription_type']?.toString() ?? 'Monthly',
      validUntil: json['valid_until']?.toString() ?? 'Sep 30',
      hasReturnRide: json['has_return'] ?? json['has_return_ride'] ?? true,
      status: json['status']?.toString() ?? 'on_route',
      statusText: json['status_text']?.toString() ?? 'On route',
      seatLabel: json['seat_info']?.toString() ??
          json['seat_label']?.toString() ??
          'Seat 2 of 4',
      routeSubtitle: json['route_subtitle']?.toString() ?? 'Route to Downtown',
      pickupEtaMinutes: json['eta_minutes'] != null
          ? int.tryParse(json['eta_minutes'].toString()) ?? 8
          : (json['pickup_eta_minutes'] != null
              ? int.tryParse(json['pickup_eta_minutes'].toString()) ?? 8
              : 8),
      driver: json['driver'] != null
          ? SchoolActiveTripDriver.fromJson(json['driver'])
          : const SchoolActiveTripDriver(
              name: '',
              avatar: '',
              phone: '',
              vehicleModel: '',
              vehicleColor: '',
              plateNumber: '',
              rating: 5.0,
              isVerified: true,
              etaMinutes: 0,
            ),
      startTripCode: json['pin_code']?.toString() ??
          json['start_trip_code']?.toString() ??
          '',
      passengers: passList,
      additionalPassengersCount: json['additional_passengers_count'] != null
          ? int.tryParse(json['additional_passengers_count'].toString()) ?? 1
          : 1,
      totalPassengersText: json['total_passengers_text']?.toString() ??
          '3 passengers sharing this route',
      pickupLatitude: json['pickup_latitude'] != null
          ? double.tryParse(json['pickup_latitude'].toString()) ?? 30.0601
          : 30.0601,
      pickupLongitude: json['pickup_longitude'] != null
          ? double.tryParse(json['pickup_longitude'].toString()) ?? 31.3411
          : 31.3411,
      destinationLatitude: json['destination_latitude'] != null
          ? double.tryParse(json['destination_latitude'].toString()) ?? 30.0444
          : 30.0444,
      destinationLongitude: json['destination_longitude'] != null
          ? double.tryParse(json['destination_longitude'].toString()) ?? 31.2357
          : 31.2357,
      driverLatitude: json['driver_latitude'] != null
          ? double.tryParse(json['driver_latitude'].toString())
          : (json['vehicle_location'] != null &&
                  json['vehicle_location']['latitude'] != null
              ? double.tryParse(json['vehicle_location']['latitude'].toString())
              : 30.0528),
      driverLongitude: json['driver_longitude'] != null
          ? double.tryParse(json['driver_longitude'].toString())
          : (json['vehicle_location'] != null &&
                  json['vehicle_location']['longitude'] != null
              ? double.tryParse(
                  json['vehicle_location']['longitude'].toString())
              : 31.2915),
      isOtpGiven: json['is_otp_given'] == true ||
          json['is_otp_verified'] == true ||
          json['otp_given'] == true ||
          (json['status']?.toString().toLowerCase() == 'ongoing') ||
          (json['status']?.toString().toLowerCase() == 'started') ||
          (json['status']?.toString().toLowerCase() == 'picked_up') ||
          (json['status']?.toString().toLowerCase() == 'in_progress'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route_name': routeName,
      'school_name': schoolName,
      'pickup_point': pickupPoint,
      'pickup_address': pickupAddress,
      'destination_address': destinationAddress,
      'pickup_time': pickupTime,
      'departure_time': departureTime,
      'estimated_arrival': estimatedArrival,
      'subscription_type': subscriptionType,
      'valid_until': validUntil,
      'has_return_ride': hasReturnRide,
      'status': status,
      'status_text': statusText,
      'seat_label': seatLabel,
      'route_subtitle': routeSubtitle,
      'pickup_eta_minutes': pickupEtaMinutes,
      'driver': driver.toJson(),
      'start_trip_code': startTripCode,
      'passengers': passengers.map((v) => v.toJson()).toList(),
      'additional_passengers_count': additionalPassengersCount,
      'total_passengers_text': totalPassengersText,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'destination_latitude': destinationLatitude,
      'destination_longitude': destinationLongitude,
      'driver_latitude': driverLatitude,
      'driver_longitude': driverLongitude,
      'is_otp_given': isOtpGiven,
    };
  }

  SchoolActiveTripModel copyWith({
    String? id,
    String? routeName,
    String? schoolName,
    String? pickupPoint,
    String? pickupAddress,
    String? destinationAddress,
    String? pickupTime,
    String? departureTime,
    String? estimatedArrival,
    String? subscriptionType,
    String? validUntil,
    bool? hasReturnRide,
    String? status,
    String? statusText,
    String? seatLabel,
    String? routeSubtitle,
    int? pickupEtaMinutes,
    SchoolActiveTripDriver? driver,
    String? startTripCode,
    List<SchoolActiveTripPassenger>? passengers,
    int? additionalPassengersCount,
    String? totalPassengersText,
    double? pickupLatitude,
    double? pickupLongitude,
    double? destinationLatitude,
    double? destinationLongitude,
    double? driverLatitude,
    double? driverLongitude,
    bool? isOtpGiven,
  }) {
    return SchoolActiveTripModel(
      id: id ?? this.id,
      routeName: routeName ?? this.routeName,
      schoolName: schoolName ?? this.schoolName,
      pickupPoint: pickupPoint ?? this.pickupPoint,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      pickupTime: pickupTime ?? this.pickupTime,
      departureTime: departureTime ?? this.departureTime,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      validUntil: validUntil ?? this.validUntil,
      hasReturnRide: hasReturnRide ?? this.hasReturnRide,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      seatLabel: seatLabel ?? this.seatLabel,
      routeSubtitle: routeSubtitle ?? this.routeSubtitle,
      pickupEtaMinutes: pickupEtaMinutes ?? this.pickupEtaMinutes,
      driver: driver ?? this.driver,
      startTripCode: startTripCode ?? this.startTripCode,
      passengers: passengers ?? this.passengers,
      additionalPassengersCount:
          additionalPassengersCount ?? this.additionalPassengersCount,
      totalPassengersText: totalPassengersText ?? this.totalPassengersText,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      destinationLatitude: destinationLatitude ?? this.destinationLatitude,
      destinationLongitude:
          destinationLongitude ?? this.destinationLongitude,
      driverLatitude: driverLatitude ?? this.driverLatitude,
      driverLongitude: driverLongitude ?? this.driverLongitude,
      isOtpGiven: isOtpGiven ?? this.isOtpGiven,
    );
  }
}

class SchoolActiveTripDriver {
  final String name;
  final String? avatar;
  final String? phone;
  final String vehicleModel;
  final String vehicleColor;
  final String plateNumber;
  final double rating;
  final bool isVerified;
  final int etaMinutes;

  const SchoolActiveTripDriver({
    required this.name,
    this.avatar,
    this.phone,
    required this.vehicleModel,
    this.vehicleColor = 'White',
    this.plateNumber = 'CAI 2290',
    this.rating = 4.9,
    this.isVerified = true,
    this.etaMinutes = 6,
  });

  factory SchoolActiveTripDriver.fromJson(Map<String, dynamic> json) {
    String vModel = 'Kia Cerato';
    String vColor = 'White';
    String vPlate = 'CAI 2290';

    if (json['vehicle'] != null) {
      final vStr = json['vehicle'].toString();
      final parts = vStr.split('·').map((e) => e.trim()).toList();
      if (parts.isNotEmpty) vModel = parts[0];
      if (parts.length > 1) vColor = parts[1];
      if (parts.length > 2) vPlate = parts[2];
    }

    return SchoolActiveTripDriver(
      name: json['name']?.toString() ?? 'Karim Fathy',
      avatar: json['avatar']?.toString() ?? 'K',
      phone: json['phone']?.toString() ?? '+201001234567',
      vehicleModel: json['vehicle_model']?.toString() ?? vModel,
      vehicleColor: json['vehicle_color']?.toString() ?? vColor,
      plateNumber: json['plate_number']?.toString() ?? vPlate,
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString()) ?? 4.9
          : 4.9,
      isVerified: json['is_verified'] ?? true,
      etaMinutes: json['driver_eta_minutes'] != null
          ? int.tryParse(json['driver_eta_minutes'].toString()) ?? 6
          : (json['eta_minutes'] != null
              ? int.tryParse(json['eta_minutes'].toString()) ?? 6
              : 6),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatar': avatar,
      'phone': phone,
      'vehicle_model': vehicleModel,
      'vehicle_color': vehicleColor,
      'plate_number': plateNumber,
      'rating': rating,
      'is_verified': isVerified,
      'eta_minutes': etaMinutes,
    };
  }
}

class SchoolActiveTripPassenger {
  final String name;
  final String avatarText;
  final String? avatarUrl;

  const SchoolActiveTripPassenger({
    required this.name,
    required this.avatarText,
    this.avatarUrl,
  });

  factory SchoolActiveTripPassenger.fromJson(Map<String, dynamic> json) {
    return SchoolActiveTripPassenger(
      name: json['name']?.toString() ?? '',
      avatarText: json['avatar_text']?.toString() ??
          (json['name'] != null && json['name'].toString().isNotEmpty
              ? json['name'].toString()[0].toUpperCase()
              : 'P'),
      avatarUrl: json['avatar_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatar_text': avatarText,
      'avatar_url': avatarUrl,
    };
  }
}
