import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';

class UniversityPickupPointModel {
  final String id;
  final String name;
  final String timing;
  final String? tag;
  final double? latitude;
  final double? longitude;

  const UniversityPickupPointModel({
    required this.id,
    required this.name,
    required this.timing,
    this.tag,
    this.latitude,
    this.longitude,
  });

  factory UniversityPickupPointModel.fromJson(Map<String, dynamic> json) {
    double? rawLat = json['latitude'] != null
        ? double.tryParse(json['latitude'].toString())
        : (json['lat'] != null
            ? double.tryParse(json['lat'].toString())
            : null);
    double? rawLng = json['longitude'] != null
        ? double.tryParse(json['longitude'].toString())
        : (json['lng'] != null
            ? double.tryParse(json['lng'].toString())
            : (json['long'] != null
                ? double.tryParse(json['long'].toString())
                : null));

    if (rawLat != null && rawLng != null && (rawLat != 0 || rawLng != 0)) {
      final corrected = MapBoundHelper.toCorrectLatLng(rawLat, rawLng);
      rawLat = corrected.latitude;
      rawLng = corrected.longitude;
    }

    return UniversityPickupPointModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      timing: json['timing']?.toString() ?? '',
      tag: json['tag']?.toString(),
      latitude: rawLat,
      longitude: rawLng,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'timing': timing,
      if (tag != null) 'tag': tag,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  static List<UniversityPickupPointModel> getMockPickupPoints() {
    return const [];
  }
}
