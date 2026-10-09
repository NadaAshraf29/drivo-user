import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CarpoolPaymentDurationOption {
  final String key;
  final String title;
  final String subtitle;
  final int price;

  CarpoolPaymentDurationOption({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.price,
  });
}

class CarpoolPaymentDurationSelectorWidget extends StatelessWidget {
  final String selectedDuration;
  final int monthlyPrice;
  final int? twoWeeksPrice;
  final int? oneWeekPrice;
  final int? remainingDaysPrice;
  final int? remainingDays;
  final ValueChanged<String> onDurationChanged;

  const CarpoolPaymentDurationSelectorWidget({
    super.key,
    required this.selectedDuration,
    required this.monthlyPrice,
    this.twoWeeksPrice,
    this.oneWeekPrice,
    this.remainingDaysPrice,
    this.remainingDays,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final String titleText = 'booking_duration'.tr.isNotEmpty &&
            !'booking_duration'.tr.contains('booking_duration')
        ? 'booking_duration'.tr
        : ('subscription_duration'.tr.isNotEmpty &&
                !'subscription_duration'.tr.contains('subscription_duration')
            ? 'subscription_duration'.tr
            : 'Booking Duration');

    final String daysLabel =
        'days_count'.tr.isNotEmpty && !'days_count'.tr.contains('days_count')
            ? 'days_count'.tr
            : 'Days';

    final String monthTitle =
        '1_month'.tr.isNotEmpty && !'1_month'.tr.contains('1_month')
            ? '1_month'.tr
            : ('monthly'.tr.isNotEmpty && !'monthly'.tr.contains('monthly')
                ? 'monthly'.tr
                : '1 Month');

    final List<CarpoolPaymentDurationOption> options = [
      CarpoolPaymentDurationOption(
        key: 'monthly',
        title: monthTitle,
        subtitle: '30 $daysLabel',
        price: monthlyPrice,
      ),
    ];

    final String activeSelection = options.any((o) => o.key == selectedDuration)
        ? selectedDuration
        : options.first.key;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleText,
          style: textBold.copyWith(
            fontSize: 16,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        ..._buildOptionGrid(options, activeSelection),
      ],
    );
  }

  List<Widget> _buildOptionGrid(
    List<CarpoolPaymentDurationOption> options,
    String activeSelection,
  ) {
    if (options.length == 1) {
      final opt = options.first;
      return [
        _buildOptionCard(
          title: opt.title,
          subtitle: opt.subtitle,
          price: opt.price,
          isSelected: activeSelection == opt.key,
          onTap: () => onDurationChanged(opt.key),
        ),
      ];
    }

    final List<Widget> rows = [];
    for (int i = 0; i < options.length; i += 2) {
      final first = options[i];
      final hasSecond = (i + 1) < options.length;
      final second = hasSecond ? options[i + 1] : null;

      if (i > 0) {
        rows.add(const SizedBox(height: 12));
      }

      rows.add(
        Row(
          children: [
            Expanded(
              child: _buildOptionCard(
                title: first.title,
                subtitle: first.subtitle,
                price: first.price,
                isSelected: activeSelection == first.key,
                onTap: () => onDurationChanged(first.key),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: hasSecond
                  ? _buildOptionCard(
                      title: second!.title,
                      subtitle: second.subtitle,
                      price: second.price,
                      isSelected: activeSelection == second.key,
                      onTap: () => onDurationChanged(second.key),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    }
    return rows;
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required int price,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAF6FE) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF00A0E9) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF00A0E9).withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: textBold.copyWith(
                      fontSize: 14,
                      color: isSelected
                          ? const Color(0xFF00A0E9)
                          : const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00A0E9)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00A0E9)
                          : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 13,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: textRegular.copyWith(
                fontSize: 11,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$price ${'EGP'.tr}',
              style: textBold.copyWith(
                fontSize: 15,
                color: isSelected
                    ? const Color(0xFF00A0E9)
                    : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
