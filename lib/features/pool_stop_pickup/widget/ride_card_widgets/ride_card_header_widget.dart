import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/driver_model.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/vehicle_model.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class RideCardHeaderWidget extends StatelessWidget {
  final Driver driver;
  final Vehicle vehicle;

  const RideCardHeaderWidget({
    super.key,
    required this.driver,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    final rating = driver.rating;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Driver Avatar
        CircleAvatar(
          radius: 16,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          backgroundImage:
              driver.profileImage != null && driver.profileImage!.isNotEmpty
                  ? NetworkImage(driver.profileImage!)
                  : null,
          child: driver.profileImage == null || driver.profileImage!.isEmpty
              ? Icon(
                  Icons.person,
                  color: Theme.of(context).primaryColor,
                  size: 19,
                )
              : null,
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        // Name & Vehicle info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      driver.fullName.isNotEmpty ? driver.fullName : 'Driver',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textBold.copyWith(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                    size: 13,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    rating?.toStringAsFixed(1) ?? '-',
                    style: textBold.copyWith(
                      fontSize: 9,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${vehicle.brand} ${vehicle.model}'.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        // Top Rated Chip
        if ((rating ?? 0) > 4.7)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'top_rated'.tr,
              style: textMedium.copyWith(
                color: const Color(0xFF4CAF50),
                fontSize: 8,
              ),
            ),
          ),
      ],
    );
  }
}
