class UniversityConfigModel {
  final List<UniversityItem> universities;
  final List<UniversityPickupPointItem> pickupPoints;

  const UniversityConfigModel({
    this.universities = const [],
    this.pickupPoints = const [],
  });

  factory UniversityConfigModel.fromJson(Map<String, dynamic> json) {
    var unis = <UniversityItem>[];
    if (json['universities'] != null && json['universities'] is List) {
      for (var v in json['universities']) {
        if (v != null && v is Map<String, dynamic>) {
          unis.add(UniversityItem.fromJson(v));
        }
      }
    }

    var points = <UniversityPickupPointItem>[];
    if (json['pickup_points'] != null && json['pickup_points'] is List) {
      for (var v in json['pickup_points']) {
        if (v != null && v is Map<String, dynamic>) {
          points.add(UniversityPickupPointItem.fromJson(v));
        }
      }
    }

    for (int i = 0; i < unis.length; i++) {
      final u = unis[i];
      // Extract numeric route ID e.g. "uni_route_625" -> "625"
      final digitsMatch = RegExp(r'\d+').allMatches(u.id);
      final idDigits = digitsMatch.isNotEmpty ? digitsMatch.last.group(0)! : '';

      final List<UniversityPickupPointItem> combinedPoints = [];
      final Set<String> pointNames = {};

      // 1. Add embedded pickup_points inside the university object
      for (var p in u.pickupPoints) {
        final name = p.name.trim();
        if (name.isNotEmpty && !pointNames.contains(name.toLowerCase())) {
          pointNames.add(name.toLowerCase());
          combinedPoints.add(p);
        }
      }

      // 2. Find matching pickup points from the top-level pickup_points array
      for (var p in points) {
        final name = p.name.trim();
        if (name.isEmpty) continue;

        bool isRelated = false;
        if (p.universityId != null && p.universityId == u.id) {
          isRelated = true;
        } else if (p.universityName != null &&
            p.universityName!.toLowerCase() == u.name.toLowerCase()) {
          isRelated = true;
        } else if (idDigits.isNotEmpty &&
            (p.id.contains('_$idDigits') ||
                p.id.contains(idDigits) ||
                (p.universityId != null && p.universityId!.contains(idDigits)))) {
          isRelated = true;
        }

        if (isRelated && !pointNames.contains(name.toLowerCase())) {
          pointNames.add(name.toLowerCase());
          combinedPoints.add(UniversityPickupPointItem(
            id: p.id,
            name: p.name,
            nameAr: p.nameAr ?? p.name,
            area: p.area,
            latitude: p.latitude,
            longitude: p.longitude,
            universityId: u.id,
            universityName: u.name,
          ));
        }
      }

      unis[i] = UniversityItem(
        id: u.id,
        name: u.name,
        nameAr: u.nameAr,
        address: u.address,
        latitude: u.latitude,
        longitude: u.longitude,
        mainGate: u.mainGate,
        pickupPoints: combinedPoints,
      );
    }

    return UniversityConfigModel(
      universities: unis,
      pickupPoints: points,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'universities': universities.map((v) => v.toJson()).toList(),
      'pickup_points': pickupPoints.map((v) => v.toJson()).toList(),
    };
  }
}

class UniversityItem {
  final String id;
  final String name;
  final String? nameAr;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? mainGate;
  final List<UniversityPickupPointItem>? _pickupPoints;

  List<UniversityPickupPointItem> get pickupPoints => _pickupPoints ?? const [];

  const UniversityItem({
    required this.id,
    required this.name,
    this.nameAr,
    this.address,
    this.latitude,
    this.longitude,
    this.mainGate,
    List<UniversityPickupPointItem>? pickupPoints,
  }) : _pickupPoints = pickupPoints;

  factory UniversityItem.fromJson(Map<String, dynamic> json) {
    var points = <UniversityPickupPointItem>[];
    if (json['pickup_points'] != null && json['pickup_points'] is List) {
      for (var v in json['pickup_points']) {
        if (v != null && v is Map<String, dynamic>) {
          points.add(UniversityPickupPointItem.fromJson(v));
        }
      }
    }

    return UniversityItem(
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
      mainGate: json['main_gate']?.toString(),
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

class UniversityPickupPointItem {
  final String id;
  final String name;
  final String? nameAr;
  final String? area;
  final double? latitude;
  final double? longitude;
  final String? universityId;
  final String? universityName;

  const UniversityPickupPointItem({
    required this.id,
    required this.name,
    this.nameAr,
    this.area,
    this.latitude,
    this.longitude,
    this.universityId,
    this.universityName,
  });

  factory UniversityPickupPointItem.fromJson(Map<String, dynamic> json) {
    return UniversityPickupPointItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameAr: json['name_ar']?.toString(),
      area: json['area']?.toString(),
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      universityId: json['university_id']?.toString(),
      universityName: json['university_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'area': area,
      'latitude': latitude,
      'longitude': longitude,
      if (universityId != null) 'university_id': universityId,
      if (universityName != null) 'university_name': universityName,
    };
  }
}
