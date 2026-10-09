class UniversityActiveTripModel {
  final String id;
  final String routeName;
  final String universityName;
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
  final ActiveTripDriver driver;
  final String startTripCode;
  final List<ActiveTripPassenger> passengers;
  final int additionalPassengersCount;
  final String totalPassengersText;
  final double pickupLatitude;
  final double pickupLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final double? driverLatitude;
  final double? driverLongitude;

  const UniversityActiveTripModel({
    required this.id,
    required this.routeName,
    required this.universityName,
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
    this.startTripCode = '4829',
    this.passengers = const [],
    this.additionalPassengersCount = 1,
    this.totalPassengersText = '3 passengers sharing this route',
    this.pickupLatitude = 30.0601,
    this.pickupLongitude = 31.3411,
    this.destinationLatitude = 30.0444,
    this.destinationLongitude = 31.2357,
    this.driverLatitude = 30.0528,
    this.driverLongitude = 31.2915,
  });

  factory UniversityActiveTripModel.fromJson(Map<String, dynamic> json) {
    var passList = <ActiveTripPassenger>[];
    if (json['passengers'] != null && json['passengers'] is List) {
      json['passengers'].forEach((v) {
        passList.add(ActiveTripPassenger.fromJson(v));
      });
    }

    return UniversityActiveTripModel(
      id: json['id']?.toString() ?? '',
      routeName: json['route_name']?.toString() ?? 'Route 5',
      universityName: json['university_name']?.toString() ?? 'Cairo University',
      pickupPoint: json['pickup_point']?.toString() ?? 'Abbas El Akkad',
      pickupAddress: json['pickup_address']?.toString() ?? 'Madinat Al-Amal, Nasr City',
      destinationAddress: json['destination_address']?.toString() ?? 'Downtown Cairo',
      pickupTime: json['pickup_time']?.toString() ?? '7:00 AM',
      departureTime: json['departure_time']?.toString() ?? '07:30 AM',
      estimatedArrival: json['estimated_arrival']?.toString() ?? '08:25 AM',
      subscriptionType: json['subscription_type']?.toString() ?? 'Monthly',
      validUntil: json['valid_until']?.toString() ?? 'Sep 30',
      hasReturnRide: json['has_return_ride'] ?? true,
      status: json['status']?.toString() ?? 'on_route',
      statusText: json['status_text']?.toString() ?? 'On route',
      seatLabel: json['seat_label']?.toString() ?? 'Seat 2 of 4',
      routeSubtitle: json['route_subtitle']?.toString() ?? 'Route to Downtown',
      pickupEtaMinutes: json['pickup_eta_minutes'] != null
          ? int.tryParse(json['pickup_eta_minutes'].toString()) ?? 8
          : 8,
      driver: json['driver'] != null
          ? ActiveTripDriver.fromJson(json['driver'])
          : ActiveTripDriver.mockDriver(),
      startTripCode: json['start_trip_code']?.toString() ?? '4829',
      passengers: passList.isNotEmpty ? passList : ActiveTripPassenger.mockPassengers(),
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
          ? double.tryParse(json['driver_latitude'].toString()) ?? 30.0528
          : 30.0528,
      driverLongitude: json['driver_longitude'] != null
          ? double.tryParse(json['driver_longitude'].toString()) ?? 31.2915
          : 31.2915,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route_name': routeName,
      'university_name': universityName,
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
    };
  }

  static UniversityActiveTripModel getMockActiveTrip() {
    return const UniversityActiveTripModel(
      id: 'active_1',
      routeName: 'Route 5',
      universityName: 'Cairo University',
      pickupPoint: 'Abbas El Akkad',
      pickupAddress: 'Madinat Al-Amal, Nasr City',
      destinationAddress: 'Downtown Cairo',
      pickupTime: '7:00 AM',
      departureTime: '07:30 AM',
      estimatedArrival: '08:25 AM',
      subscriptionType: 'Monthly',
      validUntil: 'Sep 30',
      hasReturnRide: true,
      status: 'on_route',
      statusText: 'On route',
      seatLabel: 'Seat 2 of 4',
      routeSubtitle: 'Route to Downtown',
      pickupEtaMinutes: 8,
      pickupLatitude: 30.0601,
      pickupLongitude: 31.3411,
      destinationLatitude: 30.0444,
      destinationLongitude: 31.2357,
      driverLatitude: 30.0528,
      driverLongitude: 31.2915,
      driver: ActiveTripDriver(
        id: 'drv_10',
        name: 'Karim Fathy',
        phone: '+201099887766',
        vehicleName: 'Kia Cerato',
        vehicleColor: 'White',
        plateNumber: 'CAI 2290',
        rating: 4.9,
        isVerified: true,
        avatarInitial: 'K',
        etaMinutes: 6,
      ),
      startTripCode: '4829',
      passengers: [
        ActiveTripPassenger(name: 'Sarah', avatarInitial: 'S'),
        ActiveTripPassenger(name: 'Nour', avatarInitial: 'N'),
      ],
      additionalPassengersCount: 1,
      totalPassengersText: '3 passengers sharing this route',
    );
  }
}

