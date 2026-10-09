import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/payment/screens/payment_screen.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/domain/models/trip_details_model.dart';
import 'package:ride_sharing_user_app/features/trip/screens/tripe_details_screen.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CarpoolTripItemView extends StatelessWidget {
  final TripDetails tripDetails;
  final bool isDetailsScreen;

  const CarpoolTripItemView({
    super.key,
    required this.tripDetails,
    this.isDetailsScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final Color cardBg = isDark ? Theme.of(context).cardColor : Colors.white;
    final Color borderColor = isDark ? Colors.white10 : const Color(0xFFEBEFF5);

    return InkWell(
      onTap: isDetailsScreen ? null : () => _onTap(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row: Category Chip + Status Chip
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F6FE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.groups_2_rounded,
                        color: Color(0xFF00A3EC),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'carpool'.tr,
                        style: textSemiBold.copyWith(
                          color: const Color(0xFF00A3EC),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                _statusChip(context, tripDetails.currentStatus ?? ''),
              ],
            ),
            const SizedBox(height: 14),

            // Route Timeline Section (Origin -> Destination)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 4),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00A3EC),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 38,
                      color: const Color(0xFFE2E8F0),
                    ),
                    const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFFFF5B5B),
                      size: 14,
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'pickup_location'.tr,
                        style: textMedium.copyWith(
                          fontSize: 10,
                          color: const Color(0xFF8C94A3),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (tripDetails.startAddress != null &&
                                tripDetails.startAddress!.trim().isNotEmpty &&
                                !TripDetails.isGenericPlaceholder(tripDetails.startAddress))
                            ? tripDetails.startAddress!.trim()
                            : (tripDetails.startAddressDisplay.isNotEmpty
                                ? tripDetails.startAddressDisplay
                                : (tripDetails.pickupAddress ?? '—')),
                        style: textBold.copyWith(
                          fontSize: 13,
                          color: isDark ? Colors.white : const Color(0xFF1E2432),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'destination'.tr,
                        style: textMedium.copyWith(
                          fontSize: 10,
                          color: const Color(0xFF8C94A3),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (tripDetails.endAddress != null &&
                                tripDetails.endAddress!.trim().isNotEmpty &&
                                !TripDetails.isGenericPlaceholder(tripDetails.endAddress))
                            ? tripDetails.endAddress!.trim()
                            : (tripDetails.endAddressDisplay.isNotEmpty
                                ? tripDetails.endAddressDisplay
                                : (tripDetails.destinationAddress ?? '—')),
                        style: textBold.copyWith(
                          fontSize: 13,
                          color: isDark ? Colors.white : const Color(0xFF1E2432),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Vehicle & Date Info Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.transparent : const Color(0xFFF1F5F9),
                ),
              ),
              child: Row(
                children: [
                  Image.asset(
                    Images.car,
                    height: 16,
                    width: 16,
                    color: const Color(0xFF00A3EC),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tripDetails.vehicle?.model?.name ??
                          tripDetails.vehicleCategory?.name ??
                          'carpool'.tr,
                      style: textMedium.copyWith(
                        fontSize: 12,
                        color: isDark ? Colors.white : const Color(0xFF1E2432),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    [
                      if (tripDetails.formattedDate.isNotEmpty)
                        tripDetails.formattedDate
                      else if (tripDetails.createdAt != null &&
                          tripDetails.createdAt!.isNotEmpty)
                        DateConverter.isoStringToDateTimeString(
                          tripDetails.createdAt!,
                        ),
                      if (tripDetails.formattedTime.isNotEmpty)
                        tripDetails.formattedTime,
                    ].where((e) => e.isNotEmpty).join(' · '),
                    style: textMedium.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF8C94A3),
                    ),
                  ),
                ],
              ),
            ),

            if (!isDetailsScreen) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tripDetails.refId != null && tripDetails.refId!.isNotEmpty
                        ? '#${tripDetails.refId}'
                        : '',
                    style: textMedium.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF8C94A3),
                    ),
                  ),
                  Text(
                    _fareText(),
                    style: textBold.copyWith(
                      fontSize: 16,
                      color: const Color(0xFF00A3EC),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _fareText() {
    final fare = (tripDetails.currentStatus == 'cancelled' ||
            tripDetails.currentStatus == 'completed')
        ? tripDetails.paidFare
        : (tripDetails.discountActualFare != null &&
                tripDetails.discountActualFare! > 0)
            ? tripDetails.discountActualFare
            : tripDetails.actualFare ?? tripDetails.estimatedFare;
    if (fare == null) return '';
    return PriceConverter.convertPrice(fare);
  }

  void _onTap(BuildContext context) {
    final status = tripDetails.currentStatus;
    if (status == 'accepted' ||
        status == 'ongoing' ||
        status == 'pending') {
      Get.find<RideController>().getRideDetails(tripDetails.id!).then((_) {
        if (status == 'accepted') {
          Get.find<RideController>()
              .updateRideCurrentState(RideState.acceptingRider);
        } else if (status == 'ongoing') {
          Get.find<RideController>()
              .updateRideCurrentState(RideState.ongoingRide);
        } else {
          Get.find<RideController>()
              .updateRideCurrentState(RideState.findingRider);
        }
        Get.to(() => const MapScreen(fromScreen: MapScreenType.carpool));
      });
    } else if (status == 'completed' && tripDetails.paymentStatus == 'unpaid') {
      Get.find<RideController>().getFinalFare(tripDetails.id!).then((_) {
        Get.to(() => const PaymentScreen(fromParcel: false));
      });
    } else {
      Get.to(() => TripeDetailsScreen(
            tripId: tripDetails.id!,
            fromCarpoolTab: true,
          ));
    }
  }

  Widget _statusChip(BuildContext context, String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'completed':
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        break;
      case 'cancelled':
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFC62828);
        break;
      case 'ongoing':
      case 'accepted':
      case 'pending':
        bg = const Color(0xFFE6F6FE);
        fg = const Color(0xFF00A3EC);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.tr,
        style: textSemiBold.copyWith(
          fontSize: 11,
          color: fg,
        ),
      ),
    );
  }
}
