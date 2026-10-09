import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';

class MatchPoint {
  final double lat;
  final double lng;

  MatchPoint({
    required this.lat,
    required this.lng,
  });

  factory MatchPoint.fromJson(dynamic json) {
    if (json == null) return MatchPoint(lat: 0.0, lng: 0.0);
    try {
      if (json is MatchPoint) {
        return json;
      }
      if (json is List && json.length >= 2) {
        final a = (json[0] as num).toDouble();
        final b = (json[1] as num).toDouble();
        final corrected = MapBoundHelper.toCorrectLatLng(a, b);
        return MatchPoint(lat: corrected.latitude, lng: corrected.longitude);
      }
      if (json is Map) {
        if (json['coordinates'] is List && (json['coordinates'] as List).length >= 2) {
          final list = json['coordinates'] as List;
          final a = (list[0] as num).toDouble();
          final b = (list[1] as num).toDouble();
          final corrected = MapBoundHelper.toCorrectLatLng(a, b);
          return MatchPoint(lat: corrected.latitude, lng: corrected.longitude);
        }
        final rawLat = json['lat'] ?? json['latitude'] ?? json['latitud'];
        final rawLng = json['lng'] ?? json['longitude'] ?? json['long'] ?? json['lon'];
        if (rawLat != null && rawLng != null) {
          final a = (rawLat as num).toDouble();
          final b = (rawLng as num).toDouble();
          final corrected = MapBoundHelper.toCorrectLatLng(a, b);
          return MatchPoint(lat: corrected.latitude, lng: corrected.longitude);
        }
      }
      return MatchPoint(lat: 0.0, lng: 0.0);
    } catch (e) {
      print('Error parsing MatchPoint: $e');
      return MatchPoint(lat: 0.0, lng: 0.0);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}