class ActiveTripDriver {
  final String id;
  final String name;
  final String phone;
  final String vehicleName;
  final String vehicleColor;
  final String plateNumber;
  final double rating;
  final bool isVerified;
  final String avatarInitial;
  final int etaMinutes;

  const ActiveTripDriver({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleName,
    required this.vehicleColor,
    required this.plateNumber,
    required this.rating,
    this.isVerified = true,
    required this.avatarInitial,
    this.etaMinutes = 6,
  });

  factory ActiveTripDriver.fromJson(Map<String, dynamic> json) {
    return ActiveTripDriver(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Karim Fathy',
      phone: json['phone']?.toString() ?? '+201099887766',
      vehicleName: json['vehicle_name']?.toString() ?? 'Kia Cerato',
      vehicleColor: json['vehicle_color']?.toString() ?? 'White',
      plateNumber: json['plate_number']?.toString() ?? 'CAI 2290',
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) ?? 4.9 : 4.9,
      isVerified: json['is_verified'] ?? true,
      avatarInitial: json['avatar_initial']?.toString() ?? 'K',
      etaMinutes: json['eta_minutes'] != null ? int.tryParse(json['eta_minutes'].toString()) ?? 6 : 6,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'vehicle_name': vehicleName,
      'vehicle_color': vehicleColor,
      'plate_number': plateNumber,
      'rating': rating,
      'is_verified': isVerified,
      'avatar_initial': avatarInitial,
      'eta_minutes': etaMinutes,
    };
  }

  static ActiveTripDriver mockDriver() {
    return const ActiveTripDriver(
      id: 'drv_10',
      name: 'Karim Fathy',
      phone: '+201099887766',
      vehicleName: 'Kia Cerato',
      vehicleColor: 'White',
      plateNumber: 'CAI 2290',
      rating: 4.9,
      isVerified: true,
      avatarInitial: 'K',
      etaMinutes: 6,
    );
  }
}

class ActiveTripPassenger {
  final String name;
  final String avatarInitial;

  const ActiveTripPassenger({
    required this.name,
    required this.avatarInitial,
  });

  factory ActiveTripPassenger.fromJson(Map<String, dynamic> json) {
    return ActiveTripPassenger(
      name: json['name']?.toString() ?? '',
      avatarInitial: json['avatar_initial']?.toString() ?? 'P',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatar_initial': avatarInitial,
    };
  }

  static List<ActiveTripPassenger> mockPassengers() {
    return const [
      ActiveTripPassenger(name: 'Sarah', avatarInitial: 'S'),
      ActiveTripPassenger(name: 'Nour', avatarInitial: 'N'),
    ];
  }
}
