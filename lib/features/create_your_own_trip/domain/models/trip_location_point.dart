import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';

enum TripLocationType { pickup, destination }

class TripLocationPoint {
  final String id;
  String name;
  String address;
  double latitude;
  double longitude;
  TripLocationType type;
  int order;

  TripLocationPoint({
    required this.id,
    required this.name,
    this.address = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    required this.type,
    this.order = 1,
  });

  bool get isValid =>
      address.trim().isNotEmpty && latitude != 0.0 && longitude != 0.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'type': type == TripLocationType.pickup ? 'pickup' : 'destination',
      'order': order,
    };
  }

  factory TripLocationPoint.fromJson(Map<String, dynamic> json) {
    final rawLat = (json['latitude'] as num?)?.toDouble() ?? 0.0;
    final rawLng = (json['longitude'] as num?)?.toDouble() ?? 0.0;
    final corrected = MapBoundHelper.toCorrectLatLng(rawLat, rawLng);
    return TripLocationPoint(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: corrected.latitude != 0.0 ? corrected.latitude : rawLat,
      longitude: corrected.longitude != 0.0 ? corrected.longitude : rawLng,
      type: json['type'] == 'destination'
          ? TripLocationType.destination
          : TripLocationType.pickup,
      order: (json['order'] as num?)?.toInt() ?? 1,
    );
  }

  factory TripLocationPoint.fromStop(Map<String, dynamic> json) {
    final stopType = json['stop_type']?.toString().toLowerCase() ?? 'pickup';
    final rawLat = (json['latitude'] as num?)?.toDouble() ?? 0.0;
    final rawLng = (json['longitude'] as num?)?.toDouble() ?? 0.0;
    final corrected = MapBoundHelper.toCorrectLatLng(rawLat, rawLng);
    return TripLocationPoint(
      id: json['id']?.toString() ?? '',
      name: stopType == 'destination' ? 'Destination' : 'Pickup',
      address: json['address']?.toString() ?? '',
      latitude: corrected.latitude != 0.0 ? corrected.latitude : rawLat,
      longitude: corrected.longitude != 0.0 ? corrected.longitude : rawLng,
      type: stopType == 'destination'
          ? TripLocationType.destination
          : TripLocationType.pickup,
      order: (json['sort_order'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toLocationApiJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  TripLocationPoint copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    TripLocationType? type,
    int? order,
  }) {
    return TripLocationPoint(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      order: order ?? this.order,
    );
  }
}

typedef ScheduledRideLocation = TripLocationPoint;
typedef ScheduledRideStop = TripLocationPoint;
