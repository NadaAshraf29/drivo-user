import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TripDetailsInfoListWidget extends StatelessWidget {
  final dynamic trip;

  const TripDetailsInfoListWidget({
    super.key,
    required this.trip,
  });

  List<LatLng> _decodeEncodedPolyline(String encoded) {
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

      final p = MapBoundHelper.toCorrectLatLng(
          (lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }

  double _calculateDistanceKm(
      double lat1, double lon1, double lat2, double lon2) {
    final p1 = MapBoundHelper.toCorrectLatLng(lat1, lon1);
    final p2 = MapBoundHelper.toCorrectLatLng(lat2, lon2);
    const double p = 0.017453292519943295;
    double a = 0.5 -
        cos((p2.latitude - p1.latitude) * p) / 2 +
        cos(p1.latitude * p) *
            cos(p2.latitude * p) *
            (1 - cos((p2.longitude - p1.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(a.clamp(0.0, 1.0)));
  }

  double _getPolylineDistanceKm(List<LatLng> polyline) {
    if (polyline.length < 2) return 0.0;
    double total = 0.0;
    for (int i = 0; i < polyline.length - 1; i++) {
      total += _calculateDistanceKm(
        polyline[i].latitude,
        polyline[i].longitude,
        polyline[i + 1].latitude,
        polyline[i + 1].longitude,
      );
    }
    return total;
  }

  int _estimateDriveMinutes(double distanceKm, {bool isPolyline = false}) {
    if (distanceKm <= 0) return 5;
    final double roadKm = isPolyline ? distanceKm : (distanceKm * 1.4);

    double speedKmH;
    if (roadKm < 20) {
      speedKmH = 30.0;
    } else if (roadKm < 60) {
      speedKmH = 45.0;
    } else {
      speedKmH = 75.0;
    }

    int minutes = ((roadKm / speedKmH) * 60).round() + 5;
    return minutes < 5 ? 5 : minutes;
  }

  String _formatDuration(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int mins = totalMinutes % 60;
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else if (mins > 0) {
      return '$mins ${'min'.tr}';
    }
    return '--';
  }

  String _calculateDuration() {
    try {
      if (trip.encodedPolyline != null &&
          trip.encodedPolyline is String &&
          (trip.encodedPolyline as String).isNotEmpty) {
        final points = _decodeEncodedPolyline(trip.encodedPolyline as String);
        final polyDistanceKm = _getPolylineDistanceKm(points);
        if (polyDistanceKm > 0) {
          final minutes =
              _estimateDriveMinutes(polyDistanceKm, isPolyline: true);
          return _formatDuration(minutes);
        }
      }

      final double? pLat = (trip.pickupMatchPoint?.lat != null &&
              trip.pickupMatchPoint?.lat != 0)
          ? trip.pickupMatchPoint?.lat
          : trip.boardingPointStart?.latitude;
      final double? pLng = (trip.pickupMatchPoint?.lng != null &&
              trip.pickupMatchPoint?.lng != 0)
          ? trip.pickupMatchPoint?.lng
          : trip.boardingPointStart?.longitude;
      final double? dLat = (trip.dropoffMatchPoint?.lat != null &&
              trip.dropoffMatchPoint?.lat != 0)
          ? trip.dropoffMatchPoint?.lat
          : trip.boardingPointEnd?.latitude;
      final double? dLng = (trip.dropoffMatchPoint?.lng != null &&
              trip.dropoffMatchPoint?.lng != 0)
          ? trip.dropoffMatchPoint?.lng
          : trip.boardingPointEnd?.longitude;

      if (pLat != null &&
          pLng != null &&
          dLat != null &&
          dLng != null &&
          (pLat != 0 || pLng != 0) &&
          (dLat != 0 || dLng != 0)) {
        double straightKm = _calculateDistanceKm(pLat, pLng, dLat, dLng);
        if (straightKm > 0) {
          final minutes = _estimateDriveMinutes(straightKm, isPolyline: false);
          return _formatDuration(minutes);
        }
      }

      if (trip.estimatedTime != null &&
          trip.estimatedTime.toString().trim().isNotEmpty) {
        return trip.estimatedTime.toString().trim();
      }
      if (trip.duration != null &&
          trip.duration.toString().trim().isNotEmpty) {
        return trip.duration.toString().trim();
      }
    } catch (_) {}
    return '--';
  }

  @override
  Widget build(BuildContext context) {
    final int seatsLeft = trip.seatsAvailable ?? (trip.availableSeats ?? 2);
    final num price = trip.price ?? (trip.fare ?? 240);
    final String duration = _calculateDuration();

    return Row(
      children: [
        // Price per seat
        Expanded(
          child: _buildMetricTile(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: const Color(0xFF00A3EC),
            iconBg: const Color(0xFFE8F6FE),
            label: 'price_per_seat'.tr.isNotEmpty &&
                    !'price_per_seat'.tr.contains('price_per_seat')
                ? 'price_per_seat'.tr
                : 'Per seat',
            value: '$price ${'egp'.tr}',
          ),
        ),
        const SizedBox(width: 10),
        // Seats available
        Expanded(
          child: _buildMetricTile(
            icon: Icons.airline_seat_recline_normal_rounded,
            iconColor: const Color(0xFF2E7D32),
            iconBg: const Color(0xFFE8F5E9),
            label: 'seats_left'.tr.isNotEmpty &&
                    !'seats_left'.tr.contains('seats_left')
                ? 'seats_left'.tr
                : 'Seats left',
            value: '$seatsLeft',
          ),
        ),
        if (duration != '--') ...[
          const SizedBox(width: 10),
          // Estimated Duration
          Expanded(
            child: _buildMetricTile(
              icon: Icons.access_time_rounded,
              iconColor: const Color(0xFFF57C00),
              iconBg: const Color(0xFFFFF3E0),
              label: 'duration'.tr.isNotEmpty &&
                      !'duration'.tr.contains('duration')
                  ? 'duration'.tr
                  : 'Est. time',
              value: duration,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: textRegular.copyWith(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: textBold.copyWith(
              fontSize: 13,
              color: const Color(0xFF1E2432),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
