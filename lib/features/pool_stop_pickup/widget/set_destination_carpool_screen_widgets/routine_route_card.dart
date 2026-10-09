import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/set_destination_carpool_screen_widgets/boarding_points_dropdown.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class RoutineRouteCard extends StatelessWidget {
  final List<String> startAddresses;
  final List<String> endAddresses;
  final String? selectedStartAddress;
  final String? selectedEndAddress;
  final ValueChanged<String?> onStartAddressChanged;
  final ValueChanged<String?> onEndAddressChanged;
  final Key? pickupKey;
  final Key? destinationKey;
  final bool isLoading;

  const RoutineRouteCard({
    super.key,
    required this.startAddresses,
    required this.endAddresses,
    required this.selectedStartAddress,
    required this.selectedEndAddress,
    required this.onStartAddressChanged,
    required this.onEndAddressChanged,
    this.pickupKey,
    this.destinationKey,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Color(0xFF00A0E9)),
      );
    }

    final allPickupText = 'all_pickup_locations'.tr.isNotEmpty &&
            'all_pickup_locations'.tr != 'all_pickup_locations'
        ? 'all_pickup_locations'.tr
        : 'All pickup locations';

    final allDestText = 'all_destinations'.tr.isNotEmpty &&
            'all_destinations'.tr != 'all_destinations'
        ? 'all_destinations'.tr
        : 'All destinations';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= START LOCATION (FROM) =================
        KeyedSubtree(
          key: pickupKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BoardingPointsDropdown<String?>(
                hint: allPickupText,
                label: 'From'.tr.isNotEmpty && 'From'.tr != 'From'
                    ? 'From'.tr
                    : 'From',
                leadingIcon: Icons.my_location_rounded,
                leadingIconColor: const Color(0xFF00A0E9),
                value: (selectedStartAddress != null &&
                        startAddresses.contains(selectedStartAddress))
                    ? selectedStartAddress
                    : null,
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      allPickupText,
                      style: textRegular.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ...startAddresses.map((addr) {
                    return DropdownMenuItem<String?>(
                      value: addr,
                      child: Text(
                        addr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textRegular.copyWith(
                          color: const Color(0xFF0F172A),
                          fontSize: 13,
                        ),
                      ),
                    );
                  }),
                ],
                onChanged: onStartAddressChanged,
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ================= END LOCATION (TO) =================
        KeyedSubtree(
          key: destinationKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BoardingPointsDropdown<String?>(
                hint: allDestText,
                label: 'To'.tr.isNotEmpty && 'To'.tr != 'To' ? 'To'.tr : 'To',
                leadingIcon: Icons.location_on_rounded,
                leadingIconColor: const Color(0xFFEF4444),
                value: (selectedEndAddress != null &&
                        endAddresses.contains(selectedEndAddress))
                    ? selectedEndAddress
                    : null,
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      allDestText,
                      style: textRegular.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ...endAddresses.map((addr) {
                    return DropdownMenuItem<String?>(
                      value: addr,
                      child: Text(
                        addr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textRegular.copyWith(
                          color: const Color(0xFF0F172A),
                          fontSize: 13,
                        ),
                      ),
                    );
                  }),
                ],
                onChanged: onEndAddressChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
