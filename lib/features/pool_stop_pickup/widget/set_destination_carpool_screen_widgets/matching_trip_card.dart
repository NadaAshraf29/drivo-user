import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/pool_ride_model.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class MatchingTripCard extends StatelessWidget {
  final PoolRide ride;
  final int index;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback? onViewDetails;

  const MatchingTripCard({
    super.key,
    required this.ride,
    required this.index,
    required this.isSelected,
    required this.onSelect,
    this.onViewDetails,
  });

  DateTime? _parseDateTime(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    String str = val.toString().trim();
    if (str.isEmpty) return null;
    DateTime? dt = DateTime.tryParse(str);
    if (dt != null) return dt;

    try {
      return DateFormat('yyyy-MM-dd HH:mm:ss').parse(str);
    } catch (_) {}

    try {
      final now = DateTime.now();
      String cleanStr = str.toUpperCase();
      bool isPm = cleanStr.contains('PM');
      bool isAm = cleanStr.contains('AM');
      cleanStr = cleanStr.replaceAll('AM', '').replaceAll('PM', '').trim();

      final parts = cleanStr.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1].split(' ')[0]);
        if (isPm && hour < 12) hour += 12;
        if (isAm && hour == 12) hour = 0;
        return DateTime(now.year, now.month, now.day, hour, minute);
      }
    } catch (_) {}
    return null;
  }

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

      final p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }

  double _calculateDistanceKm(
      double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295;
    double a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
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
    // If straight-line, apply a 1.4x road curvature detour factor
    final double roadKm = isPolyline ? distanceKm : (distanceKm * 1.4);

    double speedKmH;
    if (roadKm < 20) {
      speedKmH = 30.0; // Cairo urban traffic speed (~25-35 km/h)
    } else if (roadKm < 60) {
      speedKmH = 45.0; // Ring road / highways (~40-50 km/h)
    } else {
      speedKmH = 75.0; // Intercity (~70-80 km/h)
    }

    int minutes = ((roadKm / speedKmH) * 60).round() + 5; // +5 mins buffer for traffic lights/stops
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

  String _calculateDuration(PoolRide ride) {
    try {
      // 1. If encodedPolyline is available, compute the true road distance
      if (ride.encodedPolyline != null && ride.encodedPolyline!.isNotEmpty) {
        final points = _decodeEncodedPolyline(ride.encodedPolyline!);
        final polyDistanceKm = _getPolylineDistanceKm(points);
        if (polyDistanceKm > 0) {
          final minutes = _estimateDriveMinutes(polyDistanceKm, isPolyline: true);
          return _formatDuration(minutes);
        }
      }

      // 2. Estimate from coordinates with realistic road factor & urban traffic speed
      final double? pLat = (ride.pickupMatchPoint.lat != 0)
          ? ride.pickupMatchPoint.lat
          : (ride.boardingPointStart?.latitude != null ? double.tryParse(ride.boardingPointStart!.latitude.toString()) : null);
      final double? pLng = (ride.pickupMatchPoint.lng != 0)
          ? ride.pickupMatchPoint.lng
          : (ride.boardingPointStart?.longitude != null ? double.tryParse(ride.boardingPointStart!.longitude.toString()) : null);
      final double? dLat = (ride.dropoffMatchPoint.lat != 0)
          ? ride.dropoffMatchPoint.lat
          : (ride.boardingPointEnd?.latitude != null ? double.tryParse(ride.boardingPointEnd!.latitude.toString()) : null);
      final double? dLng = (ride.dropoffMatchPoint.lng != 0)
          ? ride.dropoffMatchPoint.lng
          : (ride.boardingPointEnd?.longitude != null ? double.tryParse(ride.boardingPointEnd!.longitude.toString()) : null);

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

      // 3. Fallback to start/return time difference if present
      dynamic startRaw = ride.departureTime ?? ride.startTime;
      dynamic returnRaw = ride.returnTime;
      DateTime? startDt = _parseDateTime(startRaw);
      DateTime? endDt = _parseDateTime(returnRaw);
      if (startDt != null && endDt != null) {
        if (endDt.isBefore(startDt)) {
          endDt = endDt.add(const Duration(days: 1));
        }
        Duration diff = endDt.difference(startDt);
        if (diff.inMinutes >= 5 && diff.inMinutes <= 480) {
          return _formatDuration(diff.inMinutes);
        }
      }
    } catch (_) {}
    return '--';
  }

  String _formatScheduleTime(String? departureTime, String startTime) {
    String raw = (departureTime != null && departureTime.trim().isNotEmpty)
        ? departureTime
        : startTime;

    if (raw.trim().isEmpty) {
      return '8:00 AM';
    }

    DateTime? dt = DateTime.tryParse(raw);
    if (dt == null) {
      try {
        dt = DateFormat('yyyy-MM-dd HH:mm:ss').parse(raw.trim());
      } catch (_) {}
    }

    if (dt != null) {
      return DateFormat('h:mm a').format(dt.toLocal());
    }

    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final pickupName = ride.pickupAddress.isNotEmpty
        ? ride.pickupAddress
        : (ride.boardingPointStart?.name ?? 'Cairo');

    final dropoffName = ride.dropoffAddress.isNotEmpty
        ? ride.dropoffAddress
        : (ride.boardingPointEnd?.name ?? 'Alexandria');

    final subPickup = ride.boardingPointStart?.name ?? 'Ramses Station';
    final subDropoff = ride.boardingPointEnd?.name ?? 'Smouha';

    final priceStr = '${ride.price.toStringAsFixed(0)} EGP';
    final scheduleTime = _formatScheduleTime(ride.departureTime, ride.startTime);
    final seatsLeft = '${ride.seatsAvailable} left';
    final String durationStr = _calculateDuration(ride);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? const Color(0xFF00A0E9) : const Color(0xFFE2E8F0),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isSelected ? 0.04 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Available badge + Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'available'.tr.isNotEmpty && 'available'.tr != 'available'
                            ? 'available'.tr
                            : 'Available',
                        style: textSemiBold.copyWith(
                          fontSize: 11,
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                    ),
                    Text(
                      priceStr,
                      style: textBold.copyWith(
                        fontSize: 17,
                        color: const Color(0xFF00A0E9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Main Route: Cairo → Alexandria
                Text(
                  '$pickupName ➔ $dropoffName',
                  style: textBold.copyWith(
                    fontSize: 16,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),

                // Sub Route: Ramses Station → Smouha
                Text(
                  '$subPickup ➔ $subDropoff',
                  style: textRegular.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Info Chips Row: Departure | Duration | Seats
                Row(
                  children: [
                    _buildInfoChip(
                      label: 'departure'.tr.isNotEmpty && 'departure'.tr != 'departure'
                          ? 'departure'.tr
                          : 'Departure',
                      value: scheduleTime,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      label: 'duration'.tr.isNotEmpty && 'duration'.tr != 'duration'
                          ? 'duration'.tr
                          : 'Duration',
                      value: durationStr,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      label: 'seats'.tr.isNotEmpty && 'seats'.tr != 'seats'
                          ? 'seats'.tr
                          : 'Seats',
                      value: seatsLeft,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Bottom Right Action Button: View trip
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: onViewDetails ?? onSelect,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00A0E9)
                              : const Color(0xFFEAF8FD),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'view_trip'.tr.isNotEmpty && 'view_trip'.tr != 'view_trip'
                              ? 'view_trip'.tr
                              : 'View trip',
                          style: textSemiBold.copyWith(
                            fontSize: 12,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF00A0E9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textRegular.copyWith(
                fontSize: 10,
                color: const Color(0xFF94A3B8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: textBold.copyWith(
                fontSize: 12,
                color: const Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
