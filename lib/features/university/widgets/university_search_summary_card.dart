import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversitySearchSummaryCard extends StatelessWidget {
  final String university;
  final String pickupPoint;
  final bool hasReturnRide;
  final VoidCallback onEdit;

  const UniversitySearchSummaryCard({
    super.key,
    required this.university,
    required this.pickupPoint,
    required this.hasReturnRide,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'search_label'.tr,
                  style: textMedium.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$university · $pickupPoint',
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasReturnRide) ...[
                  const SizedBox(height: 2),
                  Text(
                    'return_ride_included'.tr,
                    style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'edit'.tr,
                style: textSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: const Color(0xFF00A0E9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
