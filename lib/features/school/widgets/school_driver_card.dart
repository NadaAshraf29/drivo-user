import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/school/domain/models/school_trip_model.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SchoolDriverCard extends StatelessWidget {
  final String driverName;
  final String driverAvatar;
  final String driverVehicle;
  final double driverRating;
  final VoidCallback? onDetails;

  const SchoolDriverCard({
    super.key,
    required this.driverName,
    this.driverAvatar = 'A',
    required this.driverVehicle,
    required this.driverRating,
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final parsed = SchoolTripModel.parseVehicleName(driverVehicle);
    final displayVehicle = parsed.isNotEmpty
        ? parsed
        : (driverVehicle.trim().startsWith('{') ? 'Unknown' : driverVehicle);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Driver Avatar
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2FE),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                driverName[0].toUpperCase(),
                style: textBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: const Color(0xFF00A0E9),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Driver Name, Vehicle, Rating
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'driver'.tr.toUpperCase(),
                  style: textRegular.copyWith(
                    fontSize: 10,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  driverName,
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayVehicle,
                        style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      driverRating.toStringAsFixed(1),
                      style: textSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Details Action
          InkWell(
            onTap: onDetails,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'details'.tr,
                style: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
