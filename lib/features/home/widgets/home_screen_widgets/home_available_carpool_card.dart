import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/pool_ride_model.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

import '../../../pool_stop_pickup/screens/set_destination_carpool_screen.dart';
import '../../../ride/controllers/ride_controller.dart';
import '../../../ride/screens/trip_details_screen.dart';

class HomeAvailableCarpoolCard extends StatelessWidget {
  final PoolRide ride;

  const HomeAvailableCarpoolCard({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () {
        Get.to(
          () => TripDetailsScreen(
            trip: ride,
            rideController: Get.find<RideController>(),
          ),
        );
        // Get.to(
        //   () => SetDestinationCarPoolScreen(
        //     carpoolType: ride.carpoolType,
        //   ),
        // );
      },
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DriverRow(ride: ride, primaryColor: primaryColor),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            _RouteRow(ride: ride, primaryColor: primaryColor),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            _DetailsRow(ride: ride),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            _TagsRow(ride: ride, primaryColor: primaryColor),
          ],
        ),
      ),
    );
  }
}

// ─── Driver info + chat icon ──────────────────────────────────────────────────
class _DriverRow extends StatelessWidget {
  final PoolRide ride;
  final Color primaryColor;

  const _DriverRow({required this.ride, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: primaryColor.withOpacity(0.1),
          backgroundImage: ride.driver.profileImage != null &&
                  ride.driver.profileImage!.isNotEmpty
              ? NetworkImage(ride.driver.profileImage!)
              : null,
          child: ride.driver.profileImage == null ||
                  ride.driver.profileImage!.isEmpty
              ? Icon(Icons.person, color: primaryColor, size: 26)
              : null,
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    ride.driver.fullName,
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.star, color: Color(0xFFFFC107), size: 14),
                  const SizedBox(width: 2),
                  Text(
                    ride.driver.rating != null
                        ? ride.driver.rating!.toStringAsFixed(1)
                        : '-',
                    style: textMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _leavesInLabel(),
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ),
        // Container(
        //   padding: const EdgeInsets.all(8),
        //   decoration: BoxDecoration(
        //     color: primaryColor.withOpacity(0.08),
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        //   child: Icon(Icons.chat_bubble_outline, color: primaryColor, size: 18),
        // ),
      ],
    );
  }

  String _leavesInLabel() {
    try {
      final dt = DateTime.parse(ride.startTime);
      final diff = dt.difference(DateTime.now());
      if (diff.isNegative) return 'leaves_now'.tr;
      final minutes = diff.inMinutes;
      if (minutes < 60) {
        return '${'leaves_in'.tr} $minutes ${'min'.tr}';
      }
      return '${'leaves_in'.tr} ${diff.inHours}${'h'.tr} ${diff.inMinutes % 60}${'m'.tr}';
    } catch (_) {
      return ride.startTime;
    }
  }
}

// ─── From → To route row ──────────────────────────────────────────────────────
class _RouteRow extends StatelessWidget {
  final PoolRide ride;
  final Color primaryColor;

  const _RouteRow({required this.ride, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, size: 10, color: primaryColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            ride.pickupAddress,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child:
              Icon(Icons.arrow_forward, size: 16, color: Colors.grey.shade500),
        ),
        Icon(Icons.circle, size: 10, color: Colors.redAccent),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            ride.dropoffAddress,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
          ),
        ),
      ],
    );
  }
}

// ─── Time · Duration · Price row ─────────────────────────────────────────────
class _DetailsRow extends StatelessWidget {
  final PoolRide ride;

  const _DetailsRow({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          _formatTime(ride.startTime),
          style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge),
        ),
        const Spacer(),
        // Icon(Icons.access_time_outlined,
        //     size: 14, color: Theme.of(context).hintColor),
        // const SizedBox(width: 4),
        // Text(
        //   '1h 20m', // ponytail: duration not in PoolRide — add estimated_duration field when available
        //   style: textRegular.copyWith(
        //     fontSize: Dimensions.fontSizeSmall,
        //     color: Theme.of(context).hintColor,
        //   ),
        // ),
        // const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${ride.price} ${'egp'.tr}',
              style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
            Text(
              '/ ${'seat'.tr}',
              style: textRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      final hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$h:$minute $period';
    } catch (_) {
      return dateTime;
    }
  }
}

// ─── Car model · seats left · amenity chips ──────────────────────────────────
class _TagsRow extends StatelessWidget {
  final PoolRide ride;
  final Color primaryColor;

  const _TagsRow({required this.ride, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _Chip(
          label: '${ride.vehicle.brand} ${ride.vehicle.model}',
          color: Colors.grey.shade200,
          textColor: Colors.black87,
        ),
        _Chip(
          label: '${ride.seatsAvailable} ${'seats_left'.tr}',
          color: primaryColor.withOpacity(0.12),
          textColor: primaryColor,
        ),
        if (ride.allowLuggage)
          _Chip(
            label: 'luggage'.tr,
            color: Colors.grey.shade200,
            textColor: Colors.black87,
            icon: Icons.luggage_outlined,
          ),
        if (ride.isAc)
          _Chip(
            label: 'ac'.tr,
            color: Colors.grey.shade200,
            textColor: Colors.black87,
            icon: Icons.ac_unit,
          ),
        if (ride.hasMusic)
          _Chip(
            label: 'music'.tr,
            color: Colors.grey.shade200,
            textColor: Colors.black87,
            icon: Icons.music_note_outlined,
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final IconData? icon;

  const _Chip({
    required this.label,
    required this.color,
    required this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
