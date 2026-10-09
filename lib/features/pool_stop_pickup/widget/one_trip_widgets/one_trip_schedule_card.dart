import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/seats_dropdown.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/trip_field_tile.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class OneTripScheduleCard extends StatelessWidget {
  final String dateText;
  final String departureTimeText;
  final int selectedSeats;
  final VoidCallback onPickDate;
  final VoidCallback onPickDepartureTime;
  final ValueChanged<int?> onSeatsChanged;

  const OneTripScheduleCard({
    super.key,
    required this.dateText,
    required this.departureTimeText,
    required this.selectedSeats,
    required this.onPickDate,
    required this.onPickDepartureTime,
    required this.onSeatsChanged,
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
          Text(
            'schedule'.tr.isNotEmpty && 'schedule'.tr != 'schedule'
                ? 'schedule'.tr
                : 'Schedule',
            style: textBold.copyWith(
              fontSize: 16,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'set_departure_and_seats'.tr.isNotEmpty &&
                    'set_departure_and_seats'.tr != 'set_departure_and_seats'
                ? 'set_departure_and_seats'.tr
                : 'Choose date, departure time, and required seats',
            style: textRegular.copyWith(
              fontSize: 11,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 14),

          // Date & Seats selector row
          Row(
            children: [
              Expanded(
                child: TripFieldTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'date'.tr,
                  value: dateText,
                  onTap: onPickDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SeatsDropdown(
                  value: selectedSeats,
                  onChanged: onSeatsChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Departure Time
          TripFieldTile(
            icon: Icons.access_time_rounded,
            label: 'departure_time'.tr.isNotEmpty &&
                    'departure_time'.tr != 'departure_time'
                ? 'departure_time'.tr
                : 'Departure',
            value: departureTimeText,
            onTap: onPickDepartureTime,
          ),
        ],
      ),
    );
  }
}
// ponytail: extracted widget class — follow single class per file rule

