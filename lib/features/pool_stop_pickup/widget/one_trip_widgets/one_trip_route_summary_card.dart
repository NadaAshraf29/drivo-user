import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class OneTripRouteSummaryCard extends StatelessWidget {
  final String pickupAddress;
  final String destinationAddress;
  final String dateText;
  final String timeText;
  final int seatsCount;

  const OneTripRouteSummaryCard({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.dateText,
    required this.timeText,
    required this.seatsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const SizedBox(height: 3),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00A0E9),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 46,
                    color: const Color(0xFFE2E8F0),
                  ),
                  const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFFEF4444),
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'pickup_uppercase'.tr.isNotEmpty &&
                              'pickup_uppercase'.tr != 'pickup_uppercase'
                          ? 'pickup_uppercase'.tr
                          : ('from'.tr.isNotEmpty && 'from'.tr != 'from'
                              ? 'from'.tr.toUpperCase()
                              : 'PICKUP'),
                      style: textBold.copyWith(
                        fontSize: 9,
                        letterSpacing: 0.5,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            pickupAddress,
                            style: textBold.copyWith(
                              fontSize: 14,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            timeText,
                            style: textMedium.copyWith(
                              fontSize: 11,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'destination_uppercase'.tr.isNotEmpty &&
                              'destination_uppercase'.tr != 'destination_uppercase'
                          ? 'destination_uppercase'.tr
                          : ('to'.tr.isNotEmpty && 'to'.tr != 'to'
                              ? 'to'.tr.toUpperCase()
                              : 'DESTINATION'),
                      style: textBold.copyWith(
                        fontSize: 9,
                        letterSpacing: 0.5,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      destinationAddress,
                      style: textBold.copyWith(
                        fontSize: 14,
                        color: const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateText,
                    style: textMedium.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.airline_seat_recline_normal_rounded,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$seatsCount ${seatsCount == 1 ? ('seat'.tr.isNotEmpty && 'seat'.tr != 'seat' ? 'seat'.tr : 'Seat') : ('seats'.tr.isNotEmpty && 'seats'.tr != 'seats' ? 'seats'.tr : 'Seats')}',
                    style: textMedium.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// ponytail: extracted widget class — follow single class per file rule
