import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/university/domain/models/university_trip_model.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityTripRouteCard extends StatelessWidget {
  final UniversityTripModel trip;
  final String? pickupPoint;
  final VoidCallback onChangePickup;
  final VoidCallback? onNavigatePickup;
  final int seatsCount;

  const UniversityTripRouteCard({
    super.key,
    required this.trip,
    this.pickupPoint,
    required this.onChangePickup,
    this.onNavigatePickup,
    this.seatsCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    final double totalPrice = trip.price * (seatsCount > 0 ? seatsCount : 1);
    final String seatsLabel = (seatsCount == 1)
        ? ('seat'.tr.isNotEmpty && 'seat'.tr != 'seat' ? 'seat'.tr : 'Seat')
        : ('seats'.tr.isNotEmpty && 'seats'.tr != 'seats'
            ? 'seats'.tr
            : 'Seats');

    final String effectivePickup = (pickupPoint != null && pickupPoint!.isNotEmpty)
        ? pickupPoint!
        : trip.pickupPoint;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top: Route Name & Duration Badge
          if (trip.routeName.isNotEmpty) ...[
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
          ],

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
            '${trip.fromArea} → ${trip.toUniversity}',
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'pickup_point_title'.tr.isNotEmpty &&
                              'pickup_point_title'.tr != 'pickup_point_title'
                          ? 'pickup_point_title'.tr.toUpperCase()
                          : 'PICKUP POINT',
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
              ),
              if (onNavigatePickup != null) ...[
                InkWell(
                  onTap: onNavigatePickup,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0F2FE),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.directions_rounded,
                        size: 18,
                        color: Color(0xFF00A0E9),
                      ),
                    ),
                  ),
                ),
              ],
              InkWell(
                onTap: onChangePickup,
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
            'destination_caps'.tr.isNotEmpty &&
                    'destination_caps'.tr != 'destination_caps'
                ? 'destination_caps'.tr
                : 'DESTINATION',
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

          const Divider(color: Color(0xFFF1F5F9), thickness: 1),
          const SizedBox(height: 14),

          // SCHEDULE & PRICE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          ? 'Departure at ${trip.scheduleTime} · ${'return_suffix'.tr.isNotEmpty && 'return_suffix'.tr != 'return_suffix' ? 'return_suffix'.tr : 'Return at'} ${trip.returnTime}'
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
                    '${totalPrice.toStringAsFixed(0)} EGP',
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: const Color(0xFF00A0E9),
                    ),
                  ),
                  if (seatsCount > 1) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${trip.price.toStringAsFixed(0)} EGP × $seatsCount $seatsLabel',
                      style: textMedium.copyWith(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // VALID UNTIL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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

