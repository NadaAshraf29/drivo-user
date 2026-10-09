import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/university/domain/models/university_trip_model.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityMatchingTripCard extends StatelessWidget {
  final UniversityTripModel trip;
  final bool isSelected;
  final VoidCallback onSelect;

  const UniversityMatchingTripCard({
    super.key,
    required this.trip,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final fromArea = trip.fromArea.isNotEmpty ? trip.fromArea : 'Cairo';
    final toUni =
        trip.toUniversity.isNotEmpty ? trip.toUniversity : 'University';
    final subPickup =
        trip.pickupPoint.isNotEmpty ? trip.pickupPoint : fromArea;
    final subDropoff =
        trip.destinationPoint.isNotEmpty ? trip.destinationPoint : toUni;
    final priceStr = '${trip.price.toStringAsFixed(0)} EGP';
    final seatsLeft = '${trip.seatsLeft} left';
    final durationStr =
        trip.returnTime.isNotEmpty ? trip.returnTime : 'Daily';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF00A0E9)
              : const Color(0xFFE2E8F0),
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
                // Top Row: Badges (Available & Round Trip / One Way) + Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
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
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: trip.hasReturnRide
                                ? const Color(0xFFE0F2FE)
                                : const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: trip.hasReturnRide
                                  ? const Color(0xFFBAE6FD)
                                  : const Color(0xFFFFEDD5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                trip.hasReturnRide
                                    ? Icons.swap_horiz_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 13,
                                color: trip.hasReturnRide
                                    ? const Color(0xFF00A0E9)
                                    : const Color(0xFFEA580C),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                trip.hasReturnRide
                                    ? 'going_return_selected'.tr
                                    : 'going_only_selected'.tr,
                                style: textSemiBold.copyWith(
                                  fontSize: 11,
                                  color: trip.hasReturnRide
                                      ? const Color(0xFF00A0E9)
                                      : const Color(0xFFEA580C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      priceStr,
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
                  '$fromArea ➔ $toUni',
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
                  '$subPickup ➔ $subDropoff',
                  style: textRegular.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Info Chips Row: Schedule | Return/Duration | Seats
                Row(
                  children: [
                    _buildInfoChip(
                      label: 'departure'.tr.isNotEmpty &&
                              'departure'.tr != 'departure'
                          ? 'departure'.tr
                          : 'Departure',
                      value: trip.scheduleTime.isNotEmpty
                          ? trip.scheduleTime
                          : '8:00 AM',
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      label: trip.returnTime.isNotEmpty
                          ? ('return'.tr.isNotEmpty &&
                                  'return'.tr != 'return'
                              ? 'return'.tr
                              : 'Return')
                          : ('duration'.tr.isNotEmpty &&
                                  'duration'.tr != 'duration'
                              ? 'duration'.tr
                              : 'Duration'),
                      value: durationStr,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      label: 'seats'.tr.isNotEmpty &&
                              'seats'.tr != 'seats'
                          ? 'seats'.tr
                          : 'Seats',
                      value: seatsLeft,
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
