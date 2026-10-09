

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:ride_sharing_user_app/util/app_constants.dart';

class WalkingRouteResult {
  final List<LatLng> points;
  final double? distanceMeters;
  final double? durationSeconds;

  const WalkingRouteResult({
    required this.points,
    this.distanceMeters,
    this.durationSeconds,
  });
}

class RouteStop {
  final String? id;
  final String name;
  final LatLng location;
  final String? address;
  final String? time;

  const RouteStop({
    this.id,
    required this.name,
    required this.location,
    this.address,
    this.time,
  });

  factory RouteStop.fromDynamic(dynamic json, [int index = 1]) {
    String name = 'Stop $index';
    String? address;
    String? id;
    String? time;
    LatLng location = const LatLng(0, 0);

    if (json is RouteStop) return json;

    double? parseD(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    if (json is String && json.trim().startsWith('{')) {
      try {
        final decoded = jsonDecode(json);
        if (decoded is Map) {
          return RouteStop.fromDynamic(decoded, index);
        }
      } catch (_) {}
    }

    if (json is LatLng) {
      return RouteStop(
        name: name,
        location: MapBoundHelper.toCorrectLatLng(json.latitude, json.longitude),
      );
    }

    if (json is List && json.length >= 2) {
      final a = parseD(json[0]) ?? 0.0;
      final b = parseD(json[1]) ?? 0.0;
      return RouteStop(
        name: name,
        location: MapBoundHelper.toCorrectLatLng(a, b),
      );
    }

    if (json is Map) {
      if (json['rest_stop'] is Map) {
        return RouteStop.fromDynamic(json['rest_stop'], index);
      }
      id = json['id']?.toString() ??
          json['_id']?.toString() ??
          json['rest_stop_id']?.toString() ??
          json['stop_id']?.toString();
      name = json['name']?.toString() ??
          json['rest_stop_name']?.toString() ??
          json['place_name']?.toString() ??
          json['title']?.toString() ??
          json['stop_name']?.toString() ??
          json['address']?.toString() ??
          json['location_name']?.toString() ??
          'Stop $index';
      address = json['address']?.toString() ??
          json['area']?.toString() ??
          json['description']?.toString() ??
          json['location_address']?.toString();
      time = json['time']?.toString() ??
          json['pickup_time']?.toString() ??
          json['rest_time']?.toString() ??
          json['stop_time']?.toString() ??
          json['duration']?.toString();

      if (json['location'] is LatLng) {
        location = MapBoundHelper.toCorrectLatLng(
          (json['location'] as LatLng).latitude,
          (json['location'] as LatLng).longitude,
        );
      } else if (json['location'] is Map) {
        final locMap = json['location'] as Map;
        final locCoords = locMap['coordinates'];
        if (locCoords is List && locCoords.length >= 2) {
          final a = parseD(locCoords[0]) ?? 0.0;
          final b = parseD(locCoords[1]) ?? 0.0;
          location = MapBoundHelper.toCorrectLatLng(a, b);
        } else {
          final rawLat = locMap['lat'] ?? locMap['latitude'] ?? locMap['latitud'];
          final rawLng = locMap['lng'] ?? locMap['longitude'] ?? locMap['long'] ?? locMap['lon'];
          if (rawLat != null && rawLng != null) {
            final a = parseD(rawLat) ?? 0.0;
            final b = parseD(rawLng) ?? 0.0;
            location = MapBoundHelper.toCorrectLatLng(a, b);
          }
        }
      } else if (json['coordinates'] is List && (json['coordinates'] as List).length >= 2) {
        final list = json['coordinates'] as List;
        final a = parseD(list[0]) ?? 0.0;
        final b = parseD(list[1]) ?? 0.0;
        location = MapBoundHelper.toCorrectLatLng(a, b);
      } else {
        final rawLat = json['lat'] ?? json['latitude'] ?? json['latitud'];
        final rawLng = json['lng'] ?? json['longitude'] ?? json['long'] ?? json['lon'];
        if (rawLat != null && rawLng != null) {
          final a = parseD(rawLat) ?? 0.0;
          final b = parseD(rawLng) ?? 0.0;
          location = MapBoundHelper.toCorrectLatLng(a, b);
        }
      }
    } else {
      try {
        id = (json as dynamic).id?.toString() ?? (json as dynamic).sId?.toString();
      } catch (_) {}
      try {
        name = (json as dynamic).name?.toString() ??
            (json as dynamic).placeName?.toString() ??
            (json as dynamic).title?.toString() ??
            (json as dynamic).stopName?.toString() ??
            'Stop $index';
      } catch (_) {}
      try {
        address = (json as dynamic).address?.toString();
      } catch (_) {}
      try {
        time = (json as dynamic).time?.toString();
      } catch (_) {}
      try {
        final rawLat = (json as dynamic).latitude ?? (json as dynamic).lat;
        final rawLng = (json as dynamic).longitude ?? (json as dynamic).lng;
        if (rawLat != null && rawLng != null) {
          final a = parseD(rawLat) ?? 0.0;
          final b = parseD(rawLng) ?? 0.0;
          location = MapBoundHelper.toCorrectLatLng(a, b);
        }
      } catch (_) {}
    }

    return RouteStop(
      id: id,
      name: name,
      location: location,
      address: address,
      time: time,
    );
  }
}

class MapBoundHelper {
  static LatLng toCorrectLatLng(double a, double b) {
    if (a == 0.0 && b == 0.0) return const LatLng(0.0, 0.0);

    // 1. Greater Cairo / Tagamoa / New Cairo / Giza / Sheikh Zayed / 6th of October / Delta / Suez region:
    // Latitude is always ~29.0 - 30.6; Longitude is always ~30.65 - 33.5. (Lat < Lng)
    // Sheikh Zayed: Lat ~29.95 - 30.15, Lng ~30.85 - 31.05
    // 6th of October: Lat ~29.85 - 30.05, Lng ~30.80 - 31.05
    if (a >= 29.0 && a <= 30.6 && b >= 30.65 && b <= 33.5) {
      return LatLng(a, b);
    }
    if (b >= 29.0 && b <= 30.6 && a >= 30.65 && a <= 33.5) {
      return LatLng(b, a);
    }

    // 2. Alexandria City:
    // Latitude is always ~31.1 - 31.5; Longitude is always ~29.5 - 30.4. (Lat > Lng)
    if (a >= 31.1 && a <= 31.5 && b >= 29.5 && b <= 30.4) {
      return LatLng(a, b);
    }
    if (b >= 31.1 && b <= 31.5 && a >= 29.5 && a <= 30.4) {
      return LatLng(b, a);
    }

    // 3. North Coast / Sahel / Alamein / Sidi Abdel Rahman / Ras El Hekma / Matrouh:
    // Latitude is always ~30.8 - 31.5; Longitude is always ~26.0 - 29.4. (Lat > Lng)
    if (a >= 30.8 && a <= 31.5 && b >= 26.0 && b <= 29.4) {
      return LatLng(a, b);
    }
    if (b >= 30.8 && b <= 31.5 && a >= 26.0 && a <= 29.4) {
      return LatLng(b, a);
    }

    // 4. Upper Egypt / Red Sea / Sinai / Hurghada / Sharm El Sheikh / Luxor / Aswan:
    // Latitude is always ~22.0 - 29.5; Longitude is always ~30.0 - 37.0. (Lat < Lng)
    if (a >= 22.0 && a <= 29.5 && b >= 30.0 && b <= 37.0) {
      return LatLng(a, b);
    }
    if (b >= 22.0 && b <= 29.5 && a >= 30.0 && a <= 37.0) {
      return LatLng(b, a);
    }

    // 5. Boundary Fallbacks:
    // If one coordinate is > 31.8, it MUST be Longitude in Egypt.
    if (a > 31.8 && b >= 22.0 && b <= 31.8) {
      return LatLng(b, a);
    }
    if (b > 31.8 && a >= 22.0 && a <= 31.8) {
      return LatLng(a, b);
    }

    // If one coordinate is < 26.0, it MUST be Latitude (Upper Egypt).
    if (a < 26.0 && a >= 22.0 && b >= 26.0 && b <= 37.0) {
      return LatLng(a, b);
    }
    if (b < 26.0 && b >= 22.0 && a >= 26.0 && a <= 37.0) {
      return LatLng(b, a);
    }

    // 6. General Egypt Fallback:
    if (a >= 22.0 && a <= 32.0 && b >= 25.0 && b <= 37.0) {
      return LatLng(a, b);
    }
    if (b >= 22.0 && b <= 32.0 && a >= 25.0 && a <= 37.0) {
      return LatLng(b, a);
    }

    return LatLng(a, b);
  }

