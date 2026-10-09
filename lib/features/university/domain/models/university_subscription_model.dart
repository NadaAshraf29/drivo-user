class UniversitySubscriptionModel {
  final String subscriptionId;
  final String tripId;
  final String routeName;
  final String university;
  final String pickupPoint;
  final String subscriptionDuration;
  final String status;
  final String startDate;
  final String endDate;
  final bool hasReturnRide;
  final double amount;
  final String? receiptUrl;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? createdAt;
  final UniversitySubscriptionDriver? driver;

  const UniversitySubscriptionModel({
    required this.subscriptionId,
    required this.tripId,
    required this.routeName,
    required this.university,
    required this.pickupPoint,
    required this.subscriptionDuration,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.hasReturnRide = true,
    required this.amount,
    this.receiptUrl,
    this.paymentMethod,
    this.paymentStatus,
    this.createdAt,
    this.driver,
  });

  factory UniversitySubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UniversitySubscriptionModel(
      subscriptionId: json['subscription_id']?.toString() ?? '',
      tripId: json['trip_id']?.toString() ?? '',
      routeName: json['route_name']?.toString() ?? '',
      university: json['university']?.toString() ?? '',
      pickupPoint: json['pickup_point']?.toString() ?? '',
      subscriptionDuration: json['subscription_duration']?.toString() ?? 'monthly',
      status: json['status']?.toString() ?? 'pending_verification',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      hasReturnRide: json['has_return_ride'] ?? true,
      amount: json['amount'] != null ? double.tryParse(json['amount'].toString()) ?? 0.0 : 0.0,
      receiptUrl: json['receipt_url']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      createdAt: json['created_at']?.toString(),
      driver: json['driver'] != null ? UniversitySubscriptionDriver.fromJson(json['driver']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscription_id': subscriptionId,
      'trip_id': tripId,
      'route_name': routeName,
      'university': university,
      'pickup_point': pickupPoint,
      'subscription_duration': subscriptionDuration,
      'status': status,
      'start_date': startDate,
      'end_date': endDate,
      'has_return_ride': hasReturnRide,
      'amount': amount,
      'receipt_url': receiptUrl,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'created_at': createdAt,
      'driver': driver?.toJson(),
    };
  }
}

class UniversitySubscriptionDriver {
  final String? name;
  final String? phone;
  final String? vehicle;
  final double? rating;

  const UniversitySubscriptionDriver({
    this.name,
    this.phone,
    this.vehicle,
    this.rating,
  });

  factory UniversitySubscriptionDriver.fromJson(Map<String, dynamic> json) {
    return UniversitySubscriptionDriver(
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      vehicle: json['vehicle']?.toString(),
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'vehicle': vehicle,
      'rating': rating,
    };
  }
}
