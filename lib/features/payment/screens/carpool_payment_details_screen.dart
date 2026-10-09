import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_paymob_sdk/flutter_paymob_sdk.dart';
import 'package:ride_sharing_user_app/features/payment/domain/services/paymob_service.dart';
import 'package:ride_sharing_user_app/features/payment/widget/carpool_payment_widgets/carpool_payment_action_footer_widget.dart';
import 'package:ride_sharing_user_app/features/payment/widget/carpool_payment_widgets/carpool_payment_app_bar_widget.dart';
import 'package:ride_sharing_user_app/features/payment/widget/carpool_payment_widgets/carpool_payment_approval_notice_widget.dart';
import 'package:ride_sharing_user_app/features/payment/widget/carpool_payment_widgets/carpool_payment_duration_selector_widget.dart';
import 'package:ride_sharing_user_app/features/payment/widget/carpool_payment_widgets/carpool_payment_instapay_account_card_widget.dart';
import 'package:ride_sharing_user_app/features/payment/widget/carpool_payment_widgets/carpool_payment_method_selector_widget.dart';
import 'package:ride_sharing_user_app/features/payment/widget/carpool_payment_widgets/carpool_payment_summary_card_widget.dart';
import 'package:ride_sharing_user_app/features/payment/widget/carpool_payment_widgets/carpool_payment_success_bottom_sheet.dart';
import 'package:ride_sharing_user_app/features/payment/widget/carpool_payment_widgets/carpool_payment_upload_card_widget.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';

class CarpoolPaymentDetailsScreen extends StatefulWidget {
  final String tripId;
  final int totalPrice;
  final List<Map<String, dynamic>> paymentAccounts;
  final Map<String, dynamic>? proration;
  final String routeTitle;
  final String dateTimeText;
  final String returnTimeText;
  final String pickupLocation;
  final String dropoffLocation;
  final String? carpoolType;

  const CarpoolPaymentDetailsScreen({
    super.key,
    required this.tripId,
    required this.totalPrice,
    required this.paymentAccounts,
    this.proration,
    this.routeTitle = '',
    this.dateTimeText = '',
    this.returnTimeText = '',
    this.pickupLocation = '',
    this.dropoffLocation = '',
    this.carpoolType,
  });

  @override
  State<CarpoolPaymentDetailsScreen> createState() =>
      _CarpoolPaymentDetailsScreenState();
}