  static double boundMapArea(double? circle) {
    double zoomLevel = 16;
    if (circle != null) {
      double radius = circle + circle / 2;
      double scale = radius / 400;
      zoomLevel = (16 - scale / 2);
    }
    return zoomLevel;
  }

  static LatLngBounds computeBounds(List<LatLng> points) {
    if (points.isEmpty) {
      return LatLngBounds(
        southwest: const LatLng(0, 0),
        northeast: const LatLng(0, 0),
      );
    }
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  static List<LatLng> decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      final pLat = lat / 1E5;
      final pLng = lng / 1E5;
      poly.add(toCorrectLatLng(pLat, pLng));
    }
    return poly;
  }

  static LatLng? _extractLatLngFromDynamic(dynamic coord) {
    if (coord == null) return null;
    try {
      if (coord is LatLng) {
        return toCorrectLatLng(coord.latitude, coord.longitude);
      }
      if (coord is List && coord.length >= 2) {
        final a = (coord[0] as num).toDouble();
        final b = (coord[1] as num).toDouble();
        if (a != 0.0 || b != 0.0) {
          return toCorrectLatLng(a, b);
        }
      }
      if (coord is Map) {
        if (coord['coordinates'] is List && (coord['coordinates'] as List).length >= 2) {
          final list = coord['coordinates'] as List;
          final lng = (list[0] as num).toDouble();
          final lat = (list[1] as num).toDouble();
          if (lat != 0.0 || lng != 0.0) {
            return toCorrectLatLng(lat, lng);
          }
        }
        final rawLat = coord['lat'] ?? coord['latitude'] ?? coord['latitud'];
        final rawLng = coord['lng'] ?? coord['longitude'] ?? coord['long'] ?? coord['lon'];
        if (rawLat != null && rawLng != null) {
          final a = (rawLat as num).toDouble();
          final b = (rawLng as num).toDouble();
          if (a != 0.0 || b != 0.0) {
            return toCorrectLatLng(a, b);
          }
        }
      }
      // Object property access
      final dynamic latProp = (coord as dynamic).lat ?? (coord as dynamic).latitude;
      final dynamic lngProp = (coord as dynamic).lng ?? (coord as dynamic).longitude;
      if (latProp != null && lngProp != null) {
        final a = (latProp as num).toDouble();
        final b = (lngProp as num).toDouble();
        if (a != 0.0 || b != 0.0) {
          return toCorrectLatLng(a, b);
        }
      }
    } catch (_) {}

    try {
      if ((coord as dynamic).coordinates != null &&
          (coord as dynamic).coordinates is List &&
          ((coord as dynamic).coordinates as List).length >= 2) {
        final list = (coord as dynamic).coordinates as List;
        final lng = (list[0] as num).toDouble();
        final lat = (list[1] as num).toDouble();
        if (lat != 0.0 || lng != 0.0) {
          return toCorrectLatLng(lat, lng);
        }
      }
    } catch (_) {}

    return null;
  }

