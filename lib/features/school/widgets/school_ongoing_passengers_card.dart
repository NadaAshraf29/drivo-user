import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/school/domain/models/school_active_trip_model.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'school_passenger_avatar_bubble.dart';

class SchoolOngoingPassengersCard extends StatelessWidget {
  final List<SchoolActiveTripPassenger> passengers;
  final String totalPassengersText;

  const SchoolOngoingPassengersCard({
    super.key,
    required this.passengers,
    required this.totalPassengersText,
  });

  @override
  Widget build(BuildContext context) {
    const colors = [
      {'bg': Color(0xFFFEF3C7), 'text': Color(0xFFD97706)},
      {'bg': Color(0xFFE0E7FF), 'text': Color(0xFF4F46E5)},
      {'bg': Color(0xFFF1F5F9), 'text': Color(0xFF475569)},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'riding_with_you'.tr,
                style: textBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                totalPassengersText,
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          Row(
            children: List.generate(
              passengers.length,
              (index) {
                final colorConfig = colors[index % colors.length];
                return SchoolPassengerAvatarBubble(
                  text: passengers[index].avatarText,
                  backgroundColor: colorConfig['bg']!,
                  textColor: colorConfig['text']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
