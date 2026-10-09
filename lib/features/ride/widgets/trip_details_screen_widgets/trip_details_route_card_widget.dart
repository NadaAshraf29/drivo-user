import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TripDetailsRouteCardWidget extends StatelessWidget {
  final dynamic trip;

  const TripDetailsRouteCardWidget({
    super.key,
    required this.trip,
  });

  DateTime? _parseDateTime(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    String str = val.toString().trim();
    if (str.isEmpty || str == 'null') return null;
    DateTime? dt = DateTime.tryParse(str);
    if (dt != null) return dt;

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

  String _formatTimeString(dynamic val) {
    if (val == null) return '';
    String str = val.toString().trim();
    if (str.isEmpty || str == 'null' || str == '00:00' || str == '00:00:00') return '';

    if (RegExp(r'^\d{1,2}:\d{2}\s*(AM|PM|am|pm)$').hasMatch(str)) {
      return str.toUpperCase();
    }
    if (RegExp(r'^\d{1,2}:\d{2}(:\d{2})?$').hasMatch(str)) {
      final parts = str.split(':');
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour != null && minute != null) {
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour % 12 == 0 ? 12 : hour % 12;
        final displayMinute = minute.toString().padLeft(2, '0');
        return '$displayHour:$displayMinute $period';
      }
    }
    try {
      final dt = DateTime.tryParse(str);
      if (dt != null) {
        final local = dt.toLocal();
        final hour = local.hour == 0 ? 12 : (local.hour > 12 ? local.hour - 12 : local.hour);
        final period = local.hour >= 12 ? 'PM' : 'AM';
        final minute = local.minute.toString().padLeft(2, '0');
        return '$hour:$minute $period';
      }
    } catch (_) {}
    return str;
  }

  String _getDepartureTimeStr() {
    try {
      if (trip.formattedTime != null &&
          trip.formattedTime is String &&
          (trip.formattedTime as String).trim().isNotEmpty) {
        return (trip.formattedTime as String).trim();
      }
    } catch (_) {}
    final raw = trip.departureTime ?? trip.startTime ?? trip.scheduledAt;
    return _formatTimeString(raw);
  }

  String _getReturnTimeStr() {
    try {
      if (trip.formattedReturnTime != null &&
          trip.formattedReturnTime is String &&
          (trip.formattedReturnTime as String).trim().isNotEmpty) {
        return (trip.formattedReturnTime as String).trim();
      }
    } catch (_) {}
    final raw = trip.returnTime;
    return _formatTimeString(raw);
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

  double? _getEstimatedDistanceKm() {
    try {
      if (trip.encodedPolyline != null &&
          trip.encodedPolyline is String &&
          (trip.encodedPolyline as String).isNotEmpty) {
        final points = _decodeEncodedPolyline(trip.encodedPolyline as String);
        final polyDistanceKm = _getPolylineDistanceKm(points);
        if (polyDistanceKm > 0) return polyDistanceKm;
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
        if (straightKm > 0) return straightKm * 1.3;
      }
    } catch (_) {}
    return null;
  }

  bool _checkIsTravelOrNorthCoast(dynamic trip) {
    try {
      if (trip.isTravelOrNorthCoast == true) return true;
    } catch (_) {}
    try {
      final ct = (trip.carpoolType?.toString() ?? '').toLowerCase().trim();
      final t = (trip.type?.toString() ?? '').toLowerCase().trim();
      final rName = (trip.routeName?.toString() ?? '').toLowerCase();
      final ttl = (trip.title?.toString() ?? '').toLowerCase();
      return ct == 'travel' ||
          ct == 'north_coast' ||
          ct == 'sahel' ||
          t == 'travel' ||
          t == 'north_coast' ||
          t == 'sahel' ||
          rName.contains('north coast') ||
          rName.contains('north_coast') ||
          rName.contains('sahel') ||
          rName.contains('travel') ||
          rName.contains('الساحل') ||
          rName.contains('سفر') ||
          ttl.contains('north coast') ||
          ttl.contains('north_coast') ||
          ttl.contains('sahel') ||
          ttl.contains('travel') ||
          ttl.contains('الساحل') ||
          ttl.contains('سفر');
    } catch (_) {}
    return false;
  }

  String _getDriverStartAddress(dynamic trip) {
    try {
      if (trip.startAddressDisplay != null &&
          trip.startAddressDisplay is String &&
          (trip.startAddressDisplay as String).trim().isNotEmpty) {
        return (trip.startAddressDisplay as String).trim();
      }
    } catch (_) {}
    try {
      if (trip.startAddress != null &&
          trip.startAddress is String &&
          (trip.startAddress as String).trim().isNotEmpty) {
        return (trip.startAddress as String).trim();
      }
    } catch (_) {}
    try {
      if (trip.startLocation != null &&
          trip.startLocation is String &&
          (trip.startLocation as String).trim().isNotEmpty) {
        return (trip.startLocation as String).trim();
      }
    } catch (_) {}
    return _getCleanPlaceName(
      trip.pickupAddress,
      trip.boardingPointStart?.name,
      trip.closestPickup?.placeName,
      trip.title,
      isStart: true,
      fallback: 'Start Location',
    );
  }

  String _getDriverEndAddress(dynamic trip) {
    try {
      if (trip.endAddressDisplay != null &&
          trip.endAddressDisplay is String &&
          (trip.endAddressDisplay as String).trim().isNotEmpty) {
        return (trip.endAddressDisplay as String).trim();
      }
    } catch (_) {}
    try {
      if (trip.endAddress != null &&
          trip.endAddress is String &&
          (trip.endAddress as String).trim().isNotEmpty) {
        return (trip.endAddress as String).trim();
      }
    } catch (_) {}
    try {
      if (trip.endLocation != null &&
          trip.endLocation is String &&
          (trip.endLocation as String).trim().isNotEmpty) {
        return (trip.endLocation as String).trim();
      }
    } catch (_) {}
    return _getCleanPlaceName(
      trip.dropoffAddress,
      trip.boardingPointEnd?.name,
      trip.closestDropoff?.placeName,
      trip.title,
      isStart: false,
      fallback: 'Destination',
    );
  }

  @override
  Widget build(BuildContext context) {
    final String departureTimeStr = _getDepartureTimeStr();
    final String returnTimeStr = _getReturnTimeStr();
    final bool hasReturn = returnTimeStr.isNotEmpty;

    DateTime startDt = _parseDateTime(trip.departureTime ?? trip.startTime ?? trip.scheduledAt) ?? DateTime.now();
    final String formattedDate = _formatDate(startDt);
    double? estimatedDistance = _getEstimatedDistanceKm();

    final bool isTravelOrNorthCoast = _checkIsTravelOrNorthCoast(trip);

    final String pickupAddress = isTravelOrNorthCoast
        ? _getDriverStartAddress(trip)
        : _getCleanPlaceName(
            trip.pickupAddress,
            trip.boardingPointStart?.name,
            trip.closestPickup?.placeName,
            trip.title,
            isStart: true,
            fallback: 'Pickup Point',
          );
    final String dropoffAddress = isTravelOrNorthCoast
        ? _getDriverEndAddress(trip)
        : _getCleanPlaceName(
            trip.dropoffAddress,
            trip.boardingPointEnd?.name,
            trip.closestDropoff?.placeName,
            trip.title,
            isStart: false,
            fallback: 'Dropoff Point',
          );

    final String pickupLabel = isTravelOrNorthCoast
        ? ('start_location'.tr.isNotEmpty && !'start_location'.tr.contains('start_location')
            ? 'start_location'.tr
            : 'Start Location')
        : ('pickup'.tr.isNotEmpty && !'pickup'.tr.contains('pickup')
            ? 'pickup'.tr
            : 'Pickup Point');

    final String dropoffLabel = isTravelOrNorthCoast
        ? ('destination'.tr.isNotEmpty && !'destination'.tr.contains('destination')
            ? 'destination'.tr
            : 'Destination')
        : ('dropoff'.tr.isNotEmpty && !'dropoff'.tr.contains('dropoff')
            ? 'dropoff'.tr
            : 'Dropoff Point');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          // 1. Header: Date & Distance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: Color(0xFF00A3EC),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formattedDate,
                    style: textBold.copyWith(
                      fontSize: 13,
                      color: const Color(0xFF1E2432),
                    ),
                  ),
                ],
              ),
              if (estimatedDistance != null && estimatedDistance > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${estimatedDistance.toStringAsFixed(1)} km',
                    style: textMedium.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // 2. Schedule Badges: Departure Time & Return Time (Morning & Night)
          if (hasReturn) ...[
            Row(
              children: [
                // Departure / Morning Trip
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFEDD5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.wb_sunny_rounded,
                          size: 14,
                          color: Color(0xFFEA580C),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'morning_trip'.tr.isNotEmpty &&
                                        !'morning_trip'.tr.contains('morning_trip')
                                    ? 'morning_trip'.tr
                                    : 'departure'.tr.isNotEmpty &&
                                            !'departure'.tr.contains('departure')
                                        ? 'departure'.tr
                                        : 'Departure',
                                style: textMedium.copyWith(
                                  fontSize: 10,
                                  color: const Color(0xFF9A3412),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1),
                              Text(
                                departureTimeStr.isNotEmpty
                                    ? departureTimeStr
                                    : '07:30 AM',
                                style: textBold.copyWith(
                                  fontSize: 13,
                                  color: const Color(0xFF431407),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Return / Night Trip
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE9D5FF)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.nights_stay_rounded,
                          size: 14,
                          color: Color(0xFF7C3AED),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'night_trip'.tr.isNotEmpty &&
                                        !'night_trip'.tr.contains('night_trip')
                                    ? 'night_trip'.tr
                                    : 'return'.tr.isNotEmpty &&
                                            !'return'.tr.contains('return')
                                        ? 'return'.tr
                                        : 'Return',
                                style: textMedium.copyWith(
                                  fontSize: 10,
                                  color: const Color(0xFF6B21A8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1),
                              Text(
                                returnTimeStr.isNotEmpty
                                    ? returnTimeStr
                                    : '05:30 PM',
                                style: textBold.copyWith(
                                  fontSize: 13,
                                  color: const Color(0xFF3B0764),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ] else if (departureTimeStr.isNotEmpty) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F6FE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: Color(0xFF00A3EC),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'departure_time'.tr.isNotEmpty &&
                            !'departure_time'.tr.contains('departure_time')
                        ? 'departure_time'.tr
                        : 'Departure Time',
                    style: textMedium.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF0369A1),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    departureTimeStr,
                    style: textBold.copyWith(
                      fontSize: 13,
                      color: const Color(0xFF0C4A6E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 14),

          // 3. Route Details (Pickup & Dropoff Locations)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Timeline Icons & Connecting Line
              Column(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00A3EC).withValues(alpha: 0.15),
                    ),
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF00A3EC),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 36,
                    color: Colors.grey.shade200,
                  ),
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: Color(0xFFEF5350),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              // Right: Route Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pickup Block
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pickupLabel,
                          style: textRegular.copyWith(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pickupAddress,
                          style: textBold.copyWith(
                            fontSize: 14,
                            color: const Color(0xFF1E2432),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Dropoff Block
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dropoffLabel,
                          style: textRegular.copyWith(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dropoffAddress,
                          style: textBold.copyWith(
                            fontSize: 14,
                            color: const Color(0xFF1E2432),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    final dayName = days[dt.weekday % 7];
    final monthName = months[dt.month - 1];
    return '$dayName, ${dt.day} $monthName ${dt.year}';
  }

  String _getCleanPlaceName(
    String? address,
    String? boardingPointName,
    String? closestPlaceName,
    String? tripTitle, {
    required bool isStart,
    required String fallback,
  }) {
    if (boardingPointName != null &&
        boardingPointName.trim().isNotEmpty &&
        !_isCoordinateString(boardingPointName)) {
      return boardingPointName.trim();
    }
    if (closestPlaceName != null &&
        closestPlaceName.trim().isNotEmpty &&
        !_isCoordinateString(closestPlaceName)) {
      return closestPlaceName.trim();
    }
    if (address != null &&
        address.trim().isNotEmpty &&
        !_isCoordinateString(address)) {
      return address.trim();
    }
    if (tripTitle != null && tripTitle.trim().isNotEmpty) {
      final parts = tripTitle.split(RegExp(r'[-➔→to]'));
      if (isStart && parts.isNotEmpty && parts[0].trim().isNotEmpty) {
        return parts[0].trim();
      } else if (!isStart && parts.length >= 2 && parts[1].trim().isNotEmpty) {
        return parts[1].trim();
      }
    }
    return fallback;
  }

  bool _isCoordinateString(String s) {
    final trimmed = s.trim();
    final coordRegex = RegExp(r'^-?\d+(\.\d+)?\s*,\s*-?\d+(\.\d+)?$');
    return coordRegex.hasMatch(trimmed);
  }
}
