import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class RideCardTimeRouteWidget extends StatelessWidget {
  final String startTime;
  final String? departureTime;
  final String? returnTime;
  final double? startLat;
  final double? startLng;
  final double? endLat;
  final double? endLng;

  const RideCardTimeRouteWidget({
    super.key,
    required this.startTime,
    this.departureTime,
    this.returnTime,
    this.startLat,
    this.startLng,
    this.endLat,
    this.endLng,
  });

  DateTime? _parseDateTime(String str) {
    if (str.trim().isEmpty) return null;
    DateTime? dt = DateTime.tryParse(str);
    if (dt != null) return dt;

    try {
      final now = DateTime.now();
      String cleanStr = str.trim().toUpperCase();
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

  String _formatDateTime(DateTime dt) {
    int hour = dt.hour;
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    String minuteStr = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minuteStr $period';
  }

  String _formatTime(String dateTimeStr) {
    if (dateTimeStr.isEmpty) return '--';
    DateTime? dt = _parseDateTime(dateTimeStr);
    if (dt != null) {
      return _formatDateTime(dt);
    }
    return dateTimeStr;
  }

  double _calculateDistanceKm(
      double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295; // Math.PI / 180
    double a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a.clamp(0.0, 1.0)));
  }

  int _estimateDriveMinutes(double distanceKm) {
    if (distanceKm <= 0) return 5;
    final double roadKm = distanceKm * 1.4;

    double speedKmH;
    if (roadKm < 20) {
      speedKmH = 30.0; // Cairo urban traffic speed (~25-35 km/h)
    } else if (roadKm < 60) {
      speedKmH = 45.0; // Ring road / highways (~40-50 km/h)
    } else {
      speedKmH = 75.0; // Intercity (~70-80 km/h)
    }

    int minutes = ((roadKm / speedKmH) * 60).round() + 5;
    return minutes < 5 ? 5 : minutes;
  }

  int? _getEstimatedMinutesFromCoords() {
    if (startLat != null &&
        startLng != null &&
        endLat != null &&
        endLng != null &&
        (startLat != 0 || startLng != 0) &&
        (endLat != 0 || endLng != 0)) {
      double distanceKm =
          _calculateDistanceKm(startLat!, startLng!, endLat!, endLng!);
      if (distanceKm > 0) {
        return _estimateDriveMinutes(distanceKm);
      }
    }
    return null;
  }

  String _formatDuration(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else if (minutes > 0) {
      return '$minutes ${'min'.tr}';
    }
    return '--';
  }

  @override
  Widget build(BuildContext context) {
    String startRaw = departureTime ?? startTime;
    String startDisplayTime = _formatTime(startRaw);

    DateTime? startDt = _parseDateTime(startRaw);
    DateTime? endDt = returnTime != null && returnTime!.isNotEmpty
        ? _parseDateTime(returnTime!)
        : null;

    String endDisplayTime = '--';
    String durationText = '--';
    int? estimatedMinutes = _getEstimatedMinutesFromCoords();

    if (startDt != null && endDt != null) {
      if (endDt.isBefore(startDt)) {
        endDt = endDt.add(const Duration(days: 1));
      }
      final diffMins = endDt.difference(startDt).inMinutes;
      if (estimatedMinutes != null && (diffMins < 5 || diffMins < (estimatedMinutes * 0.4))) {
        durationText = _formatDuration(estimatedMinutes);
        endDisplayTime = _formatDateTime(startDt.add(Duration(minutes: estimatedMinutes)));
      } else {
        durationText = _formatDuration(diffMins);
        endDisplayTime = _formatDateTime(endDt);
      }
    } else {
      if (estimatedMinutes != null) {
        durationText = _formatDuration(estimatedMinutes);
        if (startDt != null) {
          endDisplayTime =
              _formatDateTime(startDt.add(Duration(minutes: estimatedMinutes)));
        } else if (returnTime != null && returnTime!.isNotEmpty) {
          endDisplayTime = _formatTime(returnTime!);
        }
      } else if (returnTime != null && returnTime!.isNotEmpty) {
        endDisplayTime = _formatTime(returnTime!);
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Departure Time
        Text(
          startDisplayTime,
          style: textBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Colors.black87,
          ),
        ),

        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

        // Left Arrow
        Icon(
          Icons.arrow_back,
          size: 14,
          color: Colors.grey.shade400,
        ),

        // Dashed / dotted line placeholder space with duration chip
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                ),
              ),
              // Container(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              //   decoration: BoxDecoration(
              //     color: Colors.grey.shade100,
              //     borderRadius: BorderRadius.circular(16),
              //   ),
              //   child: Text(
              //     durationText,
              //     style: textMedium.copyWith(
              //       fontSize: Dimensions.fontSizeExtraSmall,
              //       color: Colors.grey.shade600,
              //     ),
              //   ),
              // ),
              Expanded(
                child: Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                ),
              ),
            ],
          ),
        ),

        // Right Arrow
        Icon(
          Icons.arrow_forward,
          size: 14,
          color: Colors.grey.shade400,
        ),

        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

        // Arrival / Return Time
        Text(
          endDisplayTime,
          style: textBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
