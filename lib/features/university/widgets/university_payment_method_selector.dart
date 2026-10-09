import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityPaymentMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onMethodChanged;

  const UniversityPaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isInstaPay = selectedMethod == 'instapay';
    final isPaymob = selectedMethod == 'paymob';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'payment_method'.tr,
          style: textBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // InstaPay
            Expanded(
              child: InkWell(
                onTap: () => onMethodChanged('instapay'),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: isInstaPay ? const Color(0xFFEAF6FE) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isInstaPay
                          ? const Color(0xFF00A0E9)
                          : const Color(0xFFE2E8F0),
                      width: isInstaPay ? 1.5 : 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'instapay'.tr,
                      style: textBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: isInstaPay
                            ? const Color(0xFF00A0E9)
                            : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Card (Credit/Debit)
            Expanded(
              child: InkWell(
                onTap: () => onMethodChanged('paymob'),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: isPaymob ? const Color(0xFFEAF6FE) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPaymob
                          ? const Color(0xFF00A0E9)
                          : const Color(0xFFE2E8F0),
                      width: isPaymob ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.credit_card_rounded,
                        size: 22,
                        color: isPaymob
                            ? const Color(0xFF00A0E9)
                            : const Color(0xFF1E293B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'VISA / MasterCard'.tr.isNotEmpty &&
                                !'VISA / MasterCard'.tr.contains('VISA')
                            ? 'VISA / MasterCard'.tr
                            : 'VISA / Card',
                        style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: isPaymob
                              ? const Color(0xFF00A0E9)
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
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