  static LatLng? _extractStartLatLngFromDynamic(dynamic coord) {
    if (coord == null) return null;
    try {
      if (coord is LatLng) {
        return toCorrectLatLng(coord.latitude, coord.longitude);
      }
      if (coord is List && coord.length >= 2) {
        final a = (coord[0] as num).toDouble();
        final b = (coord[1] as num).toDouble();
        if (a != 0.0 || b != 0.0) {
          return toCorrectLatLng(a, b);
        }
      }
      if (coord is Map) {
        if (coord['coordinates'] is List && (coord['coordinates'] as List).length >= 2) {
          final list = coord['coordinates'] as List;
          final lat = (list[0] as num).toDouble();
          final lng = (list[1] as num).toDouble();
          if (lat != 0.0 || lng != 0.0) {
            return toCorrectLatLng(lat, lng);
          }
        }
        final rawLat = coord['lat'] ?? coord['latitude'] ?? coord['latitud'];
        final rawLng = coord['lng'] ?? coord['longitude'] ?? coord['long'] ?? coord['lon'];
        if (rawLat != null && rawLng != null) {
          final a = (rawLat as num).toDouble();
          final b = (rawLng as num).toDouble();
          if (a != 0.0 || b != 0.0) {
            return toCorrectLatLng(b, a);
          }
        }
      }
      final dynamic coords = (coord as dynamic).coordinates;
      if (coords is List && coords.length >= 2) {
        final lat = (coords[0] as num).toDouble();
        final lng = (coords[1] as num).toDouble();
        if (lat != 0.0 || lng != 0.0) {
          return toCorrectLatLng(lat, lng);
        }
      }
      final dynamic latProp = (coord as dynamic).lat ?? (coord as dynamic).latitude;
      final dynamic lngProp = (coord as dynamic).lng ?? (coord as dynamic).longitude;
      if (latProp != null && lngProp != null) {
        final a = (latProp as num).toDouble();
        final b = (lngProp as num).toDouble();
        if (a != 0.0 || b != 0.0) {
          return toCorrectLatLng(b, a);
        }
      }
    } catch (_) {}

    return null;
  }

