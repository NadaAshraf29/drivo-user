import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityEmptyMatchingCard extends StatelessWidget {
  final String university;
  final String pickupPoint;
  final bool hasReturnRide;
  final VoidCallback onChangeSearch;

  const UniversityEmptyMatchingCard({
    super.key,
    required this.university,
    required this.pickupPoint,
    required this.hasReturnRide,
    required this.onChangeSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Searched For Header Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'searched_for'.tr,
                  style: textSemiBold.copyWith(
                    fontSize: 11,
                    letterSpacing: 0.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$university · $pickupPoint',
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hasReturnRide
                      ? 'return_ride_included'.tr
                      : 'one_way_ride'.tr,
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Circle Car Icon
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2FE),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.directions_car_filled_rounded,
                color: Color(0xFF0F172A),
                size: 44,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // No Matching Trips Title
          Text(
            'no_matching_university_trips'.tr,
            style: textBold.copyWith(
              fontSize: 18,
              color: const Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'no_matching_trips_desc'.tr,
              style: textRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 28),

          // Change Search Button
          InkWell(
            onTap: onChangeSearch,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF00A0E9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'change_search'.tr,
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
