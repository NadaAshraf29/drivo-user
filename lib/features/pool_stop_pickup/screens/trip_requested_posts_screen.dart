import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/one_trip_widgets/one_trip_route_summary_card.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TripRequestedPostsScreen extends StatelessWidget {
  final String pickupAddress;
  final String destinationAddress;
  final String dateText;
  final String timeText;
  final int seatsCount;
  final double estimatedFare;

  const TripRequestedPostsScreen({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.dateText,
    required this.timeText,
    required this.seatsCount,
    required this.estimatedFare,
  });

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
              // Top Bar with Dismiss and Live Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Get.offAll(() => const DashboardScreen()),
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFBAE6FD),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00A0E9),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'active_request'.tr.isNotEmpty &&
                                  'active_request'.tr != 'active_request'
                              ? 'active_request'.tr
                              : 'ACTIVE REQUEST',
                          style: textBold.copyWith(
                            fontSize: 10,
                            letterSpacing: 0.5,
                            color: const Color(0xFF0284C7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Hero Radar / Pending Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0F2FE), Color(0xFFF0F9FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFBAE6FD),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00A0E9).withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00A0E9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.travel_explore_rounded,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'trip_requested_posts'.tr.isNotEmpty &&
                              'trip_requested_posts'.tr !=
                                  'trip_requested_posts'
                          ? 'trip_requested_posts'.tr
                          : 'Trip Request Posted!',
                      style: textBold.copyWith(
                        fontSize: 20,
                        color: const Color(0xFF0F172A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'we_are_finding_someone_for_your_trip'.tr.isNotEmpty &&
                              'we_are_finding_someone_for_your_trip'.tr !=
                                  'we_are_finding_someone_for_your_trip'
                          ? 'we_are_finding_someone_for_your_trip'.tr
                          : 'We are notifying matching drivers on your route.',
                      style: textMedium.copyWith(
                        fontSize: 13,
                        color: const Color(0xFF334155),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'your_trip_is_pending_driver_accept'.tr.isNotEmpty &&
                              'your_trip_is_pending_driver_accept'.tr !=
                                  'your_trip_is_pending_driver_accept'
                          ? 'your_trip_is_pending_driver_accept'.tr
                          : 'You will receive an instant notification as soon as a driver confirms.',
                      style: textRegular.copyWith(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: const LinearProgressIndicator(
                        backgroundColor: Color(0xFFBAE6FD),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF00A0E9)),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Route Summary Card
              OneTripRouteSummaryCard(
                pickupAddress: pickupAddress,
                destinationAddress: destinationAddress,
                dateText: dateText,
                timeText: timeText,
                seatsCount: seatsCount,
              ),
              const SizedBox(height: 14),

              // Live Request Progress Steps Card
              Container(
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
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'request_status_timeline'.tr.isNotEmpty &&
                              'request_status_timeline'.tr !=
                                  'request_status_timeline'
                          ? 'request_status_timeline'.tr
                          : 'Request Status Timeline',
                      style: textBold.copyWith(
                        fontSize: 14,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildStepRow(
                      icon: Icons.check_circle_rounded,
                      iconColor: const Color(0xFF00A0E9),
                      title: 'trip_request_created'.tr.isNotEmpty &&
                              'trip_request_created'.tr !=
                                  'trip_request_created'
                          ? 'trip_request_created'.tr
                          : 'Trip Request Created',
                      subtitle:
                          'details_broadcasted_to_drivers'.tr.isNotEmpty &&
                                  'details_broadcasted_to_drivers'.tr !=
                                      'details_broadcasted_to_drivers'
                              ? 'details_broadcasted_to_drivers'.tr
                              : 'Details broadcasted to available drivers',
                      isCompleted: true,
                      hasLine: true,
                    ),
                    _buildStepRow(
                      icon: Icons.radar_rounded,
                      iconColor: const Color(0xFF00A0E9),
                      title: 'matching_drivers'.tr.isNotEmpty &&
                              'matching_drivers'.tr != 'matching_drivers'
                          ? 'matching_drivers'.tr
                          : 'Matching Drivers',
                      subtitle: 'active_search_along_route'.tr.isNotEmpty &&
                              'active_search_along_route'.tr !=
                                  'active_search_along_route'
                          ? 'active_search_along_route'.tr
                          : 'Active search along your route and timing',
                      isCompleted: false,
                      isActive: true,
                      hasLine: true,
                    ),
                    _buildStepRow(
                      icon: Icons.radio_button_unchecked_rounded,
                      iconColor: const Color(0xFF94A3B8),
                      title: 'driver_confirmation'.tr.isNotEmpty &&
                              'driver_confirmation'.tr != 'driver_confirmation'
                          ? 'driver_confirmation'.tr
                          : 'Driver Confirmation',
                      subtitle: 'driver_details_unlock'.tr.isNotEmpty &&
                              'driver_details_unlock'.tr !=
                                  'driver_details_unlock'
                          ? 'driver_details_unlock'.tr
                          : 'Driver details and live pickup tracking unlock',
                      isCompleted: false,
                      hasLine: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Fare Display Card
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
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
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0F2FE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Color(0xFF00A0E9),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'estimated_fare'.tr,
                            style: textMedium.copyWith(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            'pay_securely_when_confirmed'.tr.isNotEmpty &&
                                    'pay_securely_when_confirmed'.tr !=
                                        'pay_securely_when_confirmed'
                                ? 'pay_securely_when_confirmed'.tr
                                : 'Pay securely when trip confirmed',
                            style: textRegular.copyWith(
                              fontSize: 10,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${estimatedFare.toStringAsFixed(0)} ${'egp'.tr.isNotEmpty && 'egp'.tr != 'egp' ? 'egp'.tr : 'EGP'}',
                      style: textBold.copyWith(
                        fontSize: 20,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // // Primary Action: View My Trips
              // SizedBox(
              //   width: double.infinity,
              //   height: 52,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       if (Get.isRegistered<BottomMenuController>()) {
              //         Get.find<BottomMenuController>().setTabIndex(1);
              //       }
              //       Get.offAll(() => const DashboardScreen(initialTabIndex: 1));
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: const Color(0xFF00A0E9),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(26),
              //       ),
              //       elevation: 0,
              //       shadowColor: Colors.transparent,
              //     ),
              //     child: Text(
              //       'view_my_trips'.tr.isNotEmpty &&
              //               'view_my_trips'.tr != 'view_my_trips'
              //           ? 'view_my_trips'.tr
              //           : 'View My Trips',
              //       style: textBold.copyWith(
              //         color: Colors.white,
              //         fontSize: Dimensions.fontSizeLarge,
              //       ),
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 10),

              // Secondary Action: Return to Dashboard
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () {
                    Get.offAll(() => const DashboardScreen());
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF06AAF2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'back_to_home'.tr.isNotEmpty &&
                            'back_to_home'.tr != 'back_to_home'
                        ? 'back_to_home'.tr
                        : 'Back to Home',
                    style: textSemiBold.copyWith(
                      color: const Color(0xFFFFFFFF),
                      fontSize: Dimensions.fontSizeDefault,
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

  Widget _buildStepRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isCompleted,
    bool isActive = false,
    required bool hasLine,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, color: iconColor, size: 20),
            if (hasLine)
              Container(
                width: 2,
                height: 28,
                color: isCompleted
                    ? const Color(0xFF00A0E9)
                    : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textBold.copyWith(
                  fontSize: 13,
                  color: isActive
                      ? const Color(0xFF00A0E9)
                      : (isCompleted
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF64748B)),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: textRegular.copyWith(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              if (hasLine) const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
// ponytail: extracted widget class — follow single class per file rule
