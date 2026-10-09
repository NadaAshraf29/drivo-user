import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/controller/create_your_own_trip_controller.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/domain/models/special_trip_fare_model.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/screens/special_trip_details_screen.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/widgets/special_trip_map_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SpecialTripFareConfirmationScreen extends StatelessWidget {
  const SpecialTripFareConfirmationScreen({super.key});

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

  String _formatOperatingDays(
      CreateYourOwnTripController controller, SpecialTripFareModel? fare) {
    if (fare != null && fare.activeDates.isNotEmpty) {
      final activeDays = fare.activeWeekdays;
      if (activeDays.isNotEmpty) {
        return _formatWeekdays(activeDays);
      }
    }
    return _formatWeekdays(controller.selectedWeekdays);
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd MMM yyyy');

    return GetBuilder<CreateYourOwnTripController>(
      builder: (controller) {
        final fare = controller.fareModel;
        final int daysCount = (fare != null && fare.activeDates.isNotEmpty)
            ? fare.activeDates.length
            : (fare?.totalActiveDays ??
                controller.calculateOperatingDaysCount());

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
            title: Text(
              'fare_and_trip_summary'.tr,
              style: textBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: const Color(0xFF0F172A),
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Map Preview
                SpecialTripMapWidget(
                  pickupPoints: controller.pickupPoints,
                  destinationPoints: controller.destinationPoints,
                  height: 180,
                  isInteractive: false,
                ),
                const SizedBox(height: 16),

                // Fare Total Highlight Card
                if (fare != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00A0E9), Color(0xFF0284C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF00A0E9).withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
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
                              'total_estimated_fare'.tr,
                              style: textMedium.copyWith(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$daysCount ${'trip_days'.tr}',
                                style: textBold.copyWith(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${fare.totalFare.toStringAsFixed(2)} ${fare.currency}',
                          style: textBold.copyWith(
                            fontSize: 26,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (controller.paymentResponsibility ==
                            PaymentResponsibility.eachPassengerPays)
                          Text(
                            '${'per_passenger_fare'.tr}: ${fare.passengerAmount.toStringAsFixed(2)} ${fare.currency}',
                            style: textMedium.copyWith(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          )
                        else
                          Text(
                            'creator_pays_full_fare_note'.tr,
                            style: textRegular.copyWith(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Pickup & Destination Summary Card
                _SummaryCard(
                  title: 'route_and_stops'.tr,
                  icon: Icons.alt_route_rounded,
                  iconColor: const Color(0xFF00A0E9),
                  iconBg: const Color(0xFFE0F2FE),
                  children: [
                    Text(
                      'pickup_points'.tr,
                      style: textSemiBold.copyWith(
                          fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    ...controller.pickupPoints
                        .where((p) => p.isValid)
                        .map((p) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F2FE),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text('P${p.order}',
                                        style: textBold.copyWith(
                                            fontSize: 10,
                                            color: const Color(0xFF00A0E9))),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      p.address,
                                      style: textMedium.copyWith(
                                          fontSize: 12,
                                          color: const Color(0xFF0F172A)),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                    const SizedBox(height: 10),
                    Text(
                      'destination_points'.tr,
                      style: textSemiBold.copyWith(
                          fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    ...controller.destinationPoints
                        .where((d) => d.isValid)
                        .map((d) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text('D${d.order}',
                                        style: textBold.copyWith(
                                            fontSize: 10,
                                            color: const Color(0xFFDC2626))),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      d.address,
                                      style: textMedium.copyWith(
                                          fontSize: 12,
                                          color: const Color(0xFF0F172A)),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                    if (fare?.distanceKm != null && fare!.distanceKm! > 0) ...[
                      const SizedBox(height: 10),
                      _DetailRow(
                        label: 'total_distance'.tr,
                        value: '${fare.distanceKm} km',
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),

                // Schedule Details Card
                _SummaryCard(
                  title: 'schedule_and_timing'.tr,
                  icon: Icons.calendar_month_rounded,
                  iconColor: const Color(0xFF4F46E5),
                  iconBg: const Color(0xFFEEF2FF),
                  children: [
                    _DetailRow(
                      label: 'start_date'.tr,
                      value: dateFormat.format(controller.startDate),
                    ),
                    _DetailRow(
                      label: 'end_date'.tr,
                      value: dateFormat.format(controller.endDate),
                    ),
                    _DetailRow(
                      label: 'operating_days'.tr,
                      value: _formatOperatingDays(controller, fare),
                    ),
                    _DetailRow(
                      label: 'total_operating_days'.tr,
                      value: '$daysCount ${'days'.tr}',
                    ),
                    _DetailRow(
                      label: 'outbound_time'.tr,
                      value: controller.startTime.format(context),
                    ),
                    _DetailRow(
                      label: 'return_ride'.tr,
                      value: controller.hasReturnRide
                          ? '${'yes'.tr} (${controller.returnTime?.format(context) ?? ''})'
                          : 'no'.tr,
                    ),
                    if (fare != null && fare.activeDates.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Padding(
                      //       padding: const EdgeInsets.only(top: 2),
                      //       child: Text(
                      //         'active_dates'.tr,
                      //         style: textRegular.copyWith(
                      //           fontSize: 12,
                      //           color: const Color(0xFF64748B),
                      //         ),
                      //       ),
                      //     ),
                      //     const SizedBox(width: 12),
                      //     Expanded(
                      //       child: Wrap(
                      //         alignment: WrapAlignment.end,
                      //         spacing: 6,
                      //         runSpacing: 6,
                      //         children: fare.activeDates.map((dateStr) {
                      //           final dt = DateTime.tryParse(dateStr.trim());
                      //           final label = dt != null
                      //               ? DateFormat('EEE, dd MMM').format(dt)
                      //               : dateStr;
                      //           return Container(
                      //             padding: const EdgeInsets.symmetric(
                      //                 horizontal: 8, vertical: 4),
                      //             decoration: BoxDecoration(
                      //               color: const Color(0xFFEEF2FF),
                      //               borderRadius: BorderRadius.circular(8),
                      //               border: Border.all(
                      //                 color: const Color(0xFFC7D2FE),
                      //                 width: 0.8,
                      //               ),
                      //             ),
                      //             child: Text(
                      //               label,
                      //               style: textSemiBold.copyWith(
                      //                 fontSize: 11,
                      //                 color: const Color(0xFF3730A3),
                      //               ),
                      //             ),
                      //           );
                      //         }).toList(),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),

                // Passengers & Payment Card
                _SummaryCard(
                  title: 'seats_and_passengers'.tr,
                  icon: Icons.people_rounded,
                  iconColor: const Color(0xFF16A34A),
                  iconBg: const Color(0xFFDCFCE7),
                  children: [
                    _DetailRow(
                      label: 'total_seats'.tr,
                      value:
                          '${controller.seatsCount} ${controller.seatsCount == 1 ? 'seat'.tr : 'seats'.tr}',
                    ),
                    _DetailRow(
                      label: 'who_will_pay'.tr,
                      value: controller.paymentResponsibility ==
                              PaymentResponsibility.creatorPays
                          ? 'creator_pays'.tr
                          : 'each_passenger_pays'.tr,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'passenger_roster'.tr,
                      style: textSemiBold.copyWith(
                          fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    ...controller.passengers.asMap().entries.map((entry) {
                      final p = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              p.isCurrentUser
                                  ? Icons.person_rounded
                                  : Icons.person_outline_rounded,
                              size: 16,
                              color: p.isCurrentUser
                                  ? const Color(0xFF00A0E9)
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              p.name,
                              style: textSemiBold.copyWith(
                                  fontSize: 12, color: const Color(0xFF0F172A)),
                            ),
                            if (p.isCurrentUser) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('creator'.tr,
                                    style: textBold.copyWith(
                                        fontSize: 9,
                                        color: const Color(0xFF00A0E9))),
                              ),
                            ],
                            const Spacer(),
                            Text(
                              p.phone,
                              style: textRegular.copyWith(
                                  fontSize: 11, color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 24),

                // Confirm Request Action Button
                controller.isSubmitting
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
                        buttonText: 'confirm_request'.tr,
                        radius: 12,
                        onPressed: () async {
                          final success =
                              await controller.confirmAndCreateRequest();
                          if (success && controller.currentTrip != null) {
                            Get.off(() => SpecialTripDetailsScreen(
                                trip: controller.currentTrip!));
                          }
                        },
                      ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final List<Widget> children;

  const _SummaryCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: textBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

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
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: textSemiBold.copyWith(
                fontSize: 12,
                color: const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
