import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityPaymentTotalCard extends StatelessWidget {
  final double totalPrice;
  final String periodDescription;

  const UniversityPaymentTotalCard({
    super.key,
    required this.totalPrice,
    required this.periodDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'total'.tr.isNotEmpty && !'total'.tr.contains('total')
                          ? 'total'.tr.toUpperCase()
                          : 'TOTAL AMOUNT',
                      style: textMedium.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${totalPrice.toStringAsFixed(0)} ${'EGP'.tr}',
                      style: textBold.copyWith(
                        fontSize: 22,
                        color: const Color(0xFF00A0E9),
                      ),
                    ),
                  ],
                ),
              ),
              if (periodDescription.isNotEmpty) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      periodDescription,
                      style: textMedium.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF475569),
                      ),
                      textAlign: TextAlign.end,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
