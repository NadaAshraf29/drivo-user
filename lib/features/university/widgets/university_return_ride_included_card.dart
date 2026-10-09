import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityReturnRideIncludedCard extends StatelessWidget {
  final String university;
  final double? rating;

  const UniversityReturnRideIncludedCard({
    super.key,
    required this.university,
    this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final displayRating = (rating != null && rating! > 0)
        ? rating!.toStringAsFixed(1)
        : '5.0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFBAE6FD),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF00A0E9),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'return_ride_included'.tr,
                      style: textBold.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBAE6FD)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            displayRating,
                            style: textBold.copyWith(
                              fontSize: 11,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$university → ${'home'.tr}',
                  style: textMedium.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'pickup_from_university_after_classes'.tr,
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

