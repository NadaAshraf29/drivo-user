import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class OneTripDriverInfoCard extends StatelessWidget {
  final String driverName;
  final String vehicleInfo;
  final String ratingText;
  final String licensePlate;
  final VoidCallback? onCallTap;
  final VoidCallback? onMessageTap;

  const OneTripDriverInfoCard({
    super.key,
    required this.driverName,
    required this.vehicleInfo,
    required this.ratingText,
    required this.licensePlate,
    this.onCallTap,
    this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2FE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 30,
              color: Color(0xFF00A0E9),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driverName,
                  style: textBold.copyWith(
                    fontSize: 15,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  vehicleInfo,
                  style: textRegular.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 16, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text(
                      ratingText,
                      style: textBold.copyWith(
                        fontSize: 12,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        licensePlate,
                        style: textBold.copyWith(
                          fontSize: 10,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              InkWell(
                onTap: onCallTap,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F2FE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_rounded,
                    color: Color(0xFF00A0E9),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'call'.tr,
                style: textMedium.copyWith(
                  fontSize: 10,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              InkWell(
                onTap: onMessageTap,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0F2FE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Color(0xFF00A0E9),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'message'.tr,
                style: textMedium.copyWith(
                  fontSize: 10,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// ponytail: extracted widget class — follow single class per file rule
