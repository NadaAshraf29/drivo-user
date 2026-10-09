import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CarpoolPaymentInstapayAccountCardWidget extends StatelessWidget {
  final List<Map<String, dynamic>> paymentAccounts;
  final void Function(String value, String label) onCopy;

  const CarpoolPaymentInstapayAccountCardWidget({
    super.key,
    required this.paymentAccounts,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    if (paymentAccounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final account = paymentAccounts.first;
    final String accountNumber = (account['account_number'] as String?) ?? '';
    final String accountHolder = (account['account_holder'] as String?) ?? '';
    final String label = (account['label'] as String?) ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.isNotEmpty ? label : 'instapay'.tr,
                style: textBold.copyWith(
                  fontSize: 14,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                'copy_details'.tr,
                style: textMedium.copyWith(
                  fontSize: 12,
                  color: const Color(0xFF08A9F0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (accountNumber.isNotEmpty)
            _AccountRow(
              title: 'instapay_number'.tr,
              value: accountNumber,
              onCopy: () => onCopy(accountNumber, 'instapay_number'.tr),
            ),
          if (accountNumber.isNotEmpty && accountHolder.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: Color(0xFFF1F5F9), height: 1),
            ),
          if (accountHolder.isNotEmpty)
            _AccountRow(
              title: 'account_holder'.tr,
              value: accountHolder,
              onCopy: () => onCopy(accountHolder, 'account_holder'.tr),
            ),
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onCopy;

  const _AccountRow({
    required this.title,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCopy,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textRegular.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: textSemiBold.copyWith(
                      fontSize: 14,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.copy_rounded,
                size: 16,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
