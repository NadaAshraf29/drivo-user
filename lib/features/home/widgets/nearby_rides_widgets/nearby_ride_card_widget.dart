import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/pool_ride_model.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/screens/trip_details_screen.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'nearby_ride_badge_item_widget.dart';

class NearbyRideCardWidget extends StatelessWidget {
  final PoolRide ride;

  const NearbyRideCardWidget({
    super.key,
    required this.ride,
  });

  String _formatDistance(double? distKm) {
    if (distKm == null) return 'N/A';
    if (distKm < 1.0) {
      final meters = (distKm * 1000).round();
      return '$meters m';
    }
    return '${distKm.toStringAsFixed(1)} km';
  }

  String _formatScheduleTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '8:00 AM';
    if (timeStr.contains(' ')) {
      final parts = timeStr.split(' ');
      if (parts.length >= 2) return parts.sublist(1).join(' ');
    }
    return timeStr;
  }

  @override
  Widget build(BuildContext context) {
    final isLtr = Get.find<LocalizationController>().isLtr;
    final typeLabel = isLtr
        ? (ride.carpoolTypeLabel ?? ride.carpoolType ?? 'Carpool')
        : (ride.carpoolTypeLabelAr ?? ride.carpoolTypeLabel ?? 'كاربول');

    final titleText = ride.title?.isNotEmpty == true
        ? ride.title!
        : '${ride.pickupAddress.split(',').first} → ${ride.dropoffAddress.split(',').first}';

    final pickupPoint = ride.boardingPointStart?.name ??
        ride.closestPickup?.placeName ??
        ride.pickupAddress;

    final distanceText = _formatDistance(ride.distanceFromUserKm);
    final scheduleText = _formatScheduleTime(ride.departureTime ?? ride.startTime);
    final seatsText = '${ride.seatsAvailable} ${'left'.tr.isNotEmpty ? 'left'.tr : 'left'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Title + Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  titleText,
                  style: textBold.copyWith(
                    fontSize: 18,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                PriceConverter.convertPrice(ride.price.toDouble()),
                style: textBold.copyWith(
                  fontSize: 18,
                  color: const Color(0xFF0284C7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Nearest pickup subtitle
          Text(
            '${'nearest_pickup'.tr.isNotEmpty ? 'nearest_pickup'.tr : 'Nearest pickup'}: $pickupPoint',
            style: textRegular.copyWith(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          // Badges Row
          Row(
            children: [
              Expanded(
                child: NearbyRideBadgeItemWidget(
                  label: 'distance'.tr.isNotEmpty ? 'distance'.tr : 'Distance',
                  value: distanceText,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NearbyRideBadgeItemWidget(
                  label: 'schedule'.tr.isNotEmpty ? 'schedule'.tr : 'Schedule',
                  value: scheduleText,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NearbyRideBadgeItemWidget(
                  label: 'seats'.tr.isNotEmpty ? 'seats'.tr : 'Seats',
                  value: seatsText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Bottom Row: Type label + View ride button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                typeLabel,
                style: textMedium.copyWith(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.to(() => TripDetailsScreen(
                        trip: ride,
                        rideController: Get.find<RideController>(),
                        fromSearch: true,
                      ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF08A9F0),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'view_ride'.tr.isNotEmpty ? 'view_ride'.tr : 'View ride',
                  style: textSemiBold.copyWith(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
