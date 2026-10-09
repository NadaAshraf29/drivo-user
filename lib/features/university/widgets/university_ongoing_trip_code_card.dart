import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityOngoingTripCodeCard extends StatelessWidget {
  final String startTripCode;

  const UniversityOngoingTripCodeCard({
    super.key,
    required this.startTripCode,
  });

  @override
  Widget build(BuildContext context) {
    final digits = startTripCode.split('');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCFCE7), width: 1),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFF10B981),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'start_trip_code'.tr,
                      style: textBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'share_code_with_driver'.tr,
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
          const SizedBox(height: 16),

          // Digits row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: digits.map((digit) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 48,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    digit,
                    style: textBold.copyWith(
                      fontSize: 22,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Bottom instruction
          Text(
            'only_share_when_ready'.tr,
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
