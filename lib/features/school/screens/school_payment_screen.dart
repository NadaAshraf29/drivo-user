import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/payment_success_dialog.dart';
import 'package:ride_sharing_user_app/features/payment/widget/carpool_payment_widgets/carpool_payment_instapay_account_card_widget.dart';
import 'package:ride_sharing_user_app/features/school/controllers/school_controller.dart';
import 'package:ride_sharing_user_app/features/school/domain/models/school_subscribe_request.dart';
import 'package:ride_sharing_user_app/features/school/domain/models/school_trip_model.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_payment_method_selector.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_payment_selected_route_card.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_payment_total_card.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_subscription_duration_card.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_top_bar.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_upload_receipt_card.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SchoolPaymentScreen extends StatefulWidget {
  final SchoolTripModel trip;
  final String pickupPoint;

  const SchoolPaymentScreen({
    super.key,
    required this.trip,
    required this.pickupPoint,
  });

  @override
  State<SchoolPaymentScreen> createState() => _SchoolPaymentScreenState();
}

class _SchoolPaymentScreenState extends State<SchoolPaymentScreen> {
  String _selectedDuration = 'monthly';
  List<int> _selectedDays = [0, 1, 2, 3, 4]; // Sun - Thu (5 days default)
  String _selectedPaymentMethod = 'instapay';
  File? _receiptImage;

  double get _totalAmount {
    final daysPerWeek = _selectedDays.length;
    final dailyRate = widget.trip.price;
    int weeksMultiplier = 4;
    if (_selectedDuration == 'weekly') {
      weeksMultiplier = 1;
    }
    return (dailyRate * daysPerWeek * weeksMultiplier).toDouble();
  }

  String get _durationLabel {
    final daysPerWeek = _selectedDays.length;
    int weeksMultiplier = 4;
    String title = 'one_month'.tr;
    if (_selectedDuration == 'weekly') {
      weeksMultiplier = 1;
      title = 'one_week'.tr;
    }
    final totalDays = daysPerWeek * weeksMultiplier;
    return '$title · $totalDays ${'days_count'.tr} ($daysPerWeek ${'days_per_week'.tr})';
  }

  void _onPayAndActivate(SchoolController schoolCtrl) async {
    if (_receiptImage == null) {
      showCustomSnackBar('please_upload_payment_receipt'.tr);
      return;
    }

    final request = SchoolSubscribeRequest(
      tripId: widget.trip.id,
      pickupPoint: widget.pickupPoint.isNotEmpty
          ? widget.pickupPoint
          : widget.trip.pickupPoint,
      subscriptionDuration: _selectedDuration,
      paymentMethod: _selectedPaymentMethod,
      amount: _totalAmount,
      needReturnRide: widget.trip.hasReturnRide,
    );

    final success = await schoolCtrl.submitSubscription(
      request: request,
      receiptImage: _receiptImage,
    );

    if (!mounted) return;

    if (success) {
      Get.dialog(
        PaymentSuccessDialog(
          title: 'school_subscription_activated'.tr,
          subtitle: 'school_subscription_success_message'.tr,
          routeName: widget.trip.routeName,
          pickupPoint: widget.pickupPoint.isNotEmpty
              ? widget.pickupPoint
              : widget.trip.pickupPoint,
          destination: widget.trip.toSchool,
          amount: _totalAmount,
          paymentMethod: _selectedPaymentMethod,
        ),
        barrierDismissible: false,
      );
    } else {
      showCustomSnackBar('payment_failed'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: GetBuilder<SchoolController>(
          builder: (schoolCtrl) {
            return Column(
              children: [
                const SchoolTopBar(showBackButton: true),
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: EdgeInsetsDirectional.only(
                    bottom: 8,
                    start: Dimensions.paddingSizeDefault,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'school'.tr,
                        style: textBold.copyWith(
                          fontSize: 24,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'choose_school_route_pickup'.tr,
                        style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title: school / Subtitle: Choose your school route and pickup point.

                        const SizedBox(height: 16),

                        // Selected Route Card
                        SchoolPaymentSelectedRouteCard(
                          trip: widget.trip,
                          pickupPoint: widget.pickupPoint,
                        ),
                        const SizedBox(height: 20),

                        // Subscription Duration Selector
                        SchoolSubscriptionDurationCard(
                          selectedDuration: _selectedDuration,
                          selectedDays: _selectedDays,
                          dailyUnitPrice: widget.trip.price,
                          onSelect: (dur) {
                            setState(() {
                              _selectedDuration = dur;
                            });
                          },
                          onDaysChanged: (days) {
                            setState(() {
                              _selectedDays = days;
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        // Payment Method Selector
                        SchoolPaymentMethodSelector(
                          selectedMethod: _selectedPaymentMethod,
                          onSelectMethod: (m) {
                            setState(() {
                              _selectedPaymentMethod = m;
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        // InstaPay Account Copy Details (Number & Name)
                        if (_selectedPaymentMethod == 'instapay') ...[
                          CarpoolPaymentInstapayAccountCardWidget(
                            paymentAccounts: const [
                              {
                                'label': 'InstaPay',
                                'account_number': '01200924442',
                                'account_holder': 'Drivo',
                              }
                            ],
                            onCopy: (value, label) {
                              Clipboard.setData(ClipboardData(text: value));
                              showCustomSnackBar(
                                '$label copied to clipboard',
                                isError: false,
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Upload Receipt Card
                        SchoolUploadReceiptCard(
                          receiptImage: _receiptImage,
                          onImageSelected: (img) {
                            setState(() {
                              _receiptImage = img;
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        // Total Card
                        SchoolPaymentTotalCard(
                          totalAmount: _totalAmount,
                          durationLabel: _durationLabel,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Bar with Pay & Activate Button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: const Color(0xFFE2E8F0)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: schoolCtrl.isSubscribing
                            ? null
                            : () => _onPayAndActivate(schoolCtrl),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A0E9),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: schoolCtrl.isSubscribing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'pay_and_activate'.tr,
                                style: textBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
