import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_details_screen.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CarpoolPaymentSuccessBottomSheet extends StatelessWidget {
  final String tripId;
  final String routeTitle;
  final int amount;
  final String paymentMethod;

  const CarpoolPaymentSuccessBottomSheet({
    super.key,
    required this.tripId,
    required this.routeTitle,
    required this.amount,
    this.paymentMethod = 'VISA / MasterCard',
  });

  static void show({
    required BuildContext context,
    required String tripId,
    required String routeTitle,
    required int amount,
    String paymentMethod = 'VISA / MasterCard',
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CarpoolPaymentSuccessBottomSheet(
        tripId: tripId,
        routeTitle: routeTitle,
        amount: amount,
        paymentMethod: paymentMethod,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Animated Icon Circle
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF86EFAC), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF16A34A),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'payment_successful'.tr.isNotEmpty &&
                      !'payment_successful'.tr.contains('payment_successful')
                  ? 'payment_successful'.tr
                  : 'Payment Successful!',
              style: textBold.copyWith(
                fontSize: 22,
                color: const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'your_carpool_subscription_confirmed'.tr.isNotEmpty &&
                      !'your_carpool_subscription_confirmed'
                          .tr
                          .contains('your_carpool_subscription_confirmed')
                  ? 'your_carpool_subscription_confirmed'.tr
                  : 'Your carpool subscription has been confirmed successfully.',
              style: textRegular.copyWith(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  if (routeTitle.isNotEmpty) ...[
                    _buildRow(
                      label: 'Route'.tr,
                      value: routeTitle,
                      isBold: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: Color(0xFFE2E8F0), height: 1),
                    ),
                  ],
                  _buildRow(
                    label: 'Amount Paid'.tr,
                    value: '$amount ${'EGP'.tr}',
                    valueColor: const Color(0xFF08A9F0),
                    isBold: true,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: Color(0xFFE2E8F0), height: 1),
                  ),
                  _buildRow(
                    label: 'Duration'.tr,
                    value: '1 Month (30 Days)'.tr,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: Color(0xFFE2E8F0), height: 1),
                  ),
                  _buildRow(
                    label: 'Payment Method'.tr,
                    value: paymentMethod,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Primary Action Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Get.offAll(
                    () => TripDetailsScreen(
                      tripId: tripId,
                      fromCarpoolTab: true,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF08A9F0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'View Trip Details'.tr,
                  style: textBold.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Secondary Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () {
                  Get.offAll(() => const DashboardScreen());
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Back to Home'.tr,
                  style: textSemiBold.copyWith(
                    fontSize: 15,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textRegular.copyWith(
            fontSize: 13,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (isBold ? textBold : textMedium).copyWith(
              fontSize: 14,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}
