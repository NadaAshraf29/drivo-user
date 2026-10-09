import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/controller/create_your_own_trip_controller.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/domain/models/passenger_model.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/widgets/add_passenger_bottom_sheet.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SeatsAndPassengersCard extends StatelessWidget {
  const SeatsAndPassengersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateYourOwnTripController>(
      builder: (controller) {
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
              // Header
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.airline_seat_recline_normal_rounded,
                      color: Color(0xFF2563EB),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'seats_and_passengers'.tr,
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Number of Seats Selector
              Text(
                'number_of_seats'.tr,
                style: textSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [1, 2, 3, 4].map((count) {
                  final isSelected = controller.seatsCount == count;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => controller.setSeatsCount(count),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$count ${count == 1 ? 'seat'.tr : 'seats'.tr}',
                            style: textBold.copyWith(
                              fontSize: 12,
                              color: isSelected ? Colors.white : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Passengers Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'passengers'.tr,
                    style: textSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  Text(
                    '${controller.passengers.length}/${controller.seatsCount} ${'reserved'.tr}',
                    style: textMedium.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Passenger 1: Current User (Creator)
              if (controller.passengers.isNotEmpty)
                _PassengerTile(
                  seatNumber: 1,
                  passenger: controller.passengers.first,
                  isCreator: true,
                  onRemove: null,
                ),

              // Additional Passengers (Seats 2..seatsCount)
              if (controller.seatsCount > 1) ...[
                const SizedBox(height: 8),
                for (int i = 1; i < controller.seatsCount; i++) ...[
                  if (i < controller.passengers.length)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _PassengerTile(
                        seatNumber: i + 1,
                        passenger: controller.passengers[i],
                        isCreator: false,
                        onRemove: () => controller.removePassenger(i),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _AddPassengerSlot(
                        seatNumber: i + 1,
                        onTap: () => AddPassengerBottomSheet.show(context),
                      ),
                    ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _PassengerTile extends StatelessWidget {
  final int seatNumber;
  final SpecialTripPassengerModel passenger;
  final bool isCreator;
  final VoidCallback? onRemove;

  const _PassengerTile({
    required this.seatNumber,
    required this.passenger,
    required this.isCreator,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isCreator ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9),
            child: Icon(
              isCreator ? Icons.person_rounded : Icons.person_outline_rounded,
              color: isCreator ? const Color(0xFF00A0E9) : const Color(0xFF64748B),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      passenger.name,
                      style: textSemiBold.copyWith(
                        fontSize: 13,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    if (isCreator) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'you_creator'.tr,
                          style: textBold.copyWith(
                            fontSize: 9,
                            color: const Color(0xFF00A0E9),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  passenger.phone.isNotEmpty ? passenger.phone : '${'seat'.tr} $seatNumber',
                  style: textRegular.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          if (!isCreator && onRemove != null)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFEF4444), size: 20),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

class _AddPassengerSlot extends StatelessWidget {
  final int seatNumber;
  final VoidCallback onTap;

  const _AddPassengerSlot({
    required this.seatNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF00A0E9).withValues(alpha: 0.4),
            style: BorderStyle.solid,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.person_add_alt_1_rounded,
                size: 16,
                color: Color(0xFF00A0E9),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${'add_passenger_for_seat'.tr} $seatNumber',
                    style: textSemiBold.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF00A0E9),
                    ),
                  ),
                  Text(
                    'search_by_mobile_number'.tr,
                    style: textRegular.copyWith(
                      fontSize: 10,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF00A0E9),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
