import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_subscription_duration_option_card.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityDurationOptionData {
  final String key;
  final String title;
  final String subtitle;
  final double price;

  UniversityDurationOptionData({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.price,
  });
}

class UniversitySubscriptionDurationCard extends StatelessWidget {
  final String selectedDuration;
  final List<int> selectedDays; // [0..6] (0=Sun, 1=Mon, ..., 6=Sat)
  final double dailyUnitPrice;
  final int seatsCount;
  final String validUntil;
  final ValueChanged<String> onDurationChanged;
  final ValueChanged<List<int>> onDaysChanged;

  const UniversitySubscriptionDurationCard({
    super.key,
    required this.selectedDuration,
    required this.selectedDays,
    required this.dailyUnitPrice,
    this.seatsCount = 1,
    this.validUntil = '',
    required this.onDurationChanged,
    required this.onDaysChanged,
  });

  DateTime? _parseValidUntilDate(String validUntilStr) {
    if (validUntilStr.trim().isEmpty) return null;
    final str = validUntilStr.trim();
    final now = DateTime.now();

    try {
      final isoDate = DateTime.tryParse(str);
      if (isoDate != null) return isoDate;

      if (str.contains('/')) {
        final parts = str.split('/');
        if (parts.length >= 2) {
          final p1 = int.tryParse(parts[0].trim());
          final p2 = int.tryParse(parts[1].trim());
          final yrRaw = parts.length >= 3 ? int.tryParse(parts[2].trim()) : null;
          if (p1 != null && p2 != null) {
            int day = p1;
            int month = p2;
            if (p1 <= 12 && p2 > 12) {
              month = p1;
              day = p2;
            }
            int targetYear;
            if (yrRaw != null) {
              targetYear = yrRaw < 100 ? 2000 + yrRaw : yrRaw;
            } else {
              targetYear = (month < now.month) ? now.year + 1 : now.year;
            }
            return DateTime(targetYear, month, day);
          }
        }
      }

      if (str.contains('-')) {
        final parts = str.split('-');
        if (parts.length >= 3) {
          final y = int.tryParse(parts[0].trim());
          final m = int.tryParse(parts[1].trim());
          final d = int.tryParse(parts[2].trim());
          if (y != null && m != null && d != null && y > 1000) {
            return DateTime(y, m, d);
          }
        }
        if (parts.length >= 2) {
          final p1 = int.tryParse(parts[0].trim());
          final p2 = int.tryParse(parts[1].trim());
          final yrRaw = parts.length >= 3 ? int.tryParse(parts[2].trim()) : null;
          if (p1 != null && p2 != null) {
            int day = p1;
            int month = p2;
            if (p1 <= 12 && p2 > 12) {
              month = p1;
              day = p2;
            }
            int targetYear;
            if (yrRaw != null) {
              targetYear = yrRaw < 100 ? 2000 + yrRaw : yrRaw;
            } else {
              targetYear = (month < now.month) ? now.year + 1 : now.year;
            }
            return DateTime(targetYear, month, day);
          }
        }
      }

      final months = {
        'jan': 1,
        'feb': 2,
        'mar': 3,
        'apr': 4,
        'may': 5,
        'jun': 6,
        'jul': 7,
        'aug': 8,
        'sep': 9,
        'oct': 10,
        'nov': 11,
        'dec': 12
      };
      final lower = str.toLowerCase();
      for (final entry in months.entries) {
        if (lower.contains(entry.key)) {
          final matches = RegExp(r'\d+')
              .allMatches(str)
              .map((m) => int.parse(m.group(0)!))
              .toList();
          if (matches.isNotEmpty) {
            final day = matches[0];
            final yrRaw = matches.length > 1 ? matches[1] : null;
            int targetYear;
            if (yrRaw != null) {
              targetYear = yrRaw < 100 ? 2000 + yrRaw : yrRaw;
            } else {
              targetYear = (entry.value < now.month) ? now.year + 1 : now.year;
            }
            return DateTime(targetYear, entry.value, day);
          }
        }
      }
    } catch (_) {}
    return null;
  }

