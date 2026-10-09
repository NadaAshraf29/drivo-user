import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityTripStatusCard extends StatelessWidget {
  final String routeName;
  final String university;
  final String subscriptionPeriod;

  const UniversityTripStatusCard({
    super.key,
    required this.routeName,
    required this.university,
    this.subscriptionPeriod = 'Monthly',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6FE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFBAE6FD),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'active'.tr,
              style: textMedium.copyWith(
                fontSize: 11,
                color: const Color(0xFF00A0E9),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '$routeName · $university',
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                subscriptionPeriod,
                style: textBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: const Color(0xFF00A0E9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
