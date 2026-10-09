import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paymob_sdk/flutter_paymob_sdk.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/payment_success_dialog.dart';
import 'package:ride_sharing_user_app/features/payment/domain/services/paymob_service.dart';
import 'package:ride_sharing_user_app/features/payment/widget/carpool_payment_widgets/carpool_payment_instapay_account_card_widget.dart';
import 'package:ride_sharing_user_app/features/payment/widget/carpool_payment_widgets/carpool_payment_success_bottom_sheet.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/university/controllers/university_controller.dart';
import 'package:ride_sharing_user_app/features/university/domain/models/university_subscribe_request.dart';
import 'package:ride_sharing_user_app/features/university/domain/models/university_trip_model.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_payment_method_selector.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_payment_selected_route_card.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_payment_total_card.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_subscription_duration_card.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_top_bar.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_upload_receipt_card.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class UniversityPaymentScreen extends StatefulWidget {
  final UniversityTripModel trip;
  final String pickupPoint;

  const UniversityPaymentScreen({
    super.key,
    required this.trip,
    required this.pickupPoint,
  });

  @override
  State<UniversityPaymentScreen> createState() =>
      _UniversityPaymentScreenState();
}

class _UniversityPaymentScreenState extends State<UniversityPaymentScreen> {
  String _selectedDuration = 'monthly';
  List<int> _selectedDays = [0, 1, 2, 3, 4]; // Sun - Thu (5 days default)
  String _selectedPaymentMethod = 'instapay';
  File? _receiptImage;
  bool _isPaymobSubmitting = false;

  DateTime? _parseValidUntilDate(String validUntilStr) {
    if (validUntilStr.trim().isEmpty) return null;
    final str = validUntilStr.trim();
    final now = DateTime.now();

    try {
      final isoDate = DateTime.tryParse(str);
      if (isoDate != null) return isoDate;

      if (str.contains('/')) {
        final parts = str.split('/');
        if (parts.length >= 2) {
          final p1 = int.tryParse(parts[0].trim());
          final p2 = int.tryParse(parts[1].trim());
          final yrRaw = parts.length >= 3 ? int.tryParse(parts[2].trim()) : null;
          if (p1 != null && p2 != null) {
            int day = p1;
            int month = p2;
            if (p1 <= 12 && p2 > 12) {
              month = p1;
              day = p2;
            }
            int targetYear;
            if (yrRaw != null) {
              targetYear = yrRaw < 100 ? 2000 + yrRaw : yrRaw;
            } else {
              targetYear = (month < now.month) ? now.year + 1 : now.year;
            }
            return DateTime(targetYear, month, day);
          }
        }
      }

      if (str.contains('-')) {
        final parts = str.split('-');
        if (parts.length >= 3) {
          final y = int.tryParse(parts[0].trim());
          final m = int.tryParse(parts[1].trim());
          final d = int.tryParse(parts[2].trim());
          if (y != null && m != null && d != null && y > 1000) {
            return DateTime(y, m, d);
          }
        }
        if (parts.length >= 2) {
          final p1 = int.tryParse(parts[0].trim());
          final p2 = int.tryParse(parts[1].trim());
          final yrRaw = parts.length >= 3 ? int.tryParse(parts[2].trim()) : null;
          if (p1 != null && p2 != null) {
            int day = p1;
            int month = p2;
            if (p1 <= 12 && p2 > 12) {
              month = p1;
              day = p2;
            }
            int targetYear;
            if (yrRaw != null) {
              targetYear = yrRaw < 100 ? 2000 + yrRaw : yrRaw;
            } else {
              targetYear = (month < now.month) ? now.year + 1 : now.year;
            }
            return DateTime(targetYear, month, day);
          }
        }
      }

      final months = {
        'jan': 1,
        'feb': 2,
        'mar': 3,
        'apr': 4,
        'may': 5,
        'jun': 6,
        'jul': 7,
        'aug': 8,
        'sep': 9,
        'oct': 10,
        'nov': 11,
        'dec': 12
      };
      final lower = str.toLowerCase();
      for (final entry in months.entries) {
        if (lower.contains(entry.key)) {
          final matches = RegExp(r'\d+')
              .allMatches(str)
              .map((m) => int.parse(m.group(0)!))
              .toList();
          if (matches.isNotEmpty) {
            final day = matches[0];
            final yrRaw = matches.length > 1 ? matches[1] : null;
            int targetYear;
            if (yrRaw != null) {
              targetYear = yrRaw < 100 ? 2000 + yrRaw : yrRaw;
            } else {
              targetYear = (entry.value < now.month) ? now.year + 1 : now.year;
            }
            return DateTime(targetYear, entry.value, day);
          }
        }
      }
    } catch (_) {}
    return null;
  }