  static LatLng? getDriverStart(dynamic trip, [List<LatLng>? fallbackPolyline]) {
    if (trip == null) {
      return (fallbackPolyline != null && fallbackPolyline.isNotEmpty)
          ? fallbackPolyline.first
          : null;
    }

    try {
      final p1 = _extractStartLatLngFromDynamic((trip as dynamic).routeStartPoint);
      if (p1 != null) return p1;
    } catch (_) {}

    try {
      final p2 = _extractStartLatLngFromDynamic((trip as dynamic).startCoordinates);
      if (p2 != null) return p2;
    } catch (_) {}

    try {
      if (trip is Map) {
        final p3 = _extractStartLatLngFromDynamic(
          trip['route_start_point'] ??
              trip['driver_start_point'] ??
              trip['driver_start_location'] ??
              trip['start_coordinates'] ??
              trip['start_location'] ??
              trip['pickup_coordinates'],
        );
        if (p3 != null) return p3;
      }
    } catch (_) {}

    try {
      final p4 = _extractLatLngFromDynamic((trip as dynamic).pickupCoordinates);
      if (p4 != null) return p4;
    } catch (_) {}

    if (fallbackPolyline != null && fallbackPolyline.isNotEmpty) {
      return fallbackPolyline.first;
    }

    return null;
  }

  static LatLng? getDriverEnd(dynamic trip, [List<LatLng>? fallbackPolyline]) {
    if (trip == null) {
      return (fallbackPolyline != null && fallbackPolyline.isNotEmpty)
          ? fallbackPolyline.last
          : null;
    }

    try {
      final p1 = _extractLatLngFromDynamic((trip as dynamic).routeEndPoint);
      if (p1 != null) return p1;
    } catch (_) {}

    try {
      final p2 = _extractLatLngFromDynamic((trip as dynamic).endCoordinates);
      if (p2 != null) return p2;
    } catch (_) {}

    try {
      if (trip is Map) {
        final p3 = _extractLatLngFromDynamic(
          trip['route_end_point'] ??
              trip['driver_end_point'] ??
              trip['driver_end_location'] ??
              trip['end_coordinates'] ??
              trip['end_location'] ??
              trip['destination_coordinates'],
        );
        if (p3 != null) return p3;
      }
    } catch (_) {}

    try {
      final p4 = _extractLatLngFromDynamic((trip as dynamic).destinationCoordinates);
      if (p4 != null) return p4;
    } catch (_) {}

    if (fallbackPolyline != null && fallbackPolyline.isNotEmpty) {
      return fallbackPolyline.last;
    }

    return null;
  }

  static LatLng? getPassengerPickup(dynamic trip) {
    if (trip == null) return null;

    try {
      final p0 = _extractStartLatLngFromDynamic((trip as dynamic).customerRequestCoordinates);
      if (p0 != null) return p0;
    } catch (_) {}

    try {
      final p1 = _extractStartLatLngFromDynamic((trip as dynamic).pickupCoordinates);
      if (p1 != null) return p1;
    } catch (_) {}

    try {
      final p2 = _extractStartLatLngFromDynamic((trip as dynamic).closestPcikupPoint);
      if (p2 != null) return p2;
    } catch (_) {}

    try {
      final p3 = _extractLatLngFromDynamic((trip as dynamic).boardingPointStart);
      if (p3 != null) return p3;
    } catch (_) {}

    try {
      final p4 = _extractLatLngFromDynamic((trip as dynamic).pickupMatchPoint);
      if (p4 != null) return p4;
    } catch (_) {}

    try {
      if (trip is Map) {
        final p5 = _extractStartLatLngFromDynamic(
          trip['customer_request_coordinates'] ??
              trip['pickup_coordinates'] ??
              trip['closest_pickup_point'] ??
              trip['passenger_pickup'],
        );
        if (p5 != null) return p5;
      }
    } catch (_) {}

    return null;
  }

  static LatLng? getPassengerDropoff(dynamic trip) {
    if (trip == null) return null;

    try {
      final p1 = _extractLatLngFromDynamic((trip as dynamic).boardingPointEnd);
      if (p1 != null) return p1;
    } catch (_) {}

    try {
      final p2 = _extractLatLngFromDynamic((trip as dynamic).dropoffMatchPoint);
      if (p2 != null) return p2;
    } catch (_) {}

    try {
      if (trip is Map) {
        final p3 = _extractLatLngFromDynamic(
          trip['boarding_point_end'] ??
              trip['dropoff_match_point'] ??
              trip['passenger_dropoff'],
        );
        if (p3 != null) return p3;
      }
    } catch (_) {}

    return null;
  }

