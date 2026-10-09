import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/available_trips/controllers/available_trips_controller.dart';
import 'package:ride_sharing_user_app/features/available_trips/screens/available_trips_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'home_available_carpool_card.dart';

class HomeAvailableCarpoolSection extends StatelessWidget {
  const HomeAvailableCarpoolSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AvailableTripsController>(
      builder: (controller) {
        if (controller.availableTrips.isEmpty) return const SizedBox.shrink();

        final preview = controller.availableTrips.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'available_carpool_trips'.tr,
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.to(() => const AvailableTripsScreen()),
                  child: Text(
                    'view_all'.tr,
                    style: textMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            HomeAvailableCarpoolCard(ride: preview),
          ],
        );
      },
    );
  }
}
