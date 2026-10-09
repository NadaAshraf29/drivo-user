import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/helper/map_bound_helper.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TripDetailsLocationFieldWidget extends StatelessWidget {
  final String label;
  final LatLng? selectedPoint;
  final LatLng? userReferencePoint;
  final String? addressName;
  final VoidCallback onTap;
  final Color accentColor;

  const TripDetailsLocationFieldWidget({
    super.key,
    required this.label,
    required this.selectedPoint,
    this.userReferencePoint,
    this.addressName,
    required this.onTap,
    required this.accentColor,
  });

  bool _isCoordinateString(String s) {
    final trimmed = s.trim();
    final coordRegex = RegExp(r'^-?\d+(\.\d+)?\s*,\s*-?\d+(\.\d+)?$');
    return coordRegex.hasMatch(trimmed);
  }

  String? _computeWalkInfo() {
    if (selectedPoint == null || userReferencePoint == null) return null;
    final p1 = MapBoundHelper.toCorrectLatLng(
      userReferencePoint!.latitude,
      userReferencePoint!.longitude,
    );
    final p2 = MapBoundHelper.toCorrectLatLng(
      selectedPoint!.latitude,
      selectedPoint!.longitude,
    );
    final straight = Geolocator.distanceBetween(
      p1.latitude,
      p1.longitude,
      p2.latitude,
      p2.longitude,
    );
    if (straight <= 15) return '1 min walk';
    final walkDist = straight * 1.15;
    final mins = (walkDist / 80).round();
    final distStr = walkDist < 1000
        ? '${walkDist.round()} m'
        : '${(walkDist / 1000).toStringAsFixed(1)} km';
    final walkTimeStr = mins <= 1 ? '1 min walk' : '$mins min walk';
    return '$distStr • $walkTimeStr';
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSelection = selectedPoint != null;
    final String subtitle;
    if (hasSelection) {
      if (addressName != null &&
          addressName!.trim().isNotEmpty &&
          !_isCoordinateString(addressName!)) {
        subtitle = addressName!.trim();
      } else {
        subtitle = 'on_driver_route'.tr.isNotEmpty &&
                !'on_driver_route'.tr.contains('on_driver_route')
            ? 'on_driver_route'.tr
            : 'Meeting Point on Route';
      }
    } else {
      subtitle = 'tap_route_to_select'.tr.isNotEmpty &&
              !'tap_route_to_select'.tr.contains('tap_route_to_select')
          ? 'tap_route_to_select'.tr
          : 'Tap on route to adjust location';
    }

    final walkInfo = hasSelection ? _computeWalkInfo() : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              color: hasSelection
                  ? accentColor.withValues(alpha: 0.35)
                  : Colors.grey.withValues(alpha: 0.15),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  accentColor == Colors.cyan || accentColor == const Color(0xFF00A3EC)
                      ? Icons.my_location_rounded
                      : Icons.pin_drop_rounded,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            style: textBold.copyWith(
                              fontSize: 13,
                              color: const Color(0xFF1E2432),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasSelection) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'set'.tr.isNotEmpty && !'set'.tr.contains('set')
                                  ? 'set'.tr
                                  : 'Set',
                              style: textBold.copyWith(
                                fontSize: 10,
                                color: accentColor,
                              ),
                            ),
                          ),
                          if (walkInfo != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.directions_walk,
                                    size: 11,
                                    color: Colors.orange.shade800,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    walkInfo,
                                    style: textBold.copyWith(
                                      fontSize: 10,
                                      color: Colors.orange.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: textRegular.copyWith(
                        fontSize: 12,
                        color: hasSelection
                            ? const Color(0xFF475569)
                            : Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_location_alt_outlined,
                  color: Color(0xFF64748B),
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
