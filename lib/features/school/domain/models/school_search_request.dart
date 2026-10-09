class SchoolSearchRequest {
  final String schoolName;
  final String pickupPointName;
  final String? schoolId;
  final String? pickupPointId;
  final DateTime? date;
  final int seats;
  final String gender;
  final bool needReturnRide;

  const SchoolSearchRequest({
    required this.schoolName,
    required this.pickupPointName,
    this.schoolId,
    this.pickupPointId,
    this.date,
    this.seats = 1,
    this.gender = 'male',
    this.needReturnRide = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'school_name': schoolName,
      'pickup_point_name': pickupPointName,
      if (schoolId != null) 'school_id': schoolId,
      if (pickupPointId != null) 'pickup_point_id': pickupPointId,
      if (date != null) 'date': date!.toIso8601String().split('T').first,
      'seats': seats,
      'gender': gender,
      'need_return_ride': needReturnRide,
    };
  }

  SchoolSearchRequest copyWith({
    String? schoolName,
    String? pickupPointName,
    String? schoolId,
    String? pickupPointId,
    DateTime? date,
    int? seats,
    String? gender,
    bool? needReturnRide,
  }) {
    return SchoolSearchRequest(
      schoolName: schoolName ?? this.schoolName,
      pickupPointName: pickupPointName ?? this.pickupPointName,
      schoolId: schoolId ?? this.schoolId,
      pickupPointId: pickupPointId ?? this.pickupPointId,
      date: date ?? this.date,
      seats: seats ?? this.seats,
      gender: gender ?? this.gender,
      needReturnRide: needReturnRide ?? this.needReturnRide,
    );
  }
}
