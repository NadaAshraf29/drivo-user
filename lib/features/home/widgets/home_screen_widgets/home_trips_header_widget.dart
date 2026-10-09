import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

import 'package:ride_sharing_user_app/features/home/screens/nearby_rides_screen.dart';

class HomeTripsHeaderWidget extends StatelessWidget {
  const HomeTripsHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'trips_near_you'.tr,
          style: textBold.copyWith(
            fontSize: 20,
            color: const Color(0xFF0F172A),
          ),
        ),
        InkWell(
          onTap: () => Get.to(() => const NearbyRidesScreen()),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'view_near_me'.tr,
                  style: textSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: const Color(0xFF00A0E9),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: Color(0xFF00A0E9),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
