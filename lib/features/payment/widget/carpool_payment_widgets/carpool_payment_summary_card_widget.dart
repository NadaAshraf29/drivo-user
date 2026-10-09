import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

String _shortLocation(String value) {
  final words = value.trim().split(RegExp(r'\s+'));
  if (words.length <= 3) return words.join(' ');
  return words.take(3).join(' ');
}

class CarpoolPaymentSummaryCardWidget extends StatelessWidget {
  final int totalPrice;
  final String routeTitle;
  final String dateTimeText;
  final String returnTimeText;
  final String pickupLocation;
  final String dropoffLocation;
  final String selectedDuration;
  final bool showDuration;
  final Map<String, dynamic>? proration;

  const CarpoolPaymentSummaryCardWidget({
    super.key,
    required this.totalPrice,
    this.routeTitle = '',
    this.dateTimeText = '',
    this.returnTimeText = '',
    this.pickupLocation = '',
    this.dropoffLocation = '',
    this.selectedDuration = 'monthly',
    this.showDuration = true,
    this.proration,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasProration = proration != null;
    final int? remainingDays = proration?['remaining_days'] as int?;
    final int? totalDays = proration?['total_days_in_month'] as int?;
    final double? prorationRatio =
        (proration?['proration_ratio'] as num?)?.toDouble();

    final int calculatedRemDays = remainingDays ??
        (DateUtils.getDaysInMonth(DateTime.now().year, DateTime.now().month) -
            DateTime.now().day +
            1);

    final String durationLabel = selectedDuration == 'monthly'
        ? ('1_month'.tr.isNotEmpty && !'1_month'.tr.contains('1_month')
            ? '1_month'.tr
            : '1 Month (30 Days)')
        : selectedDuration == 'two_weeks'
            ? ('2_weeks'.tr.isNotEmpty && !'2_weeks'.tr.contains('2_weeks')
                ? '2_weeks'.tr
                : '2 Weeks (14 Days)')
            : selectedDuration == 'one_week'
                ? ('1_week'.tr.isNotEmpty && !'1_week'.tr.contains('1_week')
                    ? '1_week'.tr
                    : '1 Week (7 Days)')
                : ('book_remaining_dates'.tr.isNotEmpty &&
                        !'book_remaining_dates'.tr.contains('book_remaining_dates')
                    ? 'book_remaining_dates'.tr
                    : 'Book Remaining Dates ($calculatedRemDays Days)');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Text(
            routeTitle,
            style: textBold.copyWith(
              fontSize: 18,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${'departure_time'.tr}: $dateTimeText',
            style: textRegular.copyWith(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          if (returnTimeText.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${'return_time'.tr}: $returnTimeText',
              style: textRegular.copyWith(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
          if (showDuration) ...[
            const SizedBox(height: 4),
            Text(
              '${'booking_duration'.tr.isNotEmpty && !'booking_duration'.tr.contains('booking_duration') ? 'booking_duration'.tr : 'Duration'}: $durationLabel',
              style: textRegular.copyWith(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            '${'pickup_colon'.tr} ${_shortLocation(pickupLocation)}',
            style: textRegular.copyWith(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          if (hasProration && remainingDays != null && totalDays != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Prorated for $remainingDays of $totalDays days'
                '${prorationRatio != null ? ' (${(prorationRatio * 100).toStringAsFixed(0)}%)' : ''}',
                style: textMedium.copyWith(
                  fontSize: 12,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Total'.tr,
                style: textMedium.copyWith(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '$totalPrice ${'EGP'.tr}',
                style: textBold.copyWith(
                  fontSize: 20,
                  color: const Color(0xFF08A9F0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
