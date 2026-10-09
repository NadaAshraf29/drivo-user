import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/school/domain/models/school_active_trip_model.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SchoolOngoingRouteCard extends StatelessWidget {
  final SchoolActiveTripModel trip;

  const SchoolOngoingRouteCard({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pickup Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF00A0E9),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'pickup_caps'.tr,
                      style: textRegular.copyWith(
                        fontSize: 10,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trip.pickupAddress,
                      style: textSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${trip.pickupEtaMinutes} ${'min'.tr}',
                style: textSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: const Color(0xFF00A0E9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Destination Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'destination_caps'.tr,
                      style: textRegular.copyWith(
                        fontSize: 10,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trip.destinationAddress,
                      style: textSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                trip.estimatedArrival,
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 12),

          // Bottom schedule & seat details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'today'.tr} · ${trip.departureTime}',
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                trip.seatLabel,
                style: textMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
