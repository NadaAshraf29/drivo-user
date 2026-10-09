import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/controller/pool_stop_pickup_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/pool_ride_model.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/ride_card_widgets/ride_card_action_button_widget.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/ride_card_widgets/ride_card_header_widget.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/ride_card_widgets/ride_card_location_points_widget.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/ride_card_widgets/ride_card_price_widget.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/ride_card_widgets/ride_card_tags_widget.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/ride_card_widgets/ride_card_time_route_widget.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/screens/trip_details_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

import '../../ride/screens/search_trip_details.dart';

class RideCardWidget extends StatelessWidget {
  final PoolRide ride;
  final int index;
  final bool fromSearch;
  final PoolStopPickupController controller;
  final bool fromAvailable;

  const RideCardWidget({
    super.key,
    required this.ride,
    required this.index,
    required this.fromSearch,
    required this.controller,
    this.fromAvailable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE7EC)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x08163247),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header (Avatar, Name, Rating, Vehicle, Top Rated Chip)
          RideCardHeaderWidget(
            driver: ride.driver,
            vehicle: ride.vehicle,
          ),

          const SizedBox(height: 8),

          // 2. Price
          RideCardPriceWidget(
            price: ride.price,
          ),

          const SizedBox(height: 8),

          // 3. Time Route Timeline
          RideCardTimeRouteWidget(
            startTime: ride.startTime,
            departureTime: ride.departureTime,
            returnTime: ride.returnTime,
            startLat: ride.pickupMatchPoint.lat != 0
                ? ride.pickupMatchPoint.lat
                : ride.boardingPointStart?.latitude,
            startLng: ride.pickupMatchPoint.lng != 0
                ? ride.pickupMatchPoint.lng
                : ride.boardingPointStart?.longitude,
            endLat: ride.dropoffMatchPoint.lat != 0
                ? ride.dropoffMatchPoint.lat
                : ride.boardingPointEnd?.latitude,
            endLng: ride.dropoffMatchPoint.lng != 0
                ? ride.dropoffMatchPoint.lng
                : ride.boardingPointEnd?.longitude,
          ),

          const SizedBox(height: 8),

          // 4. Pickup & Dropoff Location Points
          RideCardLocationPointsWidget(
            pickupAddress: ride.pickupAddress,
            dropoffAddress: ride.dropoffAddress,
          ),

          const SizedBox(height: 8),

          // 5. Tags (Seats left, Luggage)
          RideCardTagsWidget(
            seatsAvailable: ride.seatsAvailable,
            allowLuggage: ride.allowLuggage,
          ),

          const SizedBox(height: 8),

          // 6. Action Button
          fromAvailable
              ? SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: ElevatedButton(
                    onPressed: () {
                      fromSearch
                          ? Get.to(
                              () => SearchTripDetailsScreen(
                                trip: ride,
                                fromSearch: fromSearch,
                                rideController: Get.find<RideController>(),
                              ),
                            )
                          : Get.to(
                              () => TripDetailsScreen(
                                trip: ride,
                                fromSearch: fromSearch,
                                rideController: Get.find<RideController>(),
                              ),
                            );
                      // Get.to(
                      //   () => SetDestinationCarPoolScreen(
                      //     carpoolType: ride.carpoolType,
                      //   ),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE9F7FC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'search_for_rides'.tr,
                      style: textBold.copyWith(
                        color: const Color(0xFF079CD7),
                        fontSize: 9,
                      ),
                    ),
                  ),
                )
              : RideCardActionButtonWidget(
                  isLoading: controller.isJoining(ride.routeId),
                  onPressed: () {
                    fromSearch
                        ? Get.to(
                            () => SearchTripDetailsScreen(
                              trip: ride,
                              fromSearch: fromSearch,
                              rideController: Get.find<RideController>(),
                            ),
                          )
                        : Get.to(
                            () => TripDetailsScreen(
                              trip: ride,
                              fromSearch: fromSearch,
                              rideController: Get.find<RideController>(),
                            ),
                          );
                  },
                ),
        ],
      ),
    );
  }
}
