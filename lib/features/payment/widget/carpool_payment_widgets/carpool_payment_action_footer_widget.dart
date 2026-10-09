import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CarpoolPaymentActionFooterWidget extends StatelessWidget {
  final int totalPrice;
  final String selectedMethod;
  final VoidCallback onPressed;
  final bool isSubmitting;
  final bool isReady;

  const CarpoolPaymentActionFooterWidget({
    super.key,
    required this.totalPrice,
    required this.selectedMethod,
    required this.onPressed,
    required this.isSubmitting,
    required this.isReady,
  });

  @override
  Widget build(BuildContext context) {
    final String selectedMethodText = selectedMethod == 'paymob'
        ? 'VISA / MasterCard'
        : (selectedMethod == 'instapay'
            ? 'instapay_selected'.tr
            : 'card'.tr);

    final String buttonText = 'pay_amount_and_book'.tr.replaceAll(
          '@amount',
          totalPrice.toString(),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Amount To Pay Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'amount_to_pay_uppercase'.tr,
                    style: textMedium.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalPrice ${'egp'.tr}',
                    style: textBold.copyWith(
                      fontSize: 20,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Text(
                selectedMethodText,
                style: textRegular.copyWith(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Primary Blue Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF08A9F0),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF08A9F0).withValues(alpha: 0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    buttonText,
                    style: textBold.copyWith(
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        // Subtext Note
        Text(
          'payment_method_recorded_note'.tr,
          textAlign: TextAlign.center,
          style: textRegular.copyWith(
            fontSize: 12,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
