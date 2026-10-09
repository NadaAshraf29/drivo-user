import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/university/domain/models/university_trip_model.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityPaymentSelectedRouteCard extends StatelessWidget {
  final UniversityTripModel trip;
  final String currentPickupPoint;

  const UniversityPaymentSelectedRouteCard({
    super.key,
    required this.trip,
    required this.currentPickupPoint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
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
          // Top Header: Label + Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'selected_route'.tr,
                style: textMedium.copyWith(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (trip.hasReturnRide || trip.returnTime.isNotEmpty)
                      ? 'going_return_selected'.tr
                      : 'going_only_selected'.tr,
                  style: textMedium.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF00A0E9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Route Name
          Text(
            '${trip.routeName} · ${trip.toUniversity}',
            style: textBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          // Pickup & Destination
          Text(
            '${'pickup'.tr}: $currentPickupPoint',
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${'destination_label'.tr}: ${trip.destinationPoint}',
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            (trip.hasReturnRide || trip.returnTime.isNotEmpty)
                ? '${trip.scheduleTime} ${'departure_suffix'.tr} · ${trip.returnTime} ${'return_suffix'.tr}'
                : '${trip.scheduleTime} ${'departure_suffix'.tr}',
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),

          const Divider(color: Color(0xFFF1F5F9), thickness: 1),
          const SizedBox(height: 10),

          // Driver & Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '${'driver_label'.tr}  ',
                    style: textMedium.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    trip.driverName,
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Text(
                '${trip.price.toStringAsFixed(0)} EGP',
                style: textBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: const Color(0xFF00A0E9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
