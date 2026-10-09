import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SchoolPaymentMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onSelectMethod;

  const SchoolPaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onSelectMethod,
  });

  @override
  Widget build(BuildContext context) {
    final isInstaPay = selectedMethod.toLowerCase() == 'instapay';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'payment_method'.tr,
          style: textBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // InstaPay Option
            Expanded(
              child: InkWell(
                onTap: () => onSelectMethod('instapay'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isInstaPay ? const Color(0xFFEBF5FF) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isInstaPay
                          ? const Color(0xFF00A0E9)
                          : const Color(0xFFE2E8F0),
                      width: isInstaPay ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isInstaPay
                            ? const Color(0xFF00A0E9).withOpacity(0.06)
                            : Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'instapay'.tr,
                      style: textBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Card Option (Coming Soon)
            Expanded(
              child: Opacity(
                opacity: 0.65,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.credit_card_rounded,
                        size: 20,
                        color: Color(0xFF334155),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'card'.tr,
                        style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 12,
                color: Color(0xFF00A0E9),
              ),
              const SizedBox(width: 4),
              Text(
                'coming_soon'.tr,
                style: textMedium.copyWith(
                  fontSize: 10,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
