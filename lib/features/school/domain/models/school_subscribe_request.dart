class SchoolSubscribeRequest {
  final String tripId;
  final String pickupPoint;
  final String? pickupPointId;
  final String subscriptionDuration;
  final String paymentMethod;
  final int seats;
  final String gender;
  final bool needReturnRide;
  final double amount;
  final String? note;

  const SchoolSubscribeRequest({
    required this.tripId,
    required this.pickupPoint,
    this.pickupPointId,
    required this.subscriptionDuration,
    required this.paymentMethod,
    this.seats = 1,
    this.gender = 'male',
    this.needReturnRide = true,
    required this.amount,
    this.note,
  });

  String get _formattedDuration {
    if (subscriptionDuration == 'two_weeks' ||
        subscriptionDuration == '2_weeks' ||
        subscriptionDuration == '14_days') {
      return 'biweekly';
    }
    if (subscriptionDuration == 'one_week' || subscriptionDuration == '1_week') {
      return 'weekly';
    }
    if (subscriptionDuration == 'one_month' || subscriptionDuration == '1_month') {
      return 'monthly';
    }
    return subscriptionDuration;
  }

  Map<String, String> toFieldsMap() {
    return {
      'trip_id': tripId,
      'pickup_point': pickupPoint,
      if (pickupPointId != null) 'pickup_point_id': pickupPointId!,
      'subscription_duration': _formattedDuration,
      'payment_method': paymentMethod,
      'seats': seats.toString(),
      'gender': gender,
      'need_return_ride': needReturnRide ? '1' : '0',
      'amount': amount.toString(),
      if (note != null && note!.isNotEmpty) 'note': note!,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_id': tripId,
      'pickup_point': pickupPoint,
      if (pickupPointId != null) 'pickup_point_id': pickupPointId,
      'subscription_duration': _formattedDuration,
      'payment_method': paymentMethod,
      'seats': seats,
      'gender': gender,
      'need_return_ride': needReturnRide,
      'amount': amount,
      if (note != null && note!.isNotEmpty) 'note': note,
    };
  }

  factory SchoolSubscribeRequest.fromJson(Map<String, dynamic> json) {
    return SchoolSubscribeRequest(
      tripId: json['trip_id']?.toString() ?? '',
      pickupPoint: json['pickup_point']?.toString() ?? '',
      pickupPointId: json['pickup_point_id']?.toString(),
      subscriptionDuration: json['subscription_duration']?.toString() ?? 'monthly',
      paymentMethod: json['payment_method']?.toString() ?? 'instapay',
      seats: json['seats'] != null ? int.tryParse(json['seats'].toString()) ?? 1 : 1,
      gender: json['gender']?.toString() ?? 'male',
      needReturnRide: json['need_return_ride'] == true ||
          json['need_return_ride']?.toString() == '1',
      amount: json['amount'] != null
          ? double.tryParse(json['amount'].toString()) ?? 0.0
          : 0.0,
      note: json['note']?.toString(),
    );
  }
}
