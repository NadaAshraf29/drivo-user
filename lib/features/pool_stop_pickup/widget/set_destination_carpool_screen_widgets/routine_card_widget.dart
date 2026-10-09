import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/gender_selector.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/location_input_field.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/location_suggestion_list.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'dart:math' as math;

class RoutineCardWidget extends StatelessWidget {
  final RideController rideController;
  final LocationController locationController;
  final FocusNode pickFocus;
  final FocusNode destinationFocus;
  final void Function(LocationType type, LocationController controller)
      onOpenMap;
  final VoidCallback onPickDepartureTime;
  final VoidCallback onPickReturnTime;
  final String departureTimeStr;
  final String returnTimeStr;
  final String selectedGender;
  final ValueChanged<String> onGenderChanged;

  const RoutineCardWidget({
    super.key,
    required this.rideController,
    required this.locationController,
    required this.pickFocus,
    required this.destinationFocus,
    required this.onOpenMap,
    required this.onPickDepartureTime,
    required this.onPickReturnTime,
    required this.departureTimeStr,
    required this.returnTimeStr,
    required this.selectedGender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtitle instruction
          Text(
            'Add your pickup and destination for this Routine.'.tr,
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Pickup section header
          Text(
            'Pickup location'.tr,
            style: textBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          LocationInputField(
            prefix: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.cyan.shade100,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF08A9F0), width: 3),
              ),
            ),
            isReadOnly: false,
            focusNode: pickFocus,
            controller: locationController.pickupLocationController,
            onChanged: (value) => Get.find<LocationController>()
                .searchLocation(context, value, type: LocationType.from),
            onMapTap: () => onOpenMap(LocationType.from, locationController),
          ),
          LocationSuggestionList(
            locationController: locationController,
            targetType: LocationType.from,
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Destination section header
          Text(
            'Destination'.tr,
            style: textBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          LocationInputField(
            prefix: Transform(
              alignment: Alignment.center,
              transform: Get.find<LocalizationController>().isLtr
                  ? Matrix4.rotationY(0)
                  : Matrix4.rotationY(math.pi),
              child: Image.asset(
                Images.activityDirection,
                width: 18,
                height: 18,
                color: Colors.redAccent,
              ),
            ),
            isReadOnly: false,
            focusNode: destinationFocus,
            controller: locationController.destinationLocationController,
            onChanged: (value) => Get.find<LocationController>()
                .searchLocation(context, value, type: LocationType.to),
            onMapTap: () => onOpenMap(LocationType.to, locationController),
          ),
          LocationSuggestionList(
            locationController: locationController,
            targetType: LocationType.to,
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Schedule Header
          Text(
            'Schedule'.tr,
            style: textBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Work Days Tile
          // Container(
          //   padding: const EdgeInsets.symmetric(
          //     horizontal: Dimensions.paddingSizeDefault,
          //     vertical: 12,
          //   ),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(16),
          //     border: Border.all(color: Colors.grey.shade300),
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text(
          //             'WORK DAYS'.tr,
          //             style: textBold.copyWith(
          //               fontSize: 10,
          //               color: Colors.grey.shade600,
          //               letterSpacing: 0.5,
          //             ),
          //           ),
          //           const SizedBox(height: 4),
          //           Text(
          //             'Sunday – Thursday'.tr,
          //             style: textBold.copyWith(
          //               fontSize: Dimensions.fontSizeDefault,
          //               color: Colors.black,
          //             ),
          //           ),
          //         ],
          //       ),
          //       Container(
          //         padding:
          //             const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          //         decoration: BoxDecoration(
          //           color: Colors.grey.shade100,
          //           borderRadius: BorderRadius.circular(20),
          //         ),
          //         child: Text(
          //           'Edit'.tr,
          //           style: textSemiBold.copyWith(
          //             fontSize: Dimensions.fontSizeSmall,
          //             color: const Color(0xFF08A9F0),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          // const SizedBox(height: Dimensions.paddingSizeSmall),

          // Departure & Return Pickers Row
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onPickDepartureTime,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAFB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8EC)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DEPARTURE'.tr,
                              style: textBold.copyWith(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              departureTimeStr,
                              style: textBold.copyWith(
                                fontSize: 10,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: InkWell(
                  onTap: onPickReturnTime,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                       color: const Color(0xFFF7FAFB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8EC)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RETURN'.tr,
                              style: textBold.copyWith(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              returnTimeStr,
                              style: textBold.copyWith(
                                fontSize: 10,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Gender Selector
          GenderSelector(
            value: selectedGender,
            onChanged: onGenderChanged,
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),

          // Route Saved Info Banner
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info,
                  color: Color(0xFF08A9F0),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your route is saved after subscription'.tr,
                        style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You can later change your pickup point from the available points assigned to your route.'
                            .tr,
                        style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
