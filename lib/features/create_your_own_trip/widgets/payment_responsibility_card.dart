import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/controller/create_your_own_trip_controller.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/domain/models/special_trip_fare_model.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class PaymentResponsibilityCard extends StatelessWidget {
  const PaymentResponsibilityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateYourOwnTripController>(
      builder: (controller) {
        // Only show if seats > 1 or passengers > 1
        if (controller.seatsCount <= 1 && controller.passengers.length <= 1) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Color(0xFFD97706),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'who_will_pay'.tr,
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Option 1: Creator Pays
              _ResponsibilityOptionTile(
                title: 'creator_pays'.tr,
                subtitle: 'creator_pays_full_fare_description'.tr,
                icon: Icons.person_rounded,
                isSelected: controller.paymentResponsibility == PaymentResponsibility.creatorPays,
                onTap: () => controller.setPaymentResponsibility(PaymentResponsibility.creatorPays),
              ),
              const SizedBox(height: 10),

              // Option 2: Each Passenger Pays
              _ResponsibilityOptionTile(
                title: 'each_passenger_pays'.tr,
                subtitle: 'each_passenger_pays_split_description'.tr,
                icon: Icons.groups_rounded,
                isSelected: controller.paymentResponsibility == PaymentResponsibility.eachPassengerPays,
                onTap: () => controller.setPaymentResponsibility(PaymentResponsibility.eachPassengerPays),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResponsibilityOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ResponsibilityOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFDCFCE7) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textBold.copyWith(
                      fontSize: 13,
                      color: isSelected ? const Color(0xFF14532D) : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textRegular.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFCBD5E1),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