  static List<RouteStop> getDriverStops(dynamic trip) {
    if (trip == null) return [];
    List<RouteStop> result = [];

    void extractFromList(dynamic list) {
      if (list == null) return;
      if (list is String && list.trim().startsWith('[')) {
        try {
          final decoded = jsonDecode(list);
          extractFromList(decoded);
          return;
        } catch (_) {}
      }
      if (list is List && list.isNotEmpty) {
        for (int i = 0; i < list.length; i++) {
          try {
            final item = list[i];
            final stop = RouteStop.fromDynamic(item, result.length + 1);
            if (stop.location.latitude != 0.0 || stop.location.longitude != 0.0) {
              if (!result.any((s) =>
                  (s.location.latitude - stop.location.latitude).abs() < 0.0001 &&
                  (s.location.longitude - stop.location.longitude).abs() < 0.0001)) {
                result.add(stop);
              }
            }
          } catch (_) {}
        }
      }
    }

    void extractSingle(dynamic item, [String? fallbackName]) {
      if (item == null) return;
      try {
        final stop = RouteStop.fromDynamic(item, result.length + 1);
        if (stop.location.latitude != 0.0 || stop.location.longitude != 0.0) {
          if (!result.any((s) =>
              (s.location.latitude - stop.location.latitude).abs() < 0.0001 &&
              (s.location.longitude - stop.location.longitude).abs() < 0.0001)) {
            result.add(fallbackName != null && stop.name.startsWith('Stop ')
                ? RouteStop(
                    id: stop.id,
                    name: fallbackName,
                    location: stop.location,
                    address: stop.address,
                    time: stop.time,
                  )
                : stop);
          }
        }
      } catch (_) {}
    }

    try {
      extractFromList((trip as dynamic).restStops);
    } catch (_) {}

    try {
      extractFromList((trip as dynamic).rest_stops);
    } catch (_) {}

    try {
      extractFromList((trip as dynamic).driverRestStops);
    } catch (_) {}

    try {
      extractFromList((trip as dynamic).driverStops);
    } catch (_) {}

    try {
      extractFromList((trip as dynamic).stops);
    } catch (_) {}

    try {
      extractFromList((trip as dynamic).stopPoints);
    } catch (_) {}

    try {
      extractFromList((trip as dynamic).stopsPoints);
    } catch (_) {}

    try {
      extractFromList((trip as dynamic).routeStops);
    } catch (_) {}

    try {
      extractFromList((trip as dynamic).boardingPoints);
    } catch (_) {}

    try {
      extractFromList((trip as dynamic).intermediateAddresses);
    } catch (_) {}

    try {
      extractFromList((trip as dynamic).intermediateCoordinates);
    } catch (_) {}

    try {
      extractSingle((trip as dynamic).boardingPointStart, 'Boarding Point');
    } catch (_) {}

    try {
      extractSingle((trip as dynamic).boardingPointEnd, 'Dropoff Point');
    } catch (_) {}

    try {
      extractSingle((trip as dynamic).closestPickup, 'Pickup Spot');
    } catch (_) {}

    try {
      extractSingle((trip as dynamic).closestDropoff, 'Dropoff Spot');
    } catch (_) {}

    if (trip is Map) {
      extractFromList(trip['rest_stops']);
      extractFromList(trip['restStops']);
      extractFromList(trip['driver_rest_stops']);
      extractFromList(trip['driver_stops']);
      extractFromList(trip['stops']);
      extractFromList(trip['stop_points']);
      extractFromList(trip['stops_points']);
      extractFromList(trip['route_stops']);
      extractFromList(trip['boarding_points']);
      extractFromList(trip['intermediate_addresses']);
      extractFromList(trip['intermediate_coordinates']);
      extractFromList(trip['waypoints']);
      extractSingle(trip['boarding_point_start'], 'Boarding Point');
      extractSingle(trip['boarding_point_end'], 'Dropoff Point');
      extractSingle(trip['closest_pickup'], 'Pickup Spot');
      extractSingle(trip['closest_dropoff'], 'Dropoff Spot');
    }

    final start = getDriverStart(trip);
    final end = getDriverEnd(trip);
    if (start != null || end != null) {
      result.removeWhere((s) {
        if (start != null &&
            (s.location.latitude - start.latitude).abs() < 0.00015 &&
            (s.location.longitude - start.longitude).abs() < 0.00015) {
          return true;
        }
        if (end != null &&
            (s.location.latitude - end.latitude).abs() < 0.00015 &&
            (s.location.longitude - end.longitude).abs() < 0.00015) {
          return true;
        }
        return false;
      });
    }

    return result;
  }

  static final Map<String, List<LatLng>> _driverActualRouteCache = {};

  static String getTripIdentifier(dynamic trip) {
    if (trip == null) return '';
    try {
      final id = (trip as dynamic).routeId ??
          (trip as dynamic).id ??
          (trip as dynamic).rideId;
      if (id != null && id.toString().isNotEmpty && id.toString() != '0') {
        return id.toString();
      }
    } catch (_) {}
    if (trip is Map) {
      final id = trip['route_id'] ?? trip['id'] ?? trip['ride_id'];
      if (id != null && id.toString().isNotEmpty && id.toString() != '0') {
        return id.toString();
      }
    }
    return '';
  }

