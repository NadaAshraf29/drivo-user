import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/location_input_field.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/location_suggestion_list.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class OneTripLocationCard extends StatelessWidget {
  final RideController rideController;
  final LocationController locationController;
  final FocusNode pickFocus;
  final FocusNode destinationFocus;
  final void Function(LocationType type, LocationController controller) onOpenMap;

  const OneTripLocationCard({
    super.key,
    required this.rideController,
    required this.locationController,
    required this.pickFocus,
    required this.destinationFocus,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'where_do_you_commute'.tr,
            style: textBold.copyWith(
              fontSize: 16,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'add_pickup_and_destination_for_trip'.tr,
            style: textRegular.copyWith(
              fontSize: 11,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 14),

          // FROM field
          LocationInputField(
            label: 'from'.tr.isNotEmpty && 'from'.tr != 'from'
                ? 'from'.tr
                : ('from_location_uppercase'.tr.isNotEmpty &&
                        'from_location_uppercase'.tr != 'from_location_uppercase'
                    ? 'from_location_uppercase'.tr
                    : 'FROM'),
            prefix: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF00A0E9),
                shape: BoxShape.circle,
              ),
            ),
            isReadOnly: false,
            focusNode: pickFocus,
            controller: locationController.pickupLocationController,
            onChanged: (value) => Get.find<LocationController>()
                .searchLocation(context, value, type: LocationType.from),
            onTap: () {},
            onMapTap: () => onOpenMap(LocationType.from, locationController),
            mapIconColor: const Color(0xFF00A0E9),
          ),
          LocationSuggestionList(
            locationController: locationController,
            targetType: LocationType.from,
          ),
          const SizedBox(height: 10),

          // TO field
          LocationInputField(
            label: 'to'.tr.isNotEmpty && 'to'.tr != 'to'
                ? 'to'.tr
                : ('to_location_uppercase'.tr.isNotEmpty &&
                        'to_location_uppercase'.tr != 'to_location_uppercase'
                    ? 'to_location_uppercase'.tr
                    : 'TO'),
            hint: 'choose_destination'.tr.isNotEmpty &&
                    'choose_destination'.tr != 'choose_destination'
                ? 'choose_destination'.tr
                : 'Choose destination',
            prefix: const Icon(
              Icons.location_on_outlined,
              color: Color(0xFFEF4444),
              size: 18,
            ),
            isReadOnly: false,
            focusNode: destinationFocus,
            controller: locationController.destinationLocationController,
            onChanged: (value) => Get.find<LocationController>()
                .searchLocation(context, value.trim(), type: LocationType.to),
            onTap: () {},
            onMapTap: () => onOpenMap(LocationType.to, locationController),
            mapIconColor: const Color(0xFFEF4444),
          ),
          LocationSuggestionList(
            locationController: locationController,
            targetType: LocationType.to,
          ),
        ],
      ),
    );
  }
}
// ponytail: extracted widget class — follow single class per file rule
