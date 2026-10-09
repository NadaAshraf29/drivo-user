class SchoolConfigModel {
  final List<SchoolItem> schools;
  final List<SchoolPickupPointItem> pickupPoints;

  const SchoolConfigModel({
    this.schools = const [],
    this.pickupPoints = const [],
  });

  factory SchoolConfigModel.fromJson(Map<String, dynamic> json) {
    var schs = <SchoolItem>[];
    if (json['schools'] != null && json['schools'] is List) {
      for (var v in json['schools']) {
        if (v != null && v is Map<String, dynamic>) {
          schs.add(SchoolItem.fromJson(v));
        }
      }
    }

    var points = <SchoolPickupPointItem>[];
    if (json['pickup_points'] != null && json['pickup_points'] is List) {
      for (var v in json['pickup_points']) {
        if (v != null && v is Map<String, dynamic>) {
          points.add(SchoolPickupPointItem.fromJson(v));
        }
      }
    }

    for (int i = 0; i < schs.length; i++) {
      final s = schs[i];
      final digitsMatch = RegExp(r'\d+').allMatches(s.id);
      final idDigits = digitsMatch.isNotEmpty ? digitsMatch.last.group(0)! : '';

      final List<SchoolPickupPointItem> combinedPoints = [];
      final Set<String> pointNames = {};

      for (var p in s.pickupPoints) {
        final name = p.name.trim();
        if (name.isNotEmpty && !pointNames.contains(name.toLowerCase())) {
          pointNames.add(name.toLowerCase());
          combinedPoints.add(p);
        }
      }

      for (var p in points) {
        final name = p.name.trim();
        if (name.isEmpty) continue;

        bool isRelated = false;
        if (p.schoolId != null && p.schoolId == s.id) {
          isRelated = true;
        } else if (p.schoolName != null &&
            p.schoolName!.toLowerCase() == s.name.toLowerCase()) {
          isRelated = true;
        } else if (idDigits.isNotEmpty &&
            (p.id.contains('_$idDigits') ||
                p.id.contains(idDigits) ||
                (p.schoolId != null && p.schoolId!.contains(idDigits)))) {
          isRelated = true;
        }

        if (isRelated && !pointNames.contains(name.toLowerCase())) {
          pointNames.add(name.toLowerCase());
          combinedPoints.add(SchoolPickupPointItem(
            id: p.id,
            name: p.name,
            nameAr: p.nameAr ?? p.name,
            pickupTime: p.pickupTime,
            distanceKm: p.distanceKm,
            latitude: p.latitude,
            longitude: p.longitude,
            schoolId: s.id,
            schoolName: s.name,
          ));
        }
      }

      schs[i] = SchoolItem(
        id: s.id,
        name: s.name,
        nameAr: s.nameAr,
        address: s.address,
        latitude: s.latitude,
        longitude: s.longitude,
        mainGate: s.mainGate,
        pickupPoints: combinedPoints,
      );
    }

    return SchoolConfigModel(
      schools: schs,
      pickupPoints: points,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schools': schools.map((v) => v.toJson()).toList(),
      'pickup_points': pickupPoints.map((v) => v.toJson()).toList(),
    };
  }
}

class SchoolItem {
  final String id;
  final String name;
  final String? nameAr;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? mainGate;
  final List<SchoolPickupPointItem> pickupPoints;

  const SchoolItem({
    required this.id,
    required this.name,
    this.nameAr,
    this.address,
    this.latitude,
    this.longitude,
    this.mainGate,
    this.pickupPoints = const [],
  });

  factory SchoolItem.fromJson(Map<String, dynamic> json) {
    var points = <SchoolPickupPointItem>[];
    if (json['pickup_points'] != null && json['pickup_points'] is List) {
      for (var v in json['pickup_points']) {
        if (v != null && v is Map<String, dynamic>) {
          points.add(SchoolPickupPointItem.fromJson(v));
        }
      }
    }

    return SchoolItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameAr: json['name_ar']?.toString(),
      address: json['address']?.toString(),
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      mainGate: json['main_gate']?.toString() ?? 'Main Gate',
      pickupPoints: points,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'main_gate': mainGate,
      'pickup_points': pickupPoints.map((v) => v.toJson()).toList(),
    };
  }
}

class SchoolPickupPointItem {
  final String id;
  final String name;
  final String? nameAr;
  final String? schoolId;
  final String? schoolName;
  final String? pickupTime;
  final double? distanceKm;
  final double? latitude;
  final double? longitude;

  const SchoolPickupPointItem({
    required this.id,
    required this.name,
    this.nameAr,
    this.schoolId,
    this.schoolName,
    this.pickupTime,
    this.distanceKm,
    this.latitude,
    this.longitude,
  });

  factory SchoolPickupPointItem.fromJson(Map<String, dynamic> json) {
    return SchoolPickupPointItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameAr: json['name_ar']?.toString(),
      schoolId: json['school_id']?.toString(),
      schoolName: json['school_name']?.toString(),
      pickupTime: json['pickup_time']?.toString() ?? '7:15 AM',
      distanceKm: json['distance_km'] != null
          ? double.tryParse(json['distance_km'].toString())
          : null,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'school_id': schoolId,
      'school_name': schoolName,
      'pickup_time': pickupTime,
      'distance_km': distanceKm,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