  static bool routeVisitsAllStops(List<LatLng> polyline, List<RouteStop> stops) {
    if (polyline.isEmpty || stops.isEmpty) return false;
    for (final stop in stops) {
      if (stop.location.latitude == 0.0 && stop.location.longitude == 0.0) {
        continue;
      }
      double minDistance = double.infinity;
      for (int i = 0; i < polyline.length - 1; i++) {
        final candidate =
            nearestPointOnSegment(stop.location, polyline[i], polyline[i + 1]);
        final d = Geolocator.distanceBetween(
          stop.location.latitude,
          stop.location.longitude,
          candidate.latitude,
          candidate.longitude,
        );
        if (d < minDistance) {
          minDistance = d;
          if (minDistance <= 350) break;
        }
      }
      if (minDistance > 350) {
        return false;
      }
    }
    return true;
  }

  static Future<List<LatLng>> getActualDriverRoute(dynamic trip) async {
    if (trip == null) return [];

    final String tripKey = getTripIdentifier(trip);
    if (tripKey.isNotEmpty && _driverActualRouteCache.containsKey(tripKey)) {
      final cached = _driverActualRouteCache[tripKey]!;
      if (cached.isNotEmpty) return cached;
    }

    final driverStops = getDriverStops(trip);
    final initialPoly = getRoutePolylinePoints(trip);
    final driverStart = getDriverStart(trip, initialPoly);
    final driverEnd = getDriverEnd(trip, initialPoly);

    if (driverStops.isEmpty) {
      if (initialPoly.length > 2) {
        if (tripKey.isNotEmpty) _driverActualRouteCache[tripKey] = initialPoly;
        return initialPoly;
      }
      if (driverStart != null && driverEnd != null) {
        final route = await getDrivingRoute(driverStart, driverEnd);
        if (route.length >= 2) {
          if (tripKey.isNotEmpty) _driverActualRouteCache[tripKey] = route;
          return route;
        }
      }
      return initialPoly;
    }

    // Check if initial polyline already visits all stops
    if (initialPoly.length > 2 && routeVisitsAllStops(initialPoly, driverStops)) {
      if (tripKey.isNotEmpty) _driverActualRouteCache[tripKey] = initialPoly;
      return initialPoly;
    }

    // Initial polyline does NOT visit all stops! Generate route that drives to every stop
    if (driverStart != null && driverEnd != null) {
      final List<LatLng> stopWaypoints =
          driverStops.map((s) => s.location).toList();
      final route = await getDrivingRoute(
        driverStart,
        driverEnd,
        waypoints: stopWaypoints,
      );
      if (route.length >= 2) {
        if (tripKey.isNotEmpty) _driverActualRouteCache[tripKey] = route;
        return route;
      }
    }

    if (driverStart != null && driverEnd != null && driverStops.isNotEmpty) {
      final fallback = [
        driverStart,
        ...driverStops.map((s) => s.location),
        driverEnd,
      ];
      if (tripKey.isNotEmpty) _driverActualRouteCache[tripKey] = fallback;
      return fallback;
    }

    return initialPoly;
  }

  static List<LatLng> getRoutePolylinePoints(dynamic trip) {
    if (trip == null) return [];

    final String tripKey = getTripIdentifier(trip);
    if (tripKey.isNotEmpty && _driverActualRouteCache.containsKey(tripKey)) {
      final cached = _driverActualRouteCache[tripKey]!;
      if (cached.isNotEmpty) return cached;
    }

    String? encoded;
    try {
      encoded = (trip as dynamic).encodedPolyline?.toString();
    } catch (_) {}

    if (encoded == null || encoded.isEmpty) {
      try {
        encoded = (trip as dynamic).passengerPolyline?.toString();
      } catch (_) {}
    }

    if (encoded == null || encoded.isEmpty) {
      try {
        if (trip is Map) {
          encoded = (trip['encoded_polyline'] ??
                  trip['driver_encoded_polyline'] ??
                  trip['driver_polyline'] ??
                  trip['route_polyline'] ??
                  trip['full_encoded_polyline'] ??
                  trip['full_polyline'] ??
                  trip['passenger_polyline'])
              ?.toString();
        }
      } catch (_) {}
    }

    List<LatLng> points = [];
    if (encoded != null && encoded.isNotEmpty) {
      points = decodePolyline(encoded);
    }

    final driverStart = getDriverStart(trip);
    final driverEnd = getDriverEnd(trip);

    if (points.isNotEmpty) {
      if (driverStart != null) {
        final dist = Geolocator.distanceBetween(
          driverStart.latitude,
          driverStart.longitude,
          points.first.latitude,
          points.first.longitude,
        );
        if (dist > 50) {
          points.insert(0, driverStart);
        } else {
          points[0] = driverStart;
        }
      }
      if (driverEnd != null) {
        final dist = Geolocator.distanceBetween(
          driverEnd.latitude,
          driverEnd.longitude,
          points.last.latitude,
          points.last.longitude,
        );
        if (dist > 50) {
          points.add(driverEnd);
        } else {
          points[points.length - 1] = driverEnd;
        }
      }
      return points;
    }

    final passengerStart = getPassengerPickup(trip);
    final passengerEnd = getPassengerDropoff(trip);

    final startPt = driverStart ?? passengerStart;
    final endPt = driverEnd ?? passengerEnd;

    final driverStops = getDriverStops(trip);
    if (startPt != null && endPt != null) {
      if (driverStops.isNotEmpty) {
        return [
          startPt,
          ...driverStops.map((s) => s.location),
          endPt,
        ];
      }
      if ((startPt.latitude - endPt.latitude).abs() > 0.00001 ||
          (startPt.longitude - endPt.longitude).abs() > 0.00001) {
        return [startPt, endPt];
      }
    }

    return [];
  }

