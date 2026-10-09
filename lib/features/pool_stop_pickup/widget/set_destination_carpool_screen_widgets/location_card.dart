import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/location_input_field.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/location_suggestion_list.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';

class LocationCard extends StatelessWidget {
  final RideController rideController;
  final LocationController locationController;
  final FocusNode pickFocus;
  final FocusNode destinationFocus;
  final void Function(LocationType type, LocationController controller)
      onOpenMap;
  final Key? pickupKey;
  final Key? destinationKey;

  const LocationCard({
    super.key,
    required this.rideController,
    required this.locationController,
    required this.pickFocus,
    required this.destinationFocus,
    required this.onOpenMap,
    this.pickupKey,
    this.destinationKey,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRideLocked = false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KeyedSubtree(
          key: pickupKey,
          child: LocationInputField(
          label: 'from'.tr.isNotEmpty && 'from'.tr != 'from' ? 'from'.tr : 'FROM',
          prefix: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF00A0E9),
              shape: BoxShape.circle,
            ),
          ),
          isReadOnly: isRideLocked,
          focusNode: pickFocus,
          controller: locationController.pickupLocationController,
          onChanged: (value) => Get.find<LocationController>()
              .searchLocation(context, value, type: LocationType.from),
          onTap: () {},
          onMapTap: () => onOpenMap(LocationType.from, locationController),
          mapIconColor: const Color(0xFF00A0E9),
        ),
        ),
        LocationSuggestionList(
          locationController: locationController,
          targetType: LocationType.from,
        ),
        const SizedBox(height: 10),
        KeyedSubtree(
          key: destinationKey,
          child: LocationInputField(
          label: 'to'.tr.isNotEmpty && 'to'.tr != 'to' ? 'to'.tr : 'TO',
          hint: 'choose_destination'.tr.isNotEmpty &&
                  'choose_destination'.tr != 'choose_destination'
              ? 'choose_destination'.tr
              : 'Choose destination',
          prefix: const Icon(
            Icons.location_on_outlined,
            color: Color(0xFFEF4444),
            size: 18,
          ),
          isReadOnly: isRideLocked,
          focusNode: destinationFocus,
          controller: locationController.destinationLocationController,
          onChanged: (value) => Get.find<LocationController>()
              .searchLocation(context, value.trim(), type: LocationType.to),
          onTap: () {},
          onMapTap: () => onOpenMap(LocationType.to, locationController),
          mapIconColor: const Color(0xFFEF4444),
        ),
        ),
        LocationSuggestionList(
          locationController: locationController,
          targetType: LocationType.to,
        ),
      ],
    );
  }
}
