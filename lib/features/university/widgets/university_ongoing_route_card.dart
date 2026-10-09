import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityOngoingRouteCard extends StatelessWidget {
  final String pickupAddress;
  final String destinationAddress;
  final String pickupEta;
  final String arrivalTime;
  final String departureDate;
  final String carpoolSeatInfo;

  const UniversityOngoingRouteCard({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupEta,
    required this.arrivalTime,
    required this.departureDate,
    required this.carpoolSeatInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Pickup Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A0E9),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFBAE6FD), width: 2),
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 32,
                    color: const Color(0xFFCBD5E1),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'pickup_caps'.tr,
                      style: textSemiBold.copyWith(
                        fontSize: 11,
                        letterSpacing: 0.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pickupAddress,
                      style: textBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                pickupEta,
                style: textBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: const Color(0xFF00A0E9),
                ),
              ),
            ],
          ),

          // Destination Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFA7F3D0), width: 2),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'destination_caps'.tr,
                      style: textSemiBold.copyWith(
                        fontSize: 11,
                        letterSpacing: 0.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      destinationAddress,
                      style: textBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                arrivalTime,
                style: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Divider
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Bottom Meta Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                departureDate,
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                carpoolSeatInfo,
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
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
