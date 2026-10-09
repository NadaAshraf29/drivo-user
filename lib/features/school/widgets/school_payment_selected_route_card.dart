import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/school/domain/models/school_trip_model.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SchoolPaymentSelectedRouteCard extends StatelessWidget {
  final SchoolTripModel trip;
  final String pickupPoint;

  const SchoolPaymentSelectedRouteCard({
    super.key,
    required this.trip,
    required this.pickupPoint,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePickup =
        pickupPoint.isNotEmpty ? pickupPoint : trip.pickupPoint;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: SELECTED ROUTE + Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'selected_route'.tr,
                style: textRegular.copyWith(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  trip.hasReturnRide
                      ? 'going_return_selected'.tr
                      : 'one_way_ride'.tr,
                  style: textMedium.copyWith(
                    fontSize: 10,
                    color: const Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Route Name
          Text(
            trip.routeName,
            style: textBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          // Pickup
          Text(
            '${'pickup'.tr}: $effectivePickup',
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),

          // Destination
          Text(
            '${'destination'.tr}: ${trip.destinationPoint}',
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),

          // Departure & Return
          Text(
            trip.returnTime.isNotEmpty
                ? '${trip.scheduleTime} ${'departure_suffix'.tr} · ${trip.returnTime} ${'return_suffix'.tr}'
                : '${trip.scheduleTime} ${'departure_suffix'.tr}',
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),

          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 12),

          // Driver & Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'driver'.tr,
                    style: textRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 12),
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
