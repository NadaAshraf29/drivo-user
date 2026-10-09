import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class PaymentSuccessDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? routeName;
  final String? pickupPoint;
  final String? destination;
  final double? amount;
  final String? paymentMethod;
  final VoidCallback? onPrimaryPressed;

  const PaymentSuccessDialog({
    super.key,
    required this.title,
    required this.subtitle,
    this.routeName,
    this.pickupPoint,
    this.destination,
    this.amount,
    this.paymentMethod,
    this.onPrimaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon Badge
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFBAE6FD),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF00A0E9),
                  size: 42,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Title
            Text(
              title,
              style: textBold.copyWith(
                fontSize: 20,
                color: const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),

            // Subtitle
            Text(
              subtitle,
              style: textRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Summary Card (if details available)
            if (routeName != null || amount != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    if (routeName != null && routeName!.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'route_name'.tr.isNotEmpty && 'route_name'.tr != 'route_name'
                                ? 'route_name'.tr
                                : 'Route',
                            style: textRegular.copyWith(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              routeName!,
                              style: textBold.copyWith(
                                fontSize: 12,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    if (pickupPoint != null && destination != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'trip_route'.tr.isNotEmpty && 'trip_route'.tr != 'trip_route'
                                ? 'trip_route'.tr
                                : 'Trip',
                            style: textRegular.copyWith(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              '$pickupPoint ➔ $destination',
                              style: textSemiBold.copyWith(
                                fontSize: 11,
                                color: const Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    if (amount != null && amount! > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'total_amount'.tr.isNotEmpty && 'total_amount'.tr != 'total_amount'
                                ? 'total_amount'.tr
                                : 'Amount Paid',
                            style: textRegular.copyWith(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            '${amount!.toStringAsFixed(0)} EGP',
                            style: textBold.copyWith(
                              fontSize: 14,
                              color: const Color(0xFF00A0E9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Home / OK Action Button
            InkWell(
              onTap: () {
                if (onPrimaryPressed != null) {
                  onPrimaryPressed!();
                } else {
                  Get.offAll(() => const DashboardScreen());
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF00A0E9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00A0E9).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'home'.tr,
                    style: textBold.copyWith(
                      color: Colors.white,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
