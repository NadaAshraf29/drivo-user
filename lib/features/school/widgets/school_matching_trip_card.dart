import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/school/domain/models/school_trip_model.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'school_info_chip.dart';

class SchoolMatchingTripCard extends StatelessWidget {
  final SchoolTripModel trip;
  final bool isSelected;
  final VoidCallback onSelect;

  const SchoolMatchingTripCard({
    super.key,
    required this.trip,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF00A0E9) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF00A0E9).withOpacity(0.08)
                  : Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Route name + Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trip.routeName,
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '${trip.price.toStringAsFixed(0)} EGP',
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: const Color(0xFF00A0E9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Route subtitle
            Text(
              '${trip.fromArea} → ${trip.toSchool}',
              style: textRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),

            // 3 Chips: Pickup, Schedule, Seats
            Row(
              children: [
                Expanded(
                  child: SchoolInfoChip(
                    label: 'pickup'.tr,
                    value: trip.pickupPoint,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SchoolInfoChip(
                    label: 'schedule'.tr,
                    value: trip.scheduleTime,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SchoolInfoChip(
                    label: 'seats'.tr,
                    value: '${trip.seatsLeft} ${'left'.tr}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Bottom Row: Return indicator + Select trip button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trip.hasReturnRide
                      ? 'going_and_return_available'.tr
                      : 'going_only'.tr,
                  style: textMedium.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                InkWell(
                  onTap: onSelect,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF00A0E9)
                          : const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF00A0E9),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'select_trip'.tr,
                      style: textSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color:
                            isSelected ? Colors.white : const Color(0xFF00A0E9),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
