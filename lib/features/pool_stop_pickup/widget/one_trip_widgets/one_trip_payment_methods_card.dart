import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class OneTripPaymentMethodsCard extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onMethodSelected;

  const OneTripPaymentMethodsCard({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'select_payment_method'.tr,
                style: textBold.copyWith(
                  fontSize: 15,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 14, color: Color(0xFF00A0E9)),
                  const SizedBox(width: 4),
                  Text(
                    'secure_and_encrypted'.tr,
                    style: textMedium.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          _PaymentOptionTile(
            title: 'credit_debit_card'.tr,
            icon: Icons.credit_card_rounded,
            value: 'digital_payment',
            groupValue: selectedMethod,
            onChanged: onMethodSelected,
          ),
          const SizedBox(height: 8),
          _PaymentOptionTile(
            title: 'InstaPay',
            icon: Icons.account_balance_wallet_outlined,
            value: 'instapay',
            groupValue: selectedMethod,
            onChanged: onMethodSelected,
          ),
          const SizedBox(height: 8),
          _PaymentOptionTile(
            title: 'cash_at_pickup'.tr,
            icon: Icons.payments_outlined,
            value: 'cash',
            groupValue: selectedMethod,
            onChanged: onMethodSelected,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFBAE6FD),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: Color(0xFF00A0E9)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'payment_required_before_trip_starts'.tr,
                    style: textRegular.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF475569),
                    ),
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

class _PaymentOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _PaymentOptionTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F2FE) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00A0E9)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00A0E9)
                      : const Color(0xFFCBD5E1),
                  width: isSelected ? 5 : 1.5,
                ),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF00A0E9)
                  : const Color(0xFF64748B),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: (isSelected ? textBold : textMedium).copyWith(
                fontSize: 13,
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ponytail: extracted widget class — follow single class per file rule
