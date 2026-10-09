import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/university/controllers/university_controller.dart';
import 'package:ride_sharing_user_app/features/university/domain/models/university_trip_model.dart';
import 'package:ride_sharing_user_app/features/university/screens/university_change_pickup_screen.dart';
import 'package:ride_sharing_user_app/features/university/screens/university_payment_screen.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_driver_card.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_return_ride_included_card.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_top_bar.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_trip_route_card.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityTripDetailsScreen extends StatelessWidget {
  final UniversityTripModel trip;

  const UniversityTripDetailsScreen({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: GetBuilder<UniversityController>(
          builder: (uniCtrl) {
            final currentPickup = uniCtrl.selectedPickupPoint.isNotEmpty
                ? uniCtrl.selectedPickupPoint
                : trip.pickupPoint;

            return Column(
              children: [
                const UniversityTopBar(showBackButton: true),
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: EdgeInsetsDirectional.only(
                    bottom: 8,
                    start: Dimensions.paddingSizeDefault,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'university_trip'.tr,
                            style: textBold.copyWith(
                              fontSize: 24,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'your_active_university_subscription'.tr,
                            style: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Route Card with Change pickup point trigger
                        UniversityTripRouteCard(
                          trip: trip,
                          pickupPoint: currentPickup,
                          seatsCount: uniCtrl.lastSearchRequest?.seats ?? 1,
                          onChangePickup: () async {
                            final selectedPoint = await Get.to(
                              () => UniversityChangePickupScreen(
                                trip: trip,
                                currentPickupPoint: currentPickup,
                              ),
                            );
                            if (selectedPoint != null &&
                                selectedPoint is String &&
                                selectedPoint.isNotEmpty) {
                              uniCtrl.setSelectedPickupPoint(selectedPoint);
                            }
                          },
                        ),
                        const SizedBox(height: 14),

                        // Return Ride Included Card
                        if (trip.hasReturnRide) ...[
                          UniversityReturnRideIncludedCard(
                            university: trip.toUniversity,
                            rating: trip.driverRating,
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Driver Card
                        UniversityDriverCard(
                          driverName: trip.driverName,
                          vehicle: trip.driverVehicle,
                          rating: trip.driverRating,
                          driverImage: trip.driverImage,
                          onDetails: () {},
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Bar with Book Now Button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: const Color(0xFFE2E8F0)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(
                            () => UniversityPaymentScreen(
                              trip: trip,
                              pickupPoint: currentPickup,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A0E9),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'book_now'.tr,
                          style: textBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

