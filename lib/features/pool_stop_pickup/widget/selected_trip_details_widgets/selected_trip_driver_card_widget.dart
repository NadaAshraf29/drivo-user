import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import '../../domain/models/pool_ride_model.dart';
import 'trip_detail_label_widget.dart';

class SelectedTripDriverCardWidget extends StatelessWidget {
  final PoolRide trip;
  final VoidCallback? onDetailsTap;

  const SelectedTripDriverCardWidget({
    super.key,
    required this.trip,
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final driverName =
        (trip.driver?.fullName != null && trip.driver.fullName.isNotEmpty)
            ? trip.driver.fullName
            : (trip.driver?.fullName != null
                ? '${trip.driver.fullName}'
                : 'Ahmed Samir');

    final vehicleModel =
        (trip.vehicle?.model != null && trip.vehicle.model.isNotEmpty)
            ? '${trip.vehicle?.brand ?? 'Toyota'} ${trip.vehicle.model}'
            : 'Toyota Hiace';

    final rating =
        (trip.driver?.rating != null) ? '${trip.driver.rating}' : '4.9';

    final profileImageUrl = trip.driver?.profileImage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          (profileImageUrl != null && profileImageUrl.isNotEmpty)
              ? ImageWidget(
                  image: profileImageUrl,
                  height: 48,
                  width: 48,
                  radius: 24,
                  placeholder: Images.personPlaceholder,
                )
              : CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFE0F2FE),
                  child: Text(
                    driverName.isNotEmpty ? driverName[0].toUpperCase() : 'A',
                    style: textBold.copyWith(
                      fontSize: 18,
                      color: const Color(0xFF08A9F0),
                    ),
                  ),
                ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TripDetailLabelWidget(text: 'DRIVER'),
                const SizedBox(height: 2),
                Text(
                  driverName,
                  style: textBold.copyWith(
                    fontSize: 16,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$vehicleModel · $rating ★',
                  style: textRegular.copyWith(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onDetailsTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Details',
                style: textSemiBold.copyWith(
                  fontSize: 13,
                  color: const Color(0xFF08A9F0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
