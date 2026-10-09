import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/university/domain/models/university_active_trip_model.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityActiveTripCard extends StatelessWidget {
  final UniversityActiveTripModel trip;
  final VoidCallback onViewOngoingTrip;

  const UniversityActiveTripCard({
    super.key,
    required this.trip,
    required this.onViewOngoingTrip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF8FE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFBAE6FD),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Active tag & Subscription Type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'active'.tr,
                  style: textSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: const Color(0xFF00A0E9),
                  ),
                ),
              ),
              Text(
                trip.subscriptionType,
                style: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: const Color(0xFF00A0E9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title: Route & University
          Text(
            '${trip.routeName} · ${trip.universityName}',
            style: textBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 5),

          // Pickup & Time
          Text(
            '${'pickup_point_label'.tr}: ${trip.pickupPoint} · ${trip.pickupTime}',
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),

          // Bottom Row: Return Ride & View Ongoing Trip Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '${trip.hasReturnRide ? 'return_ride_included'.tr : 'one_way_ride'.tr} · ${'valid_until'.tr} ${trip.validUntil}',
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onViewOngoingTrip,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A0E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'view_ongoing_trip'.tr,
                      style: textBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        color: Colors.white,
                      ),
                    ),
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
