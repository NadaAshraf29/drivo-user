import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SchoolSearchSummaryCard extends StatelessWidget {
  final String schoolName;
  final String pickupPoint;
  final bool hasReturnRide;
  final VoidCallback onEdit;

  const SchoolSearchSummaryCard({
    super.key,
    required this.schoolName,
    required this.pickupPoint,
    required this.hasReturnRide,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'search'.tr.toUpperCase(),
                  style: textRegular.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$schoolName · $pickupPoint',
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasReturnRide
                      ? 'return_ride_included'.tr
                      : 'one_way_ride'.tr,
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'edit'.tr,
                style: textSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: const Color(0xFF0284C7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
