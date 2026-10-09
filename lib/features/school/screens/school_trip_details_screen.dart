import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/school/controllers/school_controller.dart';
import 'package:ride_sharing_user_app/features/school/domain/models/school_trip_model.dart';
import 'package:ride_sharing_user_app/features/school/screens/school_change_pickup_screen.dart';
import 'package:ride_sharing_user_app/features/school/screens/school_payment_screen.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_driver_card.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_return_ride_included_card.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_top_bar.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_trip_route_card.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_trip_status_card.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SchoolTripDetailsScreen extends StatelessWidget {
  final SchoolTripModel trip;

  const SchoolTripDetailsScreen({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: GetBuilder<SchoolController>(
          builder: (schoolCtrl) {
            final currentPickup = schoolCtrl.selectedPickupPoint.isNotEmpty
                ? schoolCtrl.selectedPickupPoint
                : trip.pickupPoint;

            return Column(
              children: [
                const SchoolTopBar(
                    showBackButton: true), // Title, Subtitle and Status Badge
                Container(
                  color: Colors.white,
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
                            'school_trip'.tr,
                            style: textBold.copyWith(
                              fontSize: 24,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'your_active_school_subscription'.tr,
                            style: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      // SchoolTripStatusCard(status: 'active'.tr),
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
                        SchoolTripRouteCard(
                          trip: trip,
                          currentPickupPoint: currentPickup,
                          onChangePickupPoint: () async {
                            final selectedPoint = await Get.to(
                              () => SchoolChangePickupScreen(trip: trip),
                            );
                            if (selectedPoint != null &&
                                selectedPoint is String &&
                                selectedPoint.isNotEmpty) {
                              schoolCtrl.setSelectedPickupPoint(selectedPoint);
                            }
                          },
                        ),
                        const SizedBox(height: 14),

                        // Return Ride Included Card
                        if (trip.hasReturnRide) ...[
                          SchoolReturnRideIncludedCard(
                            schoolName: trip.toSchool,
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Driver Card
                        SchoolDriverCard(
                          driverName: trip.driverName,
                          driverAvatar: trip.driverAvatar,
                          driverVehicle: trip.driverVehicle,
                          driverRating: trip.driverRating,
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
                        color: Colors.black.withOpacity(0.04),
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
                            () => SchoolPaymentScreen(
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
