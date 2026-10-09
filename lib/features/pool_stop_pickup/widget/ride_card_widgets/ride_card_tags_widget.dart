import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class RideCardTagsWidget extends StatelessWidget {
  final int seatsAvailable;
  final bool allowLuggage;

  const RideCardTagsWidget({
    super.key,
    required this.seatsAvailable,
    required this.allowLuggage,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        // Seats left tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$seatsAvailable ${'seats_left'.tr}',
            style: textMedium.copyWith(
              color: const Color(0xFF2E7D32),
              fontSize: Dimensions.fontSizeSmall,
            ),
          ),
        ),

        // Luggage tag
        if (allowLuggage)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.business_center,
                  size: 14,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  'luggage'.tr,
                  style: textMedium.copyWith(
                    color: Colors.grey.shade800,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
