import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CarpoolPaymentMethodSelectorWidget extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onMethodSelected;

  const CarpoolPaymentMethodSelectorWidget({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bool isInstaPaySelected = selectedMethod == 'instapay';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'payment_method'.tr,
          style: textBold.copyWith(
            fontSize: 18,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Paymob (Card & Mobile Wallet) Option
            Expanded(
              child: GestureDetector(
                onTap: () => onMethodSelected('paymob'),
                child: Container(
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selectedMethod == 'paymob'
                        ? const Color(0xFFEBF8FF)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selectedMethod == 'paymob'
                          ? const Color(0xFF08A9F0)
                          : const Color(0xFFE2E8F0),
                      width: selectedMethod == 'paymob' ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.credit_card,
                        color: selectedMethod == 'paymob'
                            ? const Color(0xFF08A9F0)
                            : const Color(0xFF334155),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'VISA',
                        style: textBold.copyWith(
                          fontSize: 16,
                          color: selectedMethod == 'paymob'
                              ? const Color(0xFF08A9F0)
                              : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // InstaPay Option
            Expanded(
              child: GestureDetector(
                onTap: () => onMethodSelected('instapay'),
                child: Container(
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isInstaPaySelected
                        ? const Color(0xFFEBF8FF)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isInstaPaySelected
                          ? const Color(0xFF08A9F0)
                          : const Color(0xFFE2E8F0),
                      width: isInstaPaySelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Text(
                    'instapay'.tr,
                    style: textBold.copyWith(
                      fontSize: 16,
                      color: isInstaPaySelected
                          ? const Color(0xFF08A9F0)
                          : const Color(0xFF334155),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
