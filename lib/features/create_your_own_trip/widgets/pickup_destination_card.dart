import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/controller/create_your_own_trip_controller.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/domain/models/trip_location_point.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class PickupDestinationCard extends StatelessWidget {
  const PickupDestinationCard({super.key});

  void _openLocationPicker({
    required BuildContext context,
    required bool isPickup,
    required int index,
    required CreateYourOwnTripController controller,
  }) {
    Get.to(
      () => PickMapScreen(
        type: isPickup ? LocationType.accessLocation : LocationType.to,
        onLocationPicked: (Position position, String address) {
          if (isPickup) {
            controller.updatePickupPoint(
              index,
              address,
              position.latitude,
              position.longitude,
            );
          } else {
            controller.updateDestinationPoint(
              index,
              address,
              position.latitude,
              position.longitude,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateYourOwnTripController>(
      builder: (controller) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- PICKUP SECTION HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.trip_origin_rounded,
                          color: Color(0xFF00A0E9),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'pickup_points'.tr,
                        style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => controller.addPickupPoint(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded, size: 14, color: Color(0xFF00A0E9)),
                          const SizedBox(width: 2),
                          Text(
                            'add_point'.tr,
                            style: textBold.copyWith(
                              fontSize: 11,
                              color: const Color(0xFF00A0E9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // PICKUP POINTS LIST
              ...controller.pickupPoints.asMap().entries.map((entry) {
                final int idx = entry.key;
                final TripLocationPoint point = entry.value;
                final bool isLast = idx == controller.pickupPoints.length - 1;

                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                  child: _LocationItemRow(
                    badgeText: 'P${idx + 1}',
                    badgeColor: const Color(0xFF00A0E9),
                    badgeBgColor: const Color(0xFFE0F2FE),
                    title: point.name,
                    address: point.address.isNotEmpty
                        ? point.address
                        : 'select_pickup_location'.tr,
                    hasAddress: point.address.isNotEmpty,
                    canDelete: controller.pickupPoints.length > 1,
                    onTap: () => _openLocationPicker(
                      context: context,
                      isPickup: true,
                      index: idx,
                      controller: controller,
                    ),
                    onDelete: () => controller.removePickupPoint(idx),
                  ),
                );
              }),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
              ),

              // --- DESTINATION SECTION HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFFEF4444),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'destination_points'.tr,
                        style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => controller.addDestinationPoint(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded, size: 14, color: Color(0xFFEF4444)),
                          const SizedBox(width: 2),
                          Text(
                            'add_point'.tr,
                            style: textBold.copyWith(
                              fontSize: 11,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // DESTINATION POINTS LIST
              ...controller.destinationPoints.asMap().entries.map((entry) {
                final int idx = entry.key;
                final TripLocationPoint point = entry.value;
                final bool isLast = idx == controller.destinationPoints.length - 1;

                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                  child: _LocationItemRow(
                    badgeText: 'D${idx + 1}',
                    badgeColor: const Color(0xFFEF4444),
                    badgeBgColor: const Color(0xFFFEE2E2),
                    title: point.name,
                    address: point.address.isNotEmpty
                        ? point.address
                        : 'select_destination_location'.tr,
                    hasAddress: point.address.isNotEmpty,
                    canDelete: controller.destinationPoints.length > 1,
                    onTap: () => _openLocationPicker(
                      context: context,
                      isPickup: false,
                      index: idx,
                      controller: controller,
                    ),
                    onDelete: () => controller.removeDestinationPoint(idx),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _LocationItemRow extends StatelessWidget {
  final String badgeText;
  final Color badgeColor;
  final Color badgeBgColor;
  final String title;
  final String address;
  final bool hasAddress;
  final bool canDelete;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _LocationItemRow({
    required this.badgeText,
    required this.badgeColor,
    required this.badgeBgColor,
    required this.title,
    required this.address,
    required this.hasAddress,
    required this.canDelete,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasAddress ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          // Order Marker Pill
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: badgeBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                badgeText,
                style: textBold.copyWith(
                  fontSize: 12,
                  color: badgeColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Address Text
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textSemiBold.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address,
                    style: textMedium.copyWith(
                      fontSize: 13,
                      color: hasAddress
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Map Picker Icon
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.map_outlined,
                size: 20,
                color: hasAddress ? const Color(0xFF00A0E9) : const Color(0xFF94A3B8),
              ),
            ),
          ),

          // Delete Button (if > 1)
          if (canDelete) ...[
            const SizedBox(width: 2),
            InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
