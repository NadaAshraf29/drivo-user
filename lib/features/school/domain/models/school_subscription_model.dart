class SchoolSubscriptionModel {
  final String subscriptionId;
  final String tripId;
  final String routeName;
  final String school;
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
  final SchoolSubscriptionDriver? driver;

  const SchoolSubscriptionModel({
    required this.subscriptionId,
    required this.tripId,
    required this.routeName,
    required this.school,
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

  factory SchoolSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SchoolSubscriptionModel(
      subscriptionId: json['subscription_id']?.toString() ?? '',
      tripId: json['trip_id']?.toString() ?? '',
      routeName: json['route_name']?.toString() ?? '',
      school: json['school']?.toString() ?? json['to_school']?.toString() ?? '',
      pickupPoint: json['pickup_point']?.toString() ?? '',
      subscriptionDuration: json['subscription_duration']?.toString() ?? 'monthly',
      status: json['status']?.toString() ?? 'pending_verification',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      hasReturnRide: json['has_return_ride'] ?? true,
      amount: json['amount'] != null
          ? double.tryParse(json['amount'].toString()) ?? 0.0
          : 0.0,
      receiptUrl: json['receipt_url']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      createdAt: json['created_at']?.toString(),
      driver: json['driver'] != null
          ? SchoolSubscriptionDriver.fromJson(json['driver'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscription_id': subscriptionId,
      'trip_id': tripId,
      'route_name': routeName,
      'school': school,
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
      if (driver != null) 'driver': driver!.toJson(),
    };
  }
}

class SchoolSubscriptionDriver {
  final String name;
  final String? phone;
  final String? avatar;
  final String? vehicle;
  final double rating;

  const SchoolSubscriptionDriver({
    required this.name,
    this.phone,
    this.avatar,
    this.vehicle,
    this.rating = 5.0,
  });

  factory SchoolSubscriptionDriver.fromJson(Map<String, dynamic> json) {
    return SchoolSubscriptionDriver(
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      avatar: json['avatar']?.toString(),
      vehicle: json['vehicle']?.toString(),
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString()) ?? 5.0
          : 5.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'vehicle': vehicle,
      'rating': rating,
    };
  }
}
