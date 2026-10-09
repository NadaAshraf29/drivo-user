import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/one_trip_widgets/one_trip_driver_info_card.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/one_trip_widgets/one_trip_payment_methods_card.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/one_trip_widgets/one_trip_route_summary_card.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class DriverAcceptedTripScreen extends StatefulWidget {
  final String driverName;
  final String vehicleInfo;
  final String ratingText;
  final String licensePlate;
  final String pickupAddress;
  final String destinationAddress;
  final String dateText;
  final String timeText;
  final int passengersCount;
  final double fareAmount;

  const DriverAcceptedTripScreen({
    super.key,
    required this.driverName,
    required this.vehicleInfo,
    required this.ratingText,
    required this.licensePlate,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.dateText,
    required this.timeText,
    required this.passengersCount,
    required this.fareAmount,
  });

  @override
  State<DriverAcceptedTripScreen> createState() =>
      _DriverAcceptedTripScreenState();
}

class _DriverAcceptedTripScreenState extends State<DriverAcceptedTripScreen> {
  String _selectedPaymentMethod = 'digital_payment';
  bool _isProcessing = false;

  Future<void> _payAndConfirmTrip() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() => _isProcessing = false);
    showCustomSnackBar('payment_submitted'.tr, isError: false);
    Get.offAll(() => const DashboardScreen());
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
            children: [
              // Top Bar
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
              const SizedBox(height: 10),

              // Top Car Header Icon
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.directions_car_filled_rounded,
                      size: 46,
                      color: Color(0xFF00A0E9),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF00A0E9),
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'a_driver_accepted_your_trip'.tr,
                style: textBold.copyWith(
                  fontSize: 22,
                  color: const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'complete_payment_to_confirm_trip'.tr,
                style: textRegular.copyWith(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Driver details card
              OneTripDriverInfoCard(
                driverName: widget.driverName,
                vehicleInfo: widget.vehicleInfo,
                ratingText: widget.ratingText,
                licensePlate: widget.licensePlate,
              ),
              const SizedBox(height: 14),

              // Trip route summary card
              OneTripRouteSummaryCard(
                pickupAddress: widget.pickupAddress,
                destinationAddress: widget.destinationAddress,
                dateText: widget.dateText,
                timeText: widget.timeText,
                seatsCount: widget.passengersCount,
              ),
              const SizedBox(height: 14),

              // Fare banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFBAE6FD),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Color(0xFF00A0E9),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'trip_fare'.tr,
                          style: textRegular.copyWith(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          '${widget.fareAmount.toStringAsFixed(0)} EGP',
                          style: textBold.copyWith(
                            fontSize: 20,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Payment method selector
              OneTripPaymentMethodsCard(
                selectedMethod: _selectedPaymentMethod,
                onMethodSelected: (val) {
                  setState(() => _selectedPaymentMethod = val);
                },
              ),
              const SizedBox(height: 24),

              // Pay & Confirm Trip Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _payAndConfirmTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A0E9),
                    disabledBackgroundColor: Colors.black54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: _isProcessing
                      ? const SpinKitThreeBounce(
                          color: Colors.white,
                          size: 22,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_outline_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'pay_amount_and_confirm_trip'
                                  .tr
                                  .replaceAll('@amount',
                                      '${widget.fareAmount.toStringAsFixed(0)} EGP'),
                              style: textBold.copyWith(
                                color: Colors.white,
                                fontSize: Dimensions.fontSizeLarge,
                              ),
                            ),
                          ],
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