  int _calculateRemainingCalendarDays(String validUntilStr) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = _parseValidUntilDate(validUntilStr);
    if (targetDate != null) {
      final targetDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
      final diff = targetDay.difference(today).inDays + 1;
      return diff > 0 ? diff : 1;
    }
    return 30;
  }

  int _calculateRemainingTravelDays(String validUntilStr, List<int> selectedDays) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final rawTarget = _parseValidUntilDate(validUntilStr) ??
        start.add(const Duration(days: 30));
    final targetDate = DateTime(rawTarget.year, rawTarget.month, rawTarget.day);

    int count = 0;
    DateTime current = start;
    while (!current.isAfter(targetDate)) {
      final dayIndex = current.weekday == 7 ? 0 : current.weekday;
      if (selectedDays.contains(dayIndex)) {
        count++;
      }
      current = current.add(const Duration(days: 1));
    }
    return count > 0 ? count : 1;
  }

  @override
  Widget build(BuildContext context) {
    final seatsCount = Get.isRegistered<UniversityController>()
        ? Get.find<UniversityController>().lastSearchRequest?.seats ?? 1
        : 1;

    final daysPerWeek = _selectedDays.length;
    final dailyRate = widget.trip.price * seatsCount;

    final remCalendarDays =
        _calculateRemainingCalendarDays(widget.trip.validUntil);

    final List<String> availableDurations = [];
    if (remCalendarDays >= 30) availableDurations.add('monthly');
    if (remCalendarDays >= 7) availableDurations.add('weekly');
    if (remCalendarDays < 30 && remCalendarDays > 0) {
      availableDurations.add('remaining');
    }
    if (availableDurations.isEmpty) availableDurations.add('remaining');

    final String activeDuration =
        availableDurations.contains(_selectedDuration)
            ? _selectedDuration
            : availableDurations.first;

    int totalActiveDays = daysPerWeek * 4;
    String durationTitle = 'one_month'.tr;
    if (activeDuration == 'weekly') {
      totalActiveDays = daysPerWeek * 1;
      durationTitle = 'one_week'.tr;
    } else if (activeDuration == 'remaining') {
      totalActiveDays =
          _calculateRemainingTravelDays(widget.trip.validUntil, _selectedDays);
      durationTitle = 'book_remaining_dates'.tr.isNotEmpty &&
              !'book_remaining_dates'.tr.contains('book_remaining_dates')
          ? 'book_remaining_dates'.tr
          : 'Book Remaining Dates';
    }

    final currentPrice = dailyRate * totalActiveDays;
    final periodDesc =
        '$durationTitle · $totalActiveDays ${'days_count'.tr} ($daysPerWeek ${'days_per_week'.tr})';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: GetBuilder<UniversityController>(
          builder: (uniController) {
            return Column(
              children: [
                const UniversityTopBar(showBackButton: true),
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
                        'universities'.tr,
                        style: textBold.copyWith(
                          fontSize: 24,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'choose_university_route_and_pickup'.tr,
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
                        const SizedBox(height: 16),

                        // Selected Route Card
                        UniversityPaymentSelectedRouteCard(
                          trip: widget.trip,
                          currentPickupPoint: widget.pickupPoint,
                        ),
                        const SizedBox(height: 20),

                        // Subscription Duration & Day Picker
                        UniversitySubscriptionDurationCard(
                          selectedDuration: activeDuration,
                          selectedDays: _selectedDays,
                          dailyUnitPrice: widget.trip.price,
                          seatsCount: seatsCount,
                          validUntil: widget.trip.validUntil,
                          onDurationChanged: (val) {
                            setState(() {
                              _selectedDuration = val;
                            });
                          },
                          onDaysChanged: (days) {
                            setState(() {
                              _selectedDays = days;
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        // Payment Method
                        UniversityPaymentMethodSelector(
                          selectedMethod: _selectedPaymentMethod,
                          onMethodChanged: (val) {
                            setState(() {
                              _selectedPaymentMethod = val;
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        // InstaPay Account Copy Details
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

                        // Upload Receipt (Only for InstaPay)
                        if (_selectedPaymentMethod == 'instapay') ...[
                          UniversityUploadReceiptCard(
                            receiptImage: _receiptImage,
                            onImageSelected: (image) {
                              setState(() {
                                _receiptImage = image;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Total Card
                        UniversityPaymentTotalCard(
                          totalPrice: currentPrice,
                          periodDescription: periodDesc,
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
                        color: Colors.black.withValues(alpha: 0.04),
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
                        onPressed: (uniController.isSubscribing || _isPaymobSubmitting)
                            ? null
                            : () => _handlePaymentSubmission(
                                  currentPrice: currentPrice,
                                  activeDuration: activeDuration,
                                  seatsCount: seatsCount,
                                  uniController: uniController,
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A0E9),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: (uniController.isSubscribing || _isPaymobSubmitting)
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

  Future<void> _handlePaymentSubmission({
    required double currentPrice,
    required String activeDuration,
    required int seatsCount,
    required UniversityController uniController,
  }) async {
    if (_selectedPaymentMethod == 'paymob') {
      setState(() {
        _isPaymobSubmitting = true;
      });

      try {
        // Step 1: Fetch Payment Intent from Backend API
        final PaymobSDKIntentModel? intent =
            await Get.find<RideController>().getPaymobIntent(
          tripRequestId: widget.trip.id,
          amount: currentPrice,
          selectedDuration: activeDuration,
        );

        if (intent == null ||
            (intent.clientSecret == null && intent.secretKey == null)) {
          if (!mounted) return;
          showCustomSnackBar('Failed to retrieve payment intent from backend.');
          return;
        }

        // Step 2: Launch Native Paymob SDK
        final result = await PaymobSdkService.startPayment(
          context: context,
          intent: intent,
        );

        // Step 3: Handle Paymob result
        bool isSuccess = false;
        String errorMsg = 'Payment was cancelled or failed.';

        if (result != null) {
          try {
            if (result.status == PaymentStatus.successful) {
              isSuccess = true;
            }
          } catch (_) {}

          if (!isSuccess) {
            try {
              final String statusStr =
                  result.status?.toString().toLowerCase() ?? '';
              if (statusStr.contains('success') ||
                  statusStr == 'true' ||
                  result.status == true) {
                isSuccess = true;
              }
            } catch (_) {}
          }

          if (!isSuccess && result is Map) {
            if (result['status'] == true ||
                result['success'] == true ||
                result['hmac_valid'] == true) {
              isSuccess = true;
            }
          }

          try {
            if (result.errorMessage != null &&
                result.errorMessage.toString().trim().isNotEmpty) {
              errorMsg = result.errorMessage.toString();
            } else if (result is Map && result['message'] != null) {
              errorMsg = result['message'].toString();
            }
          } catch (_) {}
        }

        if (isSuccess) {
          final pPoint = widget.pickupPoint.isNotEmpty
              ? widget.pickupPoint
              : (widget.trip.pickupPoint.isNotEmpty
                  ? widget.trip.pickupPoint
                  : widget.trip.fromArea);

          final request = UniversitySubscribeRequest(
            tripId: widget.trip.id,
            pickupPoint: pPoint,
            subscriptionDuration: activeDuration,
            paymentMethod: 'paymob',
            seats: seatsCount,
            amount: currentPrice,
            needReturnRide: widget.trip.hasReturnRide,
          );

          await uniController.submitSubscription(
            request: request,
            receiptImage: null,
          );

          if (!mounted) return;
          CarpoolPaymentSuccessBottomSheet.show(
            context: context,
            tripId: uniController.lastCreatedTripId ?? widget.trip.id,
            routeTitle: widget.trip.routeName,
            amount: currentPrice.toInt(),
            paymentMethod: 'VISA / MasterCard',
          );
        } else {
          if (!mounted) return;
          showCustomSnackBar(errorMsg);
        }
      } catch (e) {
        if (!mounted) return;
        showCustomSnackBar('Paymob error: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isPaymobSubmitting = false;
          });
        }
      }
      return;
    }

    // InstaPay Flow
    if (_receiptImage == null) {
      showCustomSnackBar('please_upload_payment_receipt'.tr);
      return;
    }

    final pPoint = widget.pickupPoint.isNotEmpty
        ? widget.pickupPoint
        : (widget.trip.pickupPoint.isNotEmpty
            ? widget.trip.pickupPoint
            : widget.trip.fromArea);

    final request = UniversitySubscribeRequest(
      tripId: widget.trip.id,
      pickupPoint: pPoint,
      subscriptionDuration: activeDuration,
      paymentMethod: _selectedPaymentMethod,
      seats: seatsCount,
      amount: currentPrice,
      needReturnRide: widget.trip.hasReturnRide,
    );

    final success = await uniController.submitSubscription(
      request: request,
      receiptImage: _receiptImage,
    );

    if (!mounted) return;

    if (success) {
      _showSuccessDialog(currentPrice);
    } else {
      showCustomSnackBar('Payment submission failed. Please try again.');
    }
  }

  void _showSuccessDialog(double currentPrice) {
    Get.dialog(
      PaymentSuccessDialog(
        title: 'subscription_activated'.tr,
        subtitle: 'subscription_success_message'.tr,
        routeName: widget.trip.routeName,
        pickupPoint: widget.pickupPoint,
        destination: widget.trip.toUniversity,
        amount: currentPrice,
        paymentMethod: _selectedPaymentMethod,
      ),
      barrierDismissible: false,
    );
  }
}


