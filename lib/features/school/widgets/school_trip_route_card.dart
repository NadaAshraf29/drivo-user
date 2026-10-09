import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/school/domain/models/school_trip_model.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SchoolTripRouteCard extends StatelessWidget {
  final SchoolTripModel trip;
  final String currentPickupPoint;
  final VoidCallback onChangePickupPoint;

  const SchoolTripRouteCard({
    super.key,
    required this.trip,
    required this.currentPickupPoint,
    required this.onChangePickupPoint,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePickup =
        currentPickupPoint.isNotEmpty ? currentPickupPoint : trip.pickupPoint;

    return Container(
      padding: const EdgeInsets.all(20),
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
          // Top: Route Name & Duration Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                trip.routeName,
                style: textBold.copyWith(
                  fontSize: 18,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'monthly'.tr,
                  style: textMedium.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: const Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ROUTE
          Text(
            'route'.tr.toUpperCase(),
            style: textRegular.copyWith(
              fontSize: 11,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${trip.fromArea} → ${trip.toSchool}',
            style: textSemiBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),

          // PICKUP POINT + Change button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'pickup_point_title'.tr.toUpperCase(),
                    style: textRegular.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    effectivePickup,
                    style: textSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onChangePickupPoint,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'change'.tr,
                    style: textSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: const Color(0xFF00A0E9),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // DESTINATION
          Text(
            'destination_caps'.tr,
            style: textRegular.copyWith(
              fontSize: 11,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trip.destinationPoint,
            style: textSemiBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),

          // SCHEDULE & PRICE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'schedule'.tr.toUpperCase(),
                      style: textRegular.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trip.returnTime.isNotEmpty
                          ? 'Departure at ${trip.scheduleTime} · ${'return_suffix'.tr} ${trip.returnTime}'
                          : trip.scheduleTime,
                      style: textSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'price'.tr.toUpperCase(),
                    style: textRegular.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${trip.price.toStringAsFixed(0)} EGP',
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: const Color(0xFF00A0E9),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // SUBSCRIPTION & VALID UNTIL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Expanded(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       // Text(
              //       //   'subscription'.tr.toUpperCase(),
              //       //   style: textRegular.copyWith(
              //       //     fontSize: 11,
              //       //     color: const Color(0xFF94A3B8),
              //       //     letterSpacing: 0.5,
              //       //   ),
              //       // ),
              //       const SizedBox(height: 4),
              //       // Text(
              //       //   '${'monthly'.tr} · ${trip.subscriptionDurationDays} ${'days_count'.tr}',
              //       //   style: textSemiBold.copyWith(
              //       //     fontSize: Dimensions.fontSizeSmall,
              //       //     color: const Color(0xFF0F172A),
              //       //   ),
              //       // ),
              //     ],
              //   ),
              // ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'valid_until'.tr.toUpperCase(),
                    style: textRegular.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trip.validUntil,
                    style: textSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
