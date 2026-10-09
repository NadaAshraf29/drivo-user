class SchoolPickupPointModel {
  final String id;
  final String name;
  final String? nameAr;
  final String pickupTime;
  final String distanceText;
  final bool isCurrent;
  final double latitude;
  final double longitude;

  const SchoolPickupPointModel({
    required this.id,
    required this.name,
    this.nameAr,
    required this.pickupTime,
    required this.distanceText,
    this.isCurrent = false,
    required this.latitude,
    required this.longitude,
  });

  factory SchoolPickupPointModel.fromJson(Map<String, dynamic> json) {
    return SchoolPickupPointModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameAr: json['name_ar']?.toString(),
      pickupTime: json['pickup_time']?.toString() ?? '7:15 AM',
      distanceText: json['distance_text']?.toString() ??
          (json['distance_km'] != null
              ? '${json['distance_km']} km away'
              : '0.9 km away'),
      isCurrent: json['is_current'] == true ||
          json['is_current']?.toString().toLowerCase() == 'true',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString()) ?? 30.0588
          : 30.0588,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString()) ?? 31.3411
          : 31.3411,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'pickup_time': pickupTime,
      'distance_text': distanceText,
      'is_current': isCurrent,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  SchoolPickupPointModel copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? pickupTime,
    String? distanceText,
    bool? isCurrent,
    double? latitude,
    double? longitude,
  }) {
    return SchoolPickupPointModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      pickupTime: pickupTime ?? this.pickupTime,
      distanceText: distanceText ?? this.distanceText,
      isCurrent: isCurrent ?? this.isCurrent,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
