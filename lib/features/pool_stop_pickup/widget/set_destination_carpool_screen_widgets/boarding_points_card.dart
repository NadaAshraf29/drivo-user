import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/controller/pool_stop_pickup_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/domain/models/boarding_point_model.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/boarding_points_dropdown.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class BoardingPointsCard extends StatelessWidget {
  final PoolStopPickupController poolController;
  final Key? pickupKey;
  final Key? destinationKey;

  const BoardingPointsCard({
    super.key,
    required this.poolController,
    this.pickupKey,
    this.destinationKey,
  });

  @override
  Widget build(BuildContext context) {
    if (poolController.isLoadingBoardingPoints) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Colors.black),
      );
    }

    final cities = poolController.availableCities;
    final startAreas =
        poolController.getAreasForCity(poolController.selectedStartCity);
    final endAreas =
        poolController.getAreasForCity(poolController.selectedEndCity);

    final isNorthCoast = poolController.selectedCarpoolType == 'north_coast' ||
        poolController.selectedCarpoolType == 'sahel';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= START LOCATION =================
        KeyedSubtree(
          key: pickupKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Start City Dropdown
              BoardingPointsDropdown<String>(
                hint: isNorthCoast ? 'Select Resort or Village' : 'select_city'.tr,
                label: 'From'.tr,
                leadingIcon: Icons.location_on_outlined,
                value: cities.contains(poolController.selectedStartCity)
                    ? poolController.selectedStartCity
                    : null,
                items: cities.map((city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city,
                        style: textRegular.copyWith(color: Colors.black)),
                  );
                }).toList(),
                onChanged: poolController.setSelectedStartCity,
              ),

              if (poolController.selectedStartCity != null) ...[
                const SizedBox(height: 8),
                // Start Area Dropdown
                BoardingPointsDropdown<BoardingPoint>(
                  hint: 'select_area'.tr,
                  value: startAreas
                          .contains(poolController.selectedBoardingPointStart)
                      ? poolController.selectedBoardingPointStart
                      : null,
                  items: startAreas.map((point) {
                    return DropdownMenuItem<BoardingPoint>(
                      value: point,
                      child: Text(poolController.getAreaName(point),
                          style: textRegular.copyWith(color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: poolController.setSelectedBoardingPointStart,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ================= END LOCATION =================
        KeyedSubtree(
          key: destinationKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // End City Dropdown
              BoardingPointsDropdown<String>(
                hint: isNorthCoast ? 'Select Resort or Village' : 'Choose destination'.tr,
                label: 'To'.tr,
                leadingIcon: Icons.location_on_outlined,
                leadingIconColor: Colors.red,
                value: cities.contains(poolController.selectedEndCity)
                    ? poolController.selectedEndCity
                    : null,
                items: cities.map((city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city,
                        style: textRegular.copyWith(color: Colors.black)),
                  );
                }).toList(),
                onChanged: poolController.setSelectedEndCity,
              ),

              if (poolController.selectedEndCity != null) ...[
                const SizedBox(height: 8),
                // End Area Dropdown
                BoardingPointsDropdown<BoardingPoint>(
                  hint: 'select_area'.tr,
                  value:
                      endAreas.contains(poolController.selectedBoardingPointEnd)
                          ? poolController.selectedBoardingPointEnd
                          : null,
                  items: endAreas.map((point) {
                    return DropdownMenuItem<BoardingPoint>(
                      value: point,
                      child: Text(poolController.getAreaName(point),
                          style: textRegular.copyWith(color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: poolController.setSelectedBoardingPointEnd,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
