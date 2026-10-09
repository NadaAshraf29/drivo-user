import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/pool_ride_model.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SelectedTripReturnRideWidget extends StatelessWidget {
  final PoolRide trip;

  const SelectedTripReturnRideWidget({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    final destinationCity = (trip.boardingPointEnd?.name != null &&
            (trip.boardingPointEnd?.name.isNotEmpty ?? false))
        ? trip.boardingPointEnd?.name
        : (trip.dropoffAddress != null && trip.dropoffAddress.isNotEmpty
            ? trip.dropoffAddress
            : 'Cairo school');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFBAE6FD),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF08A9F0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.check,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Return ride included',
                  style: textBold.copyWith(
                    fontSize: 16,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$destinationCity → Home',
                  style: textMedium.copyWith(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pickup from school after classes.',
                  style: textRegular.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
