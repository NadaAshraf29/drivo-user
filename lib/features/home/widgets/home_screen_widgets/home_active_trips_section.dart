import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'home_active_trip_item_card.dart';

class HomeActiveTripsSection extends StatelessWidget {
  const HomeActiveTripsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParcelController>(
      builder: (parcelController) {
        return GetBuilder<RideController>(
          builder: (rideController) {
            final hasParcel = parcelController.currentParcelState ==
                    ParcelDeliveryState.findingRider ||
                parcelController.currentParcelState ==
                    ParcelDeliveryState.acceptRider ||
                parcelController.currentParcelState ==
                    ParcelDeliveryState.otpSent ||
                parcelController.currentParcelState ==
                    ParcelDeliveryState.parcelOngoing ||
                parcelController.currentParcelState ==
                    ParcelDeliveryState.parcelComplete;

            final hasRide = rideController.rideDetails != null &&
                rideController.rideDetails!.type == 'ride_request' &&
                (rideController.rideDetails!.currentStatus == 'pending' ||
                    rideController.rideDetails!.currentStatus == 'accepted' ||
                    rideController.rideDetails!.currentStatus == 'ongoing' ||
                    (rideController.rideDetails!.currentStatus == 'completed' &&
                        rideController.rideDetails!.paymentStatus! ==
                            'unpaid') ||
                    (rideController.rideDetails!.currentStatus == 'cancelled' &&
                        rideController.rideDetails!.paymentStatus! ==
                            'unpaid'));

            final hasCarpool = rideController.carpoolTripDetails != null &&
                (rideController.carpoolTripDetails!.currentStatus ==
                        'pending' ||
                    rideController.carpoolTripDetails!.currentStatus ==
                        'accepted' ||
                    rideController.carpoolTripDetails!.currentStatus ==
                        'ongoing' ||
                    (rideController.carpoolTripDetails!.currentStatus ==
                            'completed' &&
                        rideController.carpoolTripDetails!.paymentStatus! ==
                            'unpaid') ||
                    (rideController.carpoolTripDetails!.currentStatus ==
                            'cancelled' &&
                        rideController.carpoolTripDetails!.paymentStatus! ==
                            'unpaid'));

            // if (!hasCarpool && !hasRide && !hasParcel) {
            //   return const SizedBox.shrink();
            // }

            final List<Widget> activeCards = [];

            if (true) {
              final trip = rideController.carpoolTripDetails;
              final eta = trip?.realEstamitedTimeText ??
                  trip?.formatedEstamitedTimeInMinutes ??
                  '';
              final seats = trip?.vehicle?.model?.seatCapacity;
              final String subtitle;
              if (eta.isNotEmpty && seats != null && seats > 0) {
                subtitle =
                    '${'pickup_in'.tr} $eta · ${'seat'.tr} 1 ${'of'.tr} $seats';
              } else if (eta.isNotEmpty) {
                subtitle = '${'pickup_in'.tr} $eta';
              } else {
                subtitle = 'active_carpool_trip'.tr;
              }

              activeCards.add(
                HomeActiveTripItemCard(
                  icon: Icons.group_outlined,
                  title: 'carpool_active'.tr,
                  subtitle: subtitle,
                  iconColor: const Color(0xFF1E8E3E),
                  iconBackgroundColor: const Color(0xFFE8F5E9),
                  onTap: () async {
                    await rideController.getCurrentCarpoolRideStatus(
                        fromRefresh: true);
                  },
                ),
              );
            }

            // if (hasRide) {
            //   final ride = rideController.rideDetails;
            //   final eta = ride?.formatedEstamitedTimeInMinutes ?? '';
            //   final String subtitle;
            //   if (eta.isNotEmpty) {
            //     subtitle = '${'pickup_in'.tr} $eta';
            //   } else {
            //     subtitle = 'active_ride'.tr;
            //   }

            //   activeCards.add(
            //     HomeActiveTripItemCard(
            //       icon: Icons.directions_car_outlined,
            //       title: 'ride_active'.tr,
            //       subtitle: subtitle,
            //       iconColor: const Color(0xFF1E8E3E),
            //       iconBackgroundColor: const Color(0xFFE8F5E9),
            //       onTap: () async {
            //         await rideController.getCurrentRideStatus(
            //             fromRefresh: true);
            //       },
            //     ),
            //   );
            // }

            // if (true) {
            //   activeCards.add(
            //     HomeActiveTripItemCard(
            //       icon: Icons.inventory_2_outlined,
            //       title: 'parcel_active'.tr,
            //       subtitle: 'parcel_delivery_in_progress'.tr,
            //       iconColor: const Color(0xFF1E8E3E),
            //       iconBackgroundColor: const Color(0xFFE8F5E9),
            //       onTap: () async {
            //         await parcelController.getCurrentParcelRide();
            //       },
            //     ),
            //   );
            // }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...activeCards.map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: Dimensions.paddingSizeSmall,
                    ),
                    child: card,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
