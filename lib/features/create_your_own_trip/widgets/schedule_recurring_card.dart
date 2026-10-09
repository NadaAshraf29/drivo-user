import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/controller/create_your_own_trip_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class ScheduleRecurringCard extends StatelessWidget {
  const ScheduleRecurringCard({super.key});

  Future<void> _pickStartDate(
      BuildContext context, CreateYourOwnTripController controller) async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final initial = controller.startDate.isBefore(tomorrow)
        ? tomorrow
        : controller.startDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: tomorrow, // Today is strictly disabled
      lastDate: DateTime(now.year + 2),
      selectableDayPredicate: (date) {
        // Enforce tomorrow onwards
        return !date.isBefore(tomorrow);
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setStartDate(picked);
    }
  }

  Future<void> _pickEndDate(
      BuildContext context, CreateYourOwnTripController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.endDate.isBefore(controller.startDate)
          ? controller.startDate
          : controller.endDate,
      firstDate: controller.startDate,
      lastDate: DateTime(controller.startDate.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setEndDate(picked);
    }
  }

  Future<void> _pickStartTime(
      BuildContext context, CreateYourOwnTripController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: controller.startTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setStartTime(picked);
    }
  }

  Future<void> _pickReturnTime(
      BuildContext context, CreateYourOwnTripController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          controller.returnTime ?? const TimeOfDay(hour: 17, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: const Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setReturnTime(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateYourOwnTripController>(
      builder: (controller) {
        final daysCount = controller.calculateOperatingDaysCount();
        final DateFormat dateFormat = DateFormat('dd MMM yyyy');

        // Weekday definitions: 7=Sun, 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat
        final weekdays = [
          {'id': 7, 'label': 'Sun'},
          {'id': 1, 'label': 'Mon'},
          {'id': 2, 'label': 'Tue'},
          {'id': 3, 'label': 'Wed'},
          {'id': 4, 'label': 'Thu'},
          {'id': 5, 'label': 'Fri'},
          {'id': 6, 'label': 'Sat'},
        ];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Color(0xFF4F46E5),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'schedule_and_recurring_trip'.tr,
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date Range Selectors (Start Date & End Date)
              Row(
                children: [
                  // Start Date
                  Expanded(
                    child: _DateSelectorTile(
                      label: 'start_date'.tr,
                      helperText: 'earliest_tomorrow'.tr,
                      value: dateFormat.format(controller.startDate),
                      icon: Icons.calendar_today_rounded,
                      onTap: () => _pickStartDate(context, controller),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // End Date
                  Expanded(
                    child: _DateSelectorTile(
                      label: 'end_date'.tr,
                      helperText: 'repeats_until'.tr,
                      value: dateFormat.format(controller.endDate),
                      icon: Icons.event_repeat_rounded,
                      onTap: () => _pickEndDate(context, controller),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Outbound Time Selector
              _DateSelectorTile(
                label: 'outbound_time'.tr,
                helperText: 'trip_start_time'.tr,
                value: controller.startTime.format(context),
                icon: Icons.access_time_rounded,
                onTap: () => _pickStartTime(context, controller),
              ),
              const SizedBox(height: 16),

              // Operating Weekdays Title + Exclude Fri/Sat Quick Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'operating_days'.tr,
                    style: textSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      controller
                          .setExcludeWeekends(!controller.isWeekendsExcluded);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: controller.isWeekendsExcluded
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: controller.isWeekendsExcluded
                              ? const Color(0xFF10B981)
                              : const Color(0xFFCBD5E1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            controller.isWeekendsExcluded
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 13,
                            color: controller.isWeekendsExcluded
                                ? const Color(0xFF059669)
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'exclude_fri_sat'.tr,
                            style: textMedium.copyWith(
                              fontSize: 11,
                              color: controller.isWeekendsExcluded
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Weekday Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: weekdays.map((item) {
                  final int id = item['id'] as int;
                  final String label = item['label'] as String;
                  final bool isSelected =
                      controller.selectedWeekdays.contains(id);
                  final bool isWeekend = id == 5 || id == 6;

                  return InkWell(
                    onTap: () => controller.toggleWeekday(id),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 42,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(
                            label,
                            style: textBold.copyWith(
                              fontSize: 11,
                              color: isSelected
                                  ? Colors.white
                                  : isWeekend
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Preview Trip Days Pill Badge
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFBBF7D0),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.insights_rounded,
                      size: 16,
                      color: Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$daysCount ${'trip_days_preview'.tr}',
                        style: textSemiBold.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF15803D),
                        ),
                      ),
                    ),
                    Text(
                      'ui_preview_only'.tr,
                      style: textRegular.copyWith(
                        fontSize: 10,
                        color: const Color(0xFF16A34A).withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 14),

              // Return Ride Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: controller.hasReturnRide
                              ? const Color(0xFFFEF3C7)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.swap_horiz_rounded,
                          size: 16,
                          color: controller.hasReturnRide
                              ? const Color(0xFFD97706)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'add_return_ride'.tr,
                            style: textSemiBold.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'two_way_daily_trip'.tr,
                            style: textRegular.copyWith(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: controller.hasReturnRide,
                    activeTrackColor: Theme.of(context).primaryColor,
                    onChanged: (val) => controller.setReturnRide(val),
                  ),
                ],
              ),

              // Return Time Picker (Shown only if Return Ride enabled)
              if (controller.hasReturnRide) ...[
                const SizedBox(height: 12),
                _DateSelectorTile(
                  label: 'return_time'.tr,
                  helperText: 'afternoon_evening_pickup'.tr,
                  value: controller.returnTime != null
                      ? controller.returnTime!.format(context)
                      : 'select_return_time'.tr,
                  icon: Icons.schedule_rounded,
                  onTap: () => _pickReturnTime(context, controller),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DateSelectorTile extends StatelessWidget {
  final String label;
  final String helperText;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _DateSelectorTile({
    required this.label,
    required this.helperText,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF64748B)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textRegular.copyWith(
                      fontSize: 10,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: textSemiBold.copyWith(
                      fontSize: 13,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
