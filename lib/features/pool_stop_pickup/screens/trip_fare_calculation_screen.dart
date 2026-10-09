import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/controller/pool_stop_pickup_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/screens/trip_requested_posts_screen.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/one_trip_widgets/one_trip_route_summary_card.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TripFareCalculationScreen extends StatefulWidget {
  final String pickupAddress;
  final String destinationAddress;
  final String dateText;
  final String timeText;
  final int seatsCount;
  final double estimatedFare;

  const TripFareCalculationScreen({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.dateText,
    required this.timeText,
    required this.seatsCount,
    required this.estimatedFare,
  });

  @override
  State<TripFareCalculationScreen> createState() =>
      _TripFareCalculationScreenState();
}

class _TripFareCalculationScreenState
    extends State<TripFareCalculationScreen> {
  bool _isPosting = false;

  Future<void> _confirmAndPostTrip() async {
    setState(() => _isPosting = true);
    final rideController = Get.find<RideController>();
    if (Get.isRegistered<PoolStopPickupController>()) {
      Get.find<PoolStopPickupController>().selectedCarpoolType = 'trip';
    }

    await rideController.submitRideRequest(
      'online_trip_cashless'.tr,
      false,
      isCarpool: true,
      requiredSeats: widget.seatsCount,
    );

    if (!mounted) return;
    setState(() => _isPosting = false);

    Get.to(() => TripRequestedPostsScreen(
          pickupAddress: widget.pickupAddress,
          destinationAddress: widget.destinationAddress,
          dateText: widget.dateText,
          timeText: widget.timeText,
          seatsCount: widget.seatsCount,
          estimatedFare: widget.estimatedFare,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Back Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F7FA),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Header Title & Subtitle
              Text(
                'trip_fare'.tr,
                style: textBold.copyWith(
                  fontSize: 24,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'confirmed_booking'.tr,
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),

              // Top Confirmed Banner Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFBAE6FD),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00A0E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'trip_confirmed'.tr,
                            style: textBold.copyWith(
                              fontSize: 15,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'your_trip_is_generated_successfully'.tr,
                            style: textRegular.copyWith(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFBAE6FD),
                        ),
                      ),
                      child: Text(
                        'confirmed'.tr,
                        style: textBold.copyWith(
                          fontSize: 11,
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Route summary card
              OneTripRouteSummaryCard(
                pickupAddress: widget.pickupAddress,
                destinationAddress: widget.destinationAddress,
                dateText: widget.dateText,
                timeText: widget.timeText,
                seatsCount: widget.seatsCount,
              ),
              const SizedBox(height: 14),

              // Estimated Fare Card
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0F2FE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Color(0xFF00A0E9),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'estimated_fare'.tr,
                      style: textBold.copyWith(
                        fontSize: 15,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.estimatedFare.toStringAsFixed(0)} ${'egp'.tr.isNotEmpty && 'egp'.tr != 'egp' ? 'egp'.tr : 'EGP'}',
                      style: textBold.copyWith(
                        fontSize: 32,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'fare_calculated_based_on_distance'.tr,
                      textAlign: TextAlign.center,
                      style: textRegular.copyWith(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Confirm & Post Trip Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isPosting ? null : _confirmAndPostTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A0E9),
                    disabledBackgroundColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: _isPosting
                      ? const SpinKitThreeBounce(
                          color: Colors.white,
                          size: 22,
                        )
                      : Text(
                          'confirm_and_post_trip'.tr,
                          style: textBold.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
// ponytail: extracted widget class — follow single class per file rule

/*
Archived Code:
    await rideController.submitRideRequest(
      'رحلة أونلاين بدون كاش',
      paymentMethod: 'digital_payment',
    );
*/

