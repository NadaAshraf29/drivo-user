class UniversitySearchRequest {
  final String? universityId;
  final String universityName;
  final String? pickupPointId;
  final String pickupPointName;
  final String date;
  final int seats;
  final String gender;
  final bool needReturnRide;

  const UniversitySearchRequest({
    this.universityId,
    required this.universityName,
    this.pickupPointId,
    required this.pickupPointName,
    required this.date,
    this.seats = 1,
    this.gender = 'male',
    this.needReturnRide = true,
  });

  Map<String, dynamic> toJson() {
    return {
      if (universityId != null) 'university_id': universityId,
      'university_name': universityName,
      if (pickupPointId != null) 'pickup_point_id': pickupPointId,
      'pickup_point_name': pickupPointName,
      'date': date,
      'seats': seats,
      'gender': gender,
      'need_return_ride': needReturnRide,
    };
  }

  factory UniversitySearchRequest.fromJson(Map<String, dynamic> json) {
    return UniversitySearchRequest(
      universityId: json['university_id']?.toString(),
      universityName: json['university_name']?.toString() ?? '',
      pickupPointId: json['pickup_point_id']?.toString(),
      pickupPointName: json['pickup_point_name']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      seats: json['seats'] != null ? int.tryParse(json['seats'].toString()) ?? 1 : 1,
      gender: json['gender']?.toString() ?? 'male',
      needReturnRide: json['need_return_ride'] ?? true,
    );
  }
}
