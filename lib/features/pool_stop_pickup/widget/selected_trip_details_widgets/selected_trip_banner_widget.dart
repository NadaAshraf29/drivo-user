import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/pool_ride_model.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SelectedTripBannerWidget extends StatelessWidget {
  final PoolRide trip;

  const SelectedTripBannerWidget({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    final routeTitle =
        (trip.carpoolType != null && trip.carpoolType.toString().isNotEmpty)
            ? trip.carpoolType.toString()
            : 'Route name';
    final subscriptionType =
        (trip.isRecurring == true) ? 'Monthly' : 'One-time';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFBAE6FD),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Active',
              style: textMedium.copyWith(
                fontSize: 12,
                color: const Color(0xFF08A9F0),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                routeTitle,
                style: textBold.copyWith(
                  fontSize: 18,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                subscriptionType,
                style: textSemiBold.copyWith(
                  fontSize: 15,
                  color: const Color(0xFF0284C7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