class _CarpoolPaymentDetailsScreenState
    extends State<CarpoolPaymentDetailsScreen> {
  File? _screenshot;
  bool _isSubmitting = false;
  bool _isPaymentSubmitted = false;
  String _selectedMethod = 'instapay';
  String _selectedDuration = 'monthly';

  bool get _hasDurationOptions {
    final type = (widget.carpoolType ?? '').toLowerCase().trim();
    if (type == 'travel' ||
        type == 'north_coast' ||
        type == 'sahel' ||
        type == 'trip' ||
        type == 'one_way' ||
        type == 'single') {
      return false;
    }
    final title = widget.routeTitle.toLowerCase();
    if (title.contains('travel') ||
        title.contains('north coast') ||
        title.contains('north_coast') ||
        title.contains('sahel') ||
        title.contains('الساحل') ||
        title.contains('سفر')) {
      return false;
    }
    return true;
  }

  void _cancelUnpaidBooking() {
    if (!_isPaymentSubmitted && widget.tripId.isNotEmpty) {
      try {
        Get.find<RideController>().tripStatusUpdate(
          widget.tripId,
          'cancelled',
          '',
          'User cancelled payment',
        );
      } catch (e) {
        debugPrint('Error cancelling unpaid carpool request: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          _screenshot = File(image.path);
        });
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'Failed to pick screenshot: $e',
        backgroundColor: Colors.black,
        colorText: Colors.white,
      );
    }
  }

  void _removeImage() {
    setState(() {
      _screenshot = null;
    });
  }

  void _copyToClipboard(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    Get.snackbar(
      'copied'.tr.isNotEmpty ? 'copied'.tr : 'Copied!',
      '$label copied to clipboard',
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
      icon: const Icon(Icons.copy, color: Colors.white, size: 20),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _submitPayment(int effectivePrice) async {
    if (_selectedMethod == 'paymob') {
      setState(() {
        _isSubmitting = true;
      });
      try {
        // Step 1: Fetch Payment Intent from Backend API
        final PaymobSDKIntentModel? intent =
            await Get.find<RideController>().getPaymobIntent(
          tripRequestId: widget.tripId,
          amount: effectivePrice.toDouble(),
          selectedDuration: _selectedDuration,
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
          _isPaymentSubmitted = true;
          if (!mounted) return;
          CarpoolPaymentSuccessBottomSheet.show(
            context: context,
            tripId: widget.tripId,
            routeTitle: widget.routeTitle,
            amount: effectivePrice,
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
            _isSubmitting = false;
          });
        }
      }
      return;
    }

    // InstaPay / Manual receipt upload flow
    if (_screenshot == null) {
      Get.snackbar(
        'please_upload_payment_receipt'.tr,
        'please_upload_payment_receipt'.tr,
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.amber),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final bool success = await Get.find<RideController>().submitCarpoolPayment(
      tripRequestId: widget.tripId,
      screenshotPath: _screenshot!.path,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      _isPaymentSubmitted = true;
      CarpoolPaymentSuccessBottomSheet.show(
        context: context,
        tripId: widget.tripId,
        routeTitle: widget.routeTitle,
        amount: effectivePrice,
        paymentMethod: 'InstaPay',
      );
    } else {
      showCustomSnackBar('Failed to submit payment receipt. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showDurationSelector = _hasDurationOptions;
    final int dailyPrice = widget.totalPrice; // Price for 1 day
    final int monthlyPrice = dailyPrice;

    const String activeDuration = 'monthly';

    int effectivePrice = dailyPrice;
    if (showDurationSelector) {
      effectivePrice = monthlyPrice;
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!_isPaymentSubmitted) {
          _cancelUnpaidBooking();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: CarpoolPaymentAppBarWidget(
          onBackPressed: () {
            _cancelUnpaidBooking();
            Navigator.of(context).pop();
          },
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Card
                CarpoolPaymentSummaryCardWidget(
                  totalPrice: effectivePrice,
                  proration: widget.proration,
                  routeTitle: widget.routeTitle,
                  dateTimeText: widget.dateTimeText,
                  returnTimeText: widget.returnTimeText,
                  pickupLocation: widget.pickupLocation,
                  dropoffLocation: widget.dropoffLocation,
                  selectedDuration: activeDuration,
                  showDuration: showDurationSelector,
                ),
                const SizedBox(height: 20),

                // Duration Selector (Monthly only for routine trip)
                if (showDurationSelector) ...[
                  CarpoolPaymentDurationSelectorWidget(
                    selectedDuration: activeDuration,
                    monthlyPrice: monthlyPrice,
                    onDurationChanged: (duration) {
                      setState(() {
                        _selectedDuration = duration;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                // Payment Method Selector
                CarpoolPaymentMethodSelectorWidget(
                  selectedMethod: _selectedMethod,
                  onMethodSelected: (method) {
                    setState(() {
                      _selectedMethod = method;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // InstaPay Account Copy Details (if InstaPay selected)
                if (_selectedMethod == 'instapay' &&
                    widget.paymentAccounts.isNotEmpty) ...[
                  CarpoolPaymentInstapayAccountCardWidget(
                    paymentAccounts: widget.paymentAccounts,
                    onCopy: _copyToClipboard,
                  ),
                  const SizedBox(height: 16),
                ],

                // Approval Notice Card
                const CarpoolPaymentApprovalNoticeWidget(),
                const SizedBox(height: 20),

                // Upload Payment Screenshot Box (Only for InstaPay / manual receipts)
                if (_selectedMethod == 'instapay') ...[
                  CarpoolPaymentUploadCardWidget(
                    screenshot: _screenshot,
                    onPick: _pickImage,
                    onRemove: _removeImage,
                  ),
                  const SizedBox(height: 24),
                ],

                // Amount to pay & Action Button Footer
                CarpoolPaymentActionFooterWidget(
                  totalPrice: effectivePrice,
                  selectedMethod: _selectedMethod,
                  onPressed: () => _submitPayment(effectivePrice),
                  isSubmitting: _isSubmitting,
                  isReady: _selectedMethod == 'paymob' || _screenshot != null,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
