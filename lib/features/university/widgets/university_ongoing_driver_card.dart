import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/university/domain/models/university_active_trip_model.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityOngoingDriverCard extends StatelessWidget {
  final ActiveTripDriver driver;

  const UniversityOngoingDriverCard({
    super.key,
    required this.driver,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Driver Avatar Initial
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2FE),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                driver.avatarInitial,
                style: textBold.copyWith(
                  fontSize: 20,
                  color: const Color(0xFF00A0E9),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Driver Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${driver.vehicleName} · ${driver.vehicleColor} · ${driver.plateNumber}',
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFF59E0B),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${driver.rating} · ${'verified_driver'.tr}',
                      style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ETA Away Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${driver.etaMinutes} min',
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: const Color(0xFF00A0E9),
                  ),
                ),
                Text(
                  'away'.tr.isNotEmpty ? 'away'.tr : 'away',
                  style: textRegular.copyWith(
                    fontSize: 10,
                    color: const Color(0xFF00A0E9),
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
