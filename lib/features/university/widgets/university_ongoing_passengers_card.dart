import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/university/domain/models/university_active_trip_model.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_passenger_avatar_bubble.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityOngoingPassengersCard extends StatelessWidget {
  final List<ActiveTripPassenger> passengers;
  final int additionalPassengersCount;
  final String totalPassengersText;

  const UniversityOngoingPassengersCard({
    super.key,
    required this.passengers,
    this.additionalPassengersCount = 1,
    this.totalPassengersText = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'riding_with_you'.tr,
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalPassengersText.isNotEmpty
                      ? totalPassengersText
                      : 'passengers_sharing_this_route'.tr,
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Right: Avatar Badges
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (passengers.isNotEmpty)
                UniversityPassengerAvatarBubble(
                  label: passengers[0].avatarInitial.isNotEmpty
                      ? passengers[0].avatarInitial
                      : 'S',
                  backgroundColor: const Color(0xFFFEF3C7),
                  textColor: const Color(0xFFD97706),
                ),
              if (passengers.length > 1) ...[
                const SizedBox(width: 4),
                UniversityPassengerAvatarBubble(
                  label: passengers[1].avatarInitial.isNotEmpty
                      ? passengers[1].avatarInitial
                      : 'N',
                  backgroundColor: const Color(0xFFEDE9FE),
                  textColor: const Color(0xFF7C3AED),
                ),
              ],
              if (additionalPassengersCount > 0) ...[
                const SizedBox(width: 4),
                UniversityPassengerAvatarBubble(
                  label: '+$additionalPassengersCount',
                  backgroundColor: const Color(0xFFF1F5F9),
                  textColor: const Color(0xFF64748B),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
