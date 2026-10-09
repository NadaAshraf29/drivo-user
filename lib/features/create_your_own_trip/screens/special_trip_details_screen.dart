import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/controller/create_your_own_trip_controller.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/domain/models/special_trip_model.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/widgets/special_trip_map_widget.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/message/controllers/message_controller.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/widget/one_trip_widgets/one_trip_driver_info_card.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class SpecialTripDetailsScreen extends StatefulWidget {
  final SpecialTripRequestModel trip;

  const SpecialTripDetailsScreen({super.key, required this.trip});

  @override
  State<SpecialTripDetailsScreen> createState() =>
      _SpecialTripDetailsScreenState();
}

class _SpecialTripDetailsScreenState extends State<SpecialTripDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<CreateYourOwnTripController>()) {
        final controller = Get.find<CreateYourOwnTripController>();
        controller.setTrip(widget.trip);
        if (widget.trip.id.isNotEmpty) {
          controller.fetchTripDetails(widget.trip.id);
        }
      }
    });
  }

  void _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _formatWeekdays(Iterable<int> days) {
    final map = {
      7: 'Sun',
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
    };
    final sorted = days.toSet().toList()..sort();
    return sorted
        .map((d) => map[d] ?? '')
        .where((s) => s.isNotEmpty)
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd MMM yyyy');

    return GetBuilder<CreateYourOwnTripController>(
      builder: (controller) {
        final trip = controller.currentTrip ?? widget.trip;
        final status = trip.status;
        final bool isConfirmed = status == SpecialTripStatus.confirmed ||
            status == SpecialTripStatus.paid ||
            trip.paymentStatus.toLowerCase() == 'paid';
        final bool isCancelled = status == SpecialTripStatus.cancelled ||
            trip.rawStatus?.toLowerCase() == 'cancelled' ||
            trip.rawStatus?.toLowerCase() == 'canceled';
        final bool isDriverAssigned = trip.driver != null ||
            status == SpecialTripStatus.accepted ||
            trip.rawStatus?.toLowerCase() == 'driver_assigned' ||
            trip.rawStatus?.toLowerCase() == 'accepted' ||
            trip.rawStatus?.toLowerCase() == 'accepted_pending_payment';
        final bool isWaitingPayment = !isConfirmed &&
            !isCancelled &&
            isDriverAssigned &&
            (status == SpecialTripStatus.waitingForPayment ||
                status == SpecialTripStatus.accepted ||
                trip.paymentStatus.toLowerCase() != 'paid');

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF0F172A), size: 18),
              onPressed: () => Get.back(),
            ),
            title: Column(
              children: [
                Text(
                  'trip_request_details'.tr,
                  style: textBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  trip.refId != null && trip.refId!.isNotEmpty
                      ? trip.refId!
                      : trip.id,
                  style: textRegular.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              // Status chip in AppBar
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Center(
                    // child: Container(
                    //   padding:
                    //       const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    //   decoration: BoxDecoration(
                    //     color: status.statusColor.withValues(alpha: 0.12),
                    //     borderRadius: BorderRadius.circular(12),
                    //     border: Border.all(
                    //       color: status.statusColor.withValues(alpha: 0.3),
                    //     ),
                    //   ),
                    //   child: Text(
                    //     status.readableName,
                    //     style: textBold.copyWith(
                    //       fontSize: 10,
                    //       color: status.statusColor,
                    //     ),
                    //   ),
                    // ),
                    ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Map Preview with All Markers
                SpecialTripMapWidget(
                  pickupPoints: trip.pickupPoints,
                  destinationPoints: trip.destinationPoints,
                  driver: trip.driver,
                  height: 240,
                  isInteractive: true,
                ),
                const SizedBox(height: 16),

                // 30-Minute Payment Countdown Banner (When Driver Accepted / Waiting for Payment)
                if (isWaitingPayment) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFEDD5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFFEA580C).withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEA580C),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.timer_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'driver_accepted_title'.tr,
                                    style: textBold.copyWith(
                                      fontSize: 14,
                                      color: const Color(0xFF9A3412),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'complete_payment_within_30_min'.tr,
                                    style: textRegular.copyWith(
                                      fontSize: 11,
                                      color: const Color(0xFFC2410C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEA580C),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                controller.formattedCountdown,
                                style: textBold.copyWith(
                                  fontSize: 16,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Pay Now Button (Using Paymob Integration)
                        controller.isProcessingPayment
                            ? Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  ),
                                ),
                              )
                            : ButtonWidget(
                                buttonText: 'pay_now_via_paymob'.tr,
                                radius: 12,
                                onPressed: () => controller.initiatePayment(
                                    context: context),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Pending Driver State Banner
                if (status == SpecialTripStatus.pending) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFDE68A),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFFD97706).withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFFD97706),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'searching_for_drivers'.tr,
                                    style: textBold.copyWith(
                                      fontSize: 14,
                                      color: const Color(0xFF92400E),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'request_distributed_to_drivers'.tr,
                                    style: textRegular.copyWith(
                                      fontSize: 11,
                                      color: const Color(0xFFB45309),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ButtonWidget(
                          buttonText: 'go_to_home'.tr.isNotEmpty &&
                                  'go_to_home'.tr != 'go_to_home'
                              ? 'go_to_home'.tr
                              : 'back_to_home'.tr.isNotEmpty &&
                                      'back_to_home'.tr != 'back_to_home'
                                  ? 'back_to_home'.tr
                                  : 'Go to Home',
                          radius: 12,
                          icon: Icons.home_rounded,
                          onPressed: () {
                            if (Get.isRegistered<BottomMenuController>()) {
                              Get.find<BottomMenuController>().resetNavBar();
                            }
                            Get.offAll(() => const DashboardScreen());
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Confirmed State Banner
                if (isConfirmed) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFBBF7D0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: Color(0xFF16A34A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'payment_successful_trip_confirmed'.tr,
                                style: textBold.copyWith(
                                  fontSize: 14,
                                  color: const Color(0xFF166534),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'trip_ready_to_start'.tr,
                                style: textRegular.copyWith(
                                  fontSize: 11,
                                  color: const Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Driver Info Card (when driver is assigned)
                if (trip.driver != null) ...[
                  OneTripDriverInfoCard(
                    driverName: trip.driver!.name,
                    vehicleInfo: trip.driver!.vehicleName,
                    ratingText: trip.driver!.rating.toString(),
                    licensePlate: trip.driver!.licensePlate,
                    onCallTap: () => _callPhone(trip.driver!.phone),
                    onMessageTap: () {
                      final driverId = trip.driver?.id;
                      if (driverId != null &&
                          driverId.isNotEmpty &&
                          driverId != '0') {
                        if (Get.isRegistered<MessageController>()) {
                          Get.find<MessageController>()
                              .createChannel(driverId, trip.id);
                        } else {
                          Get.put(MessageController(
                                  messageServiceInterface: Get.find()))
                              .createChannel(driverId, trip.id);
                        }
                      } else {
                        showCustomSnackBar(
                            'driver_not_assigned_yet'.tr.isNotEmpty
                                ? 'driver_not_assigned_yet'.tr
                                : 'Driver not assigned yet');
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Start Trip Code (OTP) Card
                Builder(builder: (context) {
                  final rideCtrl = Get.isRegistered<RideController>()
                      ? Get.find<RideController>()
                      : null;
                  final String? effectiveOtp = (trip.otp != null &&
                          trip.otp!.trim().isNotEmpty)
                      ? trip.otp!.trim()
                      : (rideCtrl?.tripDetails?.otp != null &&
                              rideCtrl!.tripDetails!.otp!.trim().isNotEmpty)
                          ? rideCtrl.tripDetails!.otp!.trim()
                          : null;
                  final bool isCancelledOrExpired =
                      trip.status == SpecialTripStatus.cancelled ||
                          trip.status == SpecialTripStatus.expired;
                  final bool showOtpCard = !isCancelledOrExpired &&
                      ((effectiveOtp != null && effectiveOtp.isNotEmpty) ||
                          isConfirmed ||
                          trip.status == SpecialTripStatus.accepted ||
                          trip.driver != null);
                  if (!showOtpCard) return const SizedBox.shrink();
                  return Column(
                    children: [
                      _buildOtpCard(context, effectiveOtp),
                      const SizedBox(height: 16),
                    ],
                  );
                }),

                // Passenger Roster & Payment Statuses
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'passengers_and_payment_status'.tr,
                            style: textBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(
                          //       horizontal: 8, vertical: 3),
                          //   decoration: BoxDecoration(
                          //     color: const Color(0xFFF1F5F9),
                          //     borderRadius: BorderRadius.circular(10),
                          //   ),
                          //   // child: Text(
                          //   //   trip.paymentResponsibility ==
                          //   //           PaymentResponsibility.creatorPays
                          //   //       ? 'creator_pays'.tr
                          //   //       : 'each_passenger_pays'.tr,
                          //   //   style: textBold.copyWith(
                          //   //     fontSize: 10,
                          //   //     color: const Color(0xFF475569),
                          //   //   ),
                          //   // ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...trip.passengers.asMap().entries.map((entry) {
                        final p = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: p.isCurrentUser
                                    ? const Color(0xFFE0F2FE)
                                    : const Color(0xFFF1F5F9),
                                child: Icon(
                                  p.isCurrentUser
                                      ? Icons.person_rounded
                                      : Icons.person_outline_rounded,
                                  color: p.isCurrentUser
                                      ? const Color(0xFF00A0E9)
                                      : const Color(0xFF64748B),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: textSemiBold.copyWith(
                                        fontSize: 12,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      p.phone,
                                      style: textRegular.copyWith(
                                        fontSize: 10,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: p.paymentStatus.statusColor
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  p.paymentStatus.readableName,
                                  style: textBold.copyWith(
                                    fontSize: 10,
                                    color: p.paymentStatus.statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Trip Parameters Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
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
                      Text(
                        'trip_details'.tr,
                        style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                          label: 'start_date'.tr,
                          value: dateFormat.format(trip.startDate)),
                      _InfoRow(
                          label: 'end_date'.tr,
                          value: dateFormat.format(trip.endDate)),
                      _InfoRow(
                          label: 'operating_days'.tr,
                          value: () {
                            final days = trip.activeWeekdays.isNotEmpty
                                ? trip.activeWeekdays
                                : trip.operatingWeekdays;
                            final text = _formatWeekdays(days);
                            return text.isNotEmpty ? text : '-';
                          }()),
                      _InfoRow(
                          label: 'total_trip_days'.tr,
                          value: '${trip.totalTripDays} ${'days'.tr}'),
                      _InfoRow(
                          label: 'outbound_time'.tr,
                          value: trip.outboundTime.format(context)),
                      _InfoRow(
                        label: 'return_ride'.tr,
                        value: trip.hasReturnRide
                            ? (trip.returnTime != null
                                ? '${'yes'.tr} (${trip.returnTime!.format(context)})'
                                : 'yes'.tr)
                            : 'no'.tr,
                      ),
                      _InfoRow(
                          label: 'seats'.tr,
                          value:
                              '${trip.seatsCount > 0 ? trip.seatsCount : 1}'),
                      // if (trip.activeDates.isNotEmpty) ...[
                      //   const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      //   Row(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Padding(
                      //         padding: const EdgeInsets.only(top: 2),
                      //         child: Text(
                      //           'active_dates'.tr,
                      //           style: textRegular.copyWith(
                      //             fontSize: 12,
                      //             color: const Color(0xFF64748B),
                      //           ),
                      //         ),
                      //       ),
                      //       const SizedBox(width: 12),
                      //       Expanded(
                      //         child: Wrap(
                      //           alignment: WrapAlignment.end,
                      //           spacing: 6,
                      //           runSpacing: 6,
                      //           children: trip.activeDates.map((dateStr) {
                      //             final dt = DateTime.tryParse(dateStr.trim());
                      //             final label = dt != null
                      //                 ? DateFormat('EEE, dd MMM').format(dt)
                      //                 : dateStr;
                      //             return Container(
                      //               padding: const EdgeInsets.symmetric(
                      //                   horizontal: 8, vertical: 4),
                      //               decoration: BoxDecoration(
                      //                 color: const Color(0xFFEEF2FF),
                      //                 borderRadius: BorderRadius.circular(8),
                      //                 border: Border.all(
                      //                   color: const Color(0xFFC7D2FE),
                      //                   width: 0.8,
                      //                 ),
                      //               ),
                      //               child: Text(
                      //                 label,
                      //                 style: textSemiBold.copyWith(
                      //                   fontSize: 11,
                      //                   color: const Color(0xFF3730A3),
                      //                 ),
                      //               ),
                      //             );
                      //           }).toList(),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ],
                      if (trip.fare != null) ...[
                        const Divider(height: 16, color: Color(0xFFF1F5F9)),
                        _InfoRow(
                          label: 'total_fare'.tr,
                          value:
                              '${trip.fare!.totalFare.toStringAsFixed(2)} ${trip.fare!.currency}',
                          isHighlight: true,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOtpCard(BuildContext context, String? otp) {
    final String cleanOtp = (otp != null && otp.trim().isNotEmpty)
        ? otp.trim().replaceAll(' ', '')
        : '';
    final List<String> digits =
        cleanOtp.isNotEmpty ? cleanOtp.split('') : ['-', '-', '-', '-'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFF2E7D32),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'start_trip_code'.tr == 'start_trip_code'
                          ? 'Start Trip Code (OTP)'
                          : 'start_trip_code'.tr,
                      style: textBold.copyWith(
                        color: const Color(0xFF0F172A),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'give_otp_to_driver'.tr == 'give_otp_to_driver'
                          ? 'Share this code with your driver when they arrive.'
                          : 'give_otp_to_driver'.tr,
                      style: textRegular.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < digits.length; i++) ...[
                Container(
                  width: 48,
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    digits[i],
                    style: textBold.copyWith(
                      fontSize: 22,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                if (i < digits.length - 1) const SizedBox(width: 10),
              ],
              if (cleanOtp.isNotEmpty) ...[
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: cleanOtp));
                    showCustomSnackBar('copied'.tr, isError: false);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.copy_rounded,
                      color: Color(0xFF00A0E9),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _InfoRow(
      {required this.label, required this.value, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textRegular.copyWith(
              fontSize: 12,
              color: isHighlight
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF64748B),
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: textBold.copyWith(
                fontSize: 12,
                color: isHighlight
                    ? const Color(0xFF00A0E9)
                    : const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
