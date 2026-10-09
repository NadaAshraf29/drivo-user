import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SchoolChangingPickupInfoCard extends StatelessWidget {
  const SchoolChangingPickupInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'changing_pickup_point'.tr,
          style: textBold.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'changing_pickup_point_desc'.tr,
          style: textRegular.copyWith(
            fontSize: Dimensions.fontSizeExtraSmall,
            color: const Color(0xFF64748B),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
