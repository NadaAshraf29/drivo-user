import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/school/domain/models/school_trip_model.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SchoolAvailableRideCard extends StatelessWidget {
  final SchoolTripModel? trip;
  final String? fromArea;
  final String? toArea;
  final String? nearestPickup;
  final int? distanceMeters;
  final String? scheduleTime;
  final int? seatsLeft;
  final String? durationLabel;
  final double? price;
  final bool isSelected;
  final VoidCallback onSelect;

  const SchoolAvailableRideCard({
    super.key,
    this.trip,
    this.fromArea,
    this.toArea,
    this.nearestPickup,
    this.distanceMeters,
    this.scheduleTime,
    this.seatsLeft,
    this.durationLabel,
    this.price,
    this.isSelected = false,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final from = trip?.fromArea ?? fromArea ?? 'Cairo';
    final to = trip?.toSchool ?? toArea ?? 'School';
    final pickup = trip?.pickupPoint ?? nearestPickup ?? from;
    final destination = trip?.destinationPoint ?? to;
    final parsedPrice = trip?.price ?? price ?? 0.0;
    final seats = trip?.seatsLeft ?? seatsLeft ?? 1;
    final sched = trip?.scheduleTime ?? scheduleTime ?? '7:30 AM';
    final returnT = trip?.returnTime ?? '';
    final duration = returnT.isNotEmpty
        ? returnT
        : (trip != null
            ? '${trip!.subscriptionType.tr} · ${trip!.subscriptionDurationDays} ${'days_count'.tr}'
            : (durationLabel ?? 'Monthly'));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? const Color(0xFF00A0E9) : const Color(0xFFE2E8F0),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isSelected ? 0.04 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Available badge + Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'available'.tr.isNotEmpty &&
                                'available'.tr != 'available'
                            ? 'available'.tr
                            : 'Available',
                        style: textSemiBold.copyWith(
                          fontSize: 11,
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                    ),
                    Text(
                      '${parsedPrice.toStringAsFixed(0)} EGP',
                      style: textBold.copyWith(
                        fontSize: 17,
                        color: const Color(0xFF00A0E9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Main Route: From ➔ To
                Text(
                  '$from ➔ $to',
                  style: textBold.copyWith(
                    fontSize: 16,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),

                // Sub Route: Pickup ➔ Destination
                Text(
                  '$pickup ➔ $destination',
                  style: textRegular.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Info Chips Row: Departure | Return/Duration | Seats
                Row(
                  children: [
                    _buildInfoChip(
                      label: 'departure'.tr.isNotEmpty &&
                              'departure'.tr != 'departure'
                          ? 'departure'.tr
                          : 'Departure',
                      value: sched.isNotEmpty ? sched : '7:30 AM',
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      label: returnT.isNotEmpty
                          ? ('return'.tr.isNotEmpty &&
                                  'return'.tr != 'return'
                              ? 'return'.tr
                              : 'Return')
                          : ('duration'.tr.isNotEmpty &&
                                  'duration'.tr != 'duration'
                              ? 'duration'.tr
                              : 'Duration'),
                      value: duration,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      label: 'seats'.tr.isNotEmpty &&
                              'seats'.tr != 'seats'
                          ? 'seats'.tr
                          : 'Seats',
                      value: '$seats ${'left'.tr}',
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Bottom Right Action Button: View trip
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: onSelect,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00A0E9)
                              : const Color(0xFFEAF8FD),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'view_trip'.tr.isNotEmpty &&
                                  'view_trip'.tr != 'view_trip'
                              ? 'view_trip'.tr
                              : 'View trip',
                          style: textSemiBold.copyWith(
                            fontSize: 12,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF00A0E9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFF1F5F9),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textMedium.copyWith(
                fontSize: 10,
                color: const Color(0xFF94A3B8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: textBold.copyWith(
                fontSize: 12,
                color: const Color(0xFF1E293B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
