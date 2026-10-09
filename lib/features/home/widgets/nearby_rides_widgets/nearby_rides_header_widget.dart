import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class NearbyRidesHeaderWidget extends StatelessWidget {
  final int totalNearby;

  const NearbyRidesHeaderWidget({
    super.key,
    required this.totalNearby,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'available_rides'.tr.isNotEmpty
              ? 'available_rides'.tr
              : 'Available rides',
          style: textBold.copyWith(
            fontSize: 20,
            color: const Color(0xFF0F172A),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$totalNearby ${'nearby'.tr.isNotEmpty ? 'nearby'.tr : 'nearby'}',
            style: textMedium.copyWith(
              fontSize: 13,
              color: const Color(0xFF0284C7),
            ),
          ),
        ),
      ],
    );
  }
}
