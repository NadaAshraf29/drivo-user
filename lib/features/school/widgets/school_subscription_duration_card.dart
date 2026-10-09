import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'school_duration_option_card.dart';

class SchoolSubscriptionDurationCard extends StatelessWidget {
  final String selectedDuration;
  final List<int> selectedDays;
  final double dailyUnitPrice;
  final ValueChanged<String> onSelect;
  final ValueChanged<List<int>> onDaysChanged;

  const SchoolSubscriptionDurationCard({
    super.key,
    required this.selectedDuration,
    required this.selectedDays,
    required this.dailyUnitPrice,
    required this.onSelect,
    required this.onDaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    final daysPerWeek = selectedDays.length;
    final monthlyTotalDays = daysPerWeek * 4;
    final weeklyTotalDays = daysPerWeek * 1;

    final monthlyPrice = dailyUnitPrice * monthlyTotalDays;
    final weeklyPrice = dailyUnitPrice * weeklyTotalDays;

    final dayLabels = [
      'day_sun'.tr,
      'day_mon'.tr,
      'day_tue'.tr,
      'day_wed'.tr,
      'day_thu'.tr,
      'day_fri'.tr,
      'day_sat'.tr,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'subscription_duration'.tr,
          style: textBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SchoolDurationOptionCard(
                title: 'one_month'.tr,
                subtitle: '$monthlyTotalDays ${'days_count'.tr}',
                price: '${monthlyPrice.toStringAsFixed(0)} EGP',
                isSelected: selectedDuration == 'monthly',
                onTap: () => onSelect('monthly'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SchoolDurationOptionCard(
                title: 'one_week'.tr,
                subtitle: '$weeklyTotalDays ${'days_count'.tr}',
                price: '${weeklyPrice.toStringAsFixed(0)} EGP',
                isSelected: selectedDuration == 'weekly',
                onTap: () => onSelect('weekly'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'select_travel_days'.tr,
              style: textSemiBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: const Color(0xFF1E293B),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$daysPerWeek ${'days_per_week'.tr}',
                style: textBold.copyWith(
                  fontSize: 11,
                  color: const Color(0xFF00A0E9),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(7, (index) {
              final isSelected = selectedDays.contains(index);
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  onTap: () {
                    final updated = List<int>.from(selectedDays);
                    if (isSelected) {
                      if (updated.length > 1) {
                        updated.remove(index);
                      }
                    } else {
                      updated.add(index);
                      updated.sort();
                    }
                    onDaysChanged(updated);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF00A0E9)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF00A0E9)
                            : const Color(0xFFCBD5E1),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      dayLabels[index],
                      style: textSemiBold.copyWith(
                        fontSize: 12,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
