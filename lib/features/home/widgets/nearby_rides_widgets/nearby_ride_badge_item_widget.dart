import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class NearbyRideBadgeItemWidget extends StatelessWidget {
  final String label;
  final String value;

  const NearbyRideBadgeItemWidget({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: textRegular.copyWith(
              fontSize: 11,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: textSemiBold.copyWith(
              fontSize: 13,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