  static LatLng findClosestPointOnRoute(LatLng target, List<LatLng> polyline) {
    if (polyline.isEmpty) return target;
    if (polyline.length == 1) return polyline.first;

    final correctedTarget = toCorrectLatLng(target.latitude, target.longitude);
    LatLng nearest = polyline.first;
    double minDistance = double.infinity;

    for (int i = 0; i < polyline.length - 1; i++) {
      final p1 = polyline[i];
      final p2 = polyline[i + 1];
      final candidate = nearestPointOnSegment(correctedTarget, p1, p2);
      final distance = Geolocator.distanceBetween(
        correctedTarget.latitude,
        correctedTarget.longitude,
        candidate.latitude,
        candidate.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearest = candidate;
      }
    }

    return nearest;
  }

  static LatLng nearestPointOnSegment(LatLng point, LatLng start, LatLng end) {
    final lat1 = start.latitude;
    final lon1 = start.longitude;
    final lat2 = end.latitude;
    final lon2 = end.longitude;
    final pLat = point.latitude;
    final pLon = point.longitude;

    if ((lat1 - lat2).abs() < 0.000001 && (lon1 - lon2).abs() < 0.000001) {
      return start;
    }

    final double midLatRad = ((lat1 + lat2) / 2.0) * (pi / 180.0);
    final double cosLat = cos(midLatRad);

    final double dx = (lon2 - lon1) * cosLat;
    final double dy = lat2 - lat1;
    final double segLenSq = dx * dx + dy * dy;

    if (segLenSq == 0) return start;

    final double px = (pLon - lon1) * cosLat;
    final double py = pLat - lat1;

    final double t = ((px * dx) + (py * dy)) / segLenSq;
    final double clampedT = t.clamp(0.0, 1.0);

    return LatLng(
      lat1 + clampedT * (lat2 - lat1),
      lon1 + clampedT * (lon2 - lon1),
    );
  }