  int _calculateRemainingCalendarDays() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = _parseValidUntilDate(validUntil);
    if (targetDate != null) {
      final targetDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
      final diff = targetDay.difference(today).inDays + 1;
      return diff > 0 ? diff : 1;
    }
    return 30;
  }

  int _calculateRemainingTravelDays() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final rawTarget = _parseValidUntilDate(validUntil) ??
        start.add(const Duration(days: 30));
    final targetDate = DateTime(rawTarget.year, rawTarget.month, rawTarget.day);

    int count = 0;
    DateTime current = start;
    while (!current.isAfter(targetDate)) {
      final dayIndex = current.weekday == 7 ? 0 : current.weekday;
      if (selectedDays.contains(dayIndex)) {
        count++;
      }
      current = current.add(const Duration(days: 1));
    }
    return count > 0 ? count : 1;
  }

  @override
  Widget build(BuildContext context) {
    final daysPerWeek = selectedDays.length;
    final dailyPrice = dailyUnitPrice * seatsCount;

    final remCalendarDays = _calculateRemainingCalendarDays();
    final remTravelDays = _calculateRemainingTravelDays();

    final monthlyTotalDays = daysPerWeek * 4;
    final twoWeeksTotalDays = daysPerWeek * 2;
    final weeklyTotalDays = daysPerWeek * 1;

    final monthlyPrice = dailyPrice * monthlyTotalDays;
    final twoWeeksPrice = dailyPrice * twoWeeksTotalDays;
    final weeklyPrice = dailyPrice * weeklyTotalDays;
    final remainingPrice = dailyPrice * remTravelDays;

    final String daysCountLabel = 'days_count'.tr.isNotEmpty &&
            !'days_count'.tr.contains('days_count')
        ? 'days_count'.tr
        : 'Days';

    final String bookRemainingTitle = 'book_remaining_dates'.tr.isNotEmpty &&
            !'book_remaining_dates'.tr.contains('book_remaining_dates')
        ? 'book_remaining_dates'.tr
        : ('book_remaining_days'.tr.isNotEmpty &&
                !'book_remaining_days'.tr.contains('book_remaining_days')
            ? 'book_remaining_days'.tr
            : 'Book Remaining Dates');

    final List<UniversityDurationOptionData> options = [];

    // 1 Month: Disappears if remaining calendar dates < 30
    if (remCalendarDays >= 30) {
      options.add(UniversityDurationOptionData(
        key: 'monthly',
        title: 'one_month'.tr.isNotEmpty && !'one_month'.tr.contains('one_month')
            ? 'one_month'.tr
            : '1 Month',
        subtitle: '$monthlyTotalDays $daysCountLabel',
        price: monthlyPrice,
      ));
    }



    // 1 Week: Disappears if remaining calendar dates < 7
    if (remCalendarDays >= 7) {
      options.add(UniversityDurationOptionData(
        key: 'weekly',
        title: 'one_week'.tr.isNotEmpty && !'one_week'.tr.contains('one_week')
            ? 'one_week'.tr
            : '1 Week',
        subtitle: '$weeklyTotalDays $daysCountLabel',
        price: weeklyPrice,
      ));
    }

    // Book Remaining Dates: Visible if remaining calendar dates < 30
    if (remCalendarDays < 30 && remCalendarDays > 0) {
      options.add(UniversityDurationOptionData(
        key: 'remaining',
        title: bookRemainingTitle,
        subtitle: '$remTravelDays $daysCountLabel',
        price: remainingPrice,
      ));
    }

    if (options.isEmpty) {
      options.add(UniversityDurationOptionData(
        key: 'remaining',
        title: bookRemainingTitle,
        subtitle: '$remTravelDays $daysCountLabel',
        price: remainingPrice,
      ));
    }

    final String activeSelection = options.any((o) => o.key == selectedDuration)
        ? selectedDuration
        : options.first.key;

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
            fontSize: Dimensions.fontSizeLarge,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),

        // Duration Option Cards
        ..._buildOptionGrid(options, activeSelection),
        const SizedBox(height: 16),

        // Travel Days Selection Header
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

        // Day Chips Toggle (Sun, Mon, Tue, Wed, Thu, Fri, Sat)
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

  List<Widget> _buildOptionGrid(
    List<UniversityDurationOptionData> options,
    String activeSelection,
  ) {
    if (options.length == 1) {
      final opt = options.first;
      return [
        UniversitySubscriptionDurationOptionCard(
          title: opt.title,
          subtitle: opt.subtitle,
          priceText: '${opt.price.toStringAsFixed(0)} EGP',
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
        rows.add(const SizedBox(height: 8));
      }

      rows.add(
        Row(
          children: [
            Expanded(
              child: UniversitySubscriptionDurationOptionCard(
                title: first.title,
                subtitle: first.subtitle,
                priceText: '${first.price.toStringAsFixed(0)} EGP',
                isSelected: activeSelection == first.key,
                onTap: () => onDurationChanged(first.key),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: hasSecond
                  ? UniversitySubscriptionDurationOptionCard(
                      title: second!.title,
                      subtitle: second.subtitle,
                      priceText: '${second.price.toStringAsFixed(0)} EGP',
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
}