  static Future<WalkingRouteResult> getWalkingRoute(
    LatLng origin,
    LatLng destination,
  ) async {
    final cOrigin = toCorrectLatLng(origin.latitude, origin.longitude);
    final cDest = toCorrectLatLng(destination.latitude, destination.longitude);

    final straightDist = Geolocator.distanceBetween(
      cOrigin.latitude,
      cOrigin.longitude,
      cDest.latitude,
      cDest.longitude,
    );

    if (straightDist < 25) {
      return WalkingRouteResult(
        points: [cOrigin, cDest],
        distanceMeters: straightDist,
        durationSeconds: straightDist / 1.33,
      );
    }

    // Pedestrian walking estimation parameters:
    // Average city walking speed = 4.8 km/h = 80 meters/minute = ~1.33 m/s
    // Pedestrians walk on sidewalks, paths, and crossways: direct street distance is ~1.15x straight distance.
    final double realisticWalkDist = straightDist * 1.15;
    final double realisticWalkDurationSec = realisticWalkDist / 1.33;

    // 1. Try OSRM foot/walking routing (real street walkways & sidewalks)
    try {
      final osrmFootUrl = Uri.parse(
        'https://router.project-osrm.org/route/v1/foot/'
        '${cOrigin.longitude},${cOrigin.latitude};${cDest.longitude},${cDest.latitude}'
        '?overview=full&geometries=polyline',
      );
      final response =
          await http.get(osrmFootUrl).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'Ok' && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final String? geometry = route['geometry'];
          final num? dist = route['distance'];
          if (geometry != null && geometry.isNotEmpty) {
            final pts = decodePolyline(geometry);
            if (pts.length >= 2) {
              final double routeDist = (dist != null && dist > 0)
                  ? dist.toDouble()
                  : realisticWalkDist;
              // Accept route only if it's within a realistic pedestrian factor (<= 1.5x straight distance)
              if (routeDist <= straightDist * 1.5) {
                return WalkingRouteResult(
                  points: pts,
                  distanceMeters: routeDist,
                  durationSeconds: routeDist / 1.33,
                );
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('OSRM foot routing error: $e');
    }

    // 2. Try Google Maps Directions API with mode=walking
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${cOrigin.latitude},${cOrigin.longitude}'
        '&destination=${cDest.latitude},${cDest.longitude}'
        '&mode=walking'
        '&key=${AppConstants.mapKey}',
      );
      final response =
          await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final polyline = route['overview_polyline']['points'];
          final pts = decodePolyline(polyline);
          if (pts.length >= 2) {
            final leg =
                (route['legs'] as List).isNotEmpty ? route['legs'][0] : null;
            final num? dist = leg?['distance']?['value'];
            final num? dur = leg?['duration']?['value'];
            final double distanceMeters = (dist != null && dist > 0)
                ? dist.toDouble()
                : realisticWalkDist;
            if (distanceMeters <= straightDist * 1.5) {
              final double durationSec = (dur != null && dur > 0)
                  ? dur.toDouble()
                  : (distanceMeters / 1.33);
              return WalkingRouteResult(
                points: pts,
                distanceMeters: distanceMeters,
                durationSeconds: durationSec,
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Google walking route error: $e');
    }

    // 3. Fallback: Multi-step direct street grid path with realistic pedestrian distance & duration
    final mid1 = LatLng(cOrigin.latitude, (cOrigin.longitude + cDest.longitude) / 2);
    final mid2 = LatLng(cDest.latitude, (cOrigin.longitude + cDest.longitude) / 2);
    return WalkingRouteResult(
      points: [cOrigin, mid1, mid2, cDest],
      distanceMeters: realisticWalkDist,
      durationSeconds: realisticWalkDurationSec,
    );
  }

  static Future<List<LatLng>> getDrivingRoute(
    LatLng origin,
    LatLng destination, {
    List<LatLng>? waypoints,
  }) async {
    final cOrigin = toCorrectLatLng(origin.latitude, origin.longitude);
    final cDest = toCorrectLatLng(destination.latitude, destination.longitude);

    final straightDist = Geolocator.distanceBetween(
      cOrigin.latitude,
      cOrigin.longitude,
      cDest.latitude,
      cDest.longitude,
    );

    if (straightDist < 25) {
      return [cOrigin, cDest];
    }

    // Filter valid distinct waypoints (not too close to origin or dest)
    final List<LatLng> validWaypoints = [];
    if (waypoints != null && waypoints.isNotEmpty) {
      for (final wp in waypoints) {
        final cWp = toCorrectLatLng(wp.latitude, wp.longitude);
        final dOrig = Geolocator.distanceBetween(
          cWp.latitude,
          cWp.longitude,
          cOrigin.latitude,
          cOrigin.longitude,
        );
        final dDest = Geolocator.distanceBetween(
          cWp.latitude,
          cWp.longitude,
          cDest.latitude,
          cDest.longitude,
        );
        if (dOrig > 50 && dDest > 50) {
          if (!validWaypoints.any((p) =>
              Geolocator.distanceBetween(
                p.latitude,
                p.longitude,
                cWp.latitude,
                cWp.longitude,
              ) < 30)) {
            validWaypoints.add(cWp);
          }
        }
      }
    }

    // 1. Try OSRM driving service (full turn-by-turn road geometry)
    try {
      final List<String> coordStrings = [
        '${cOrigin.longitude},${cOrigin.latitude}',
        ...validWaypoints.map((w) => '${w.longitude},${w.latitude}'),
        '${cDest.longitude},${cDest.latitude}',
      ];
      final osrmUrl = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${coordStrings.join(';')}'
        '?overview=full&geometries=polyline',
      );
      final response =
          await http.get(osrmUrl).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'Ok' && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final String? geometry = route['geometry'];
          if (geometry != null && geometry.isNotEmpty) {
            final pts = decodePolyline(geometry);
            if (pts.length >= 2) {
              return pts;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('OSRM driving route error: $e');
    }

    // 2. Try Google Maps Directions API (mode=driving)
    try {
      String waypointsParam = '';
      if (validWaypoints.isNotEmpty) {
        final wpStr = validWaypoints
            .map((w) => '${w.latitude},${w.longitude}')
            .join('|');
        waypointsParam = '&waypoints=$wpStr';
      }
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${cOrigin.latitude},${cOrigin.longitude}'
        '&destination=${cDest.latitude},${cDest.longitude}'
        '$waypointsParam'
        '&mode=driving'
        '&key=${AppConstants.mapKey}',
      );
      final response =
          await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final polyline = route['overview_polyline']?['points'];
          if (polyline != null && (polyline as String).isNotEmpty) {
            final pts = decodePolyline(polyline);
            if (pts.length >= 2) {
              return pts;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Google driving route error: $e');
    }

    // Fallback: return waypoint sequence
    return [cOrigin, ...validWaypoints, cDest];
  }
}