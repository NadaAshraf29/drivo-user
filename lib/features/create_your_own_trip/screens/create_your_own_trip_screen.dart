import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/controller/create_your_own_trip_controller.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/screens/special_trip_fare_confirmation_screen.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/widgets/payment_responsibility_card.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/widgets/pickup_destination_card.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/widgets/schedule_recurring_card.dart';
import 'package:ride_sharing_user_app/features/create_your_own_trip/widgets/seats_and_passengers_card.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CreateYourOwnTripScreen extends StatelessWidget {
  const CreateYourOwnTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateYourOwnTripController>(
      builder: (controller) {
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
              'Request Your Own Car'.tr,
              style: textBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: const Color(0xFF0F172A),
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Feature Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFBAE6FD),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00A0E9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.alt_route_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'create_your_custom_trip'.tr,
                                style: textBold.copyWith(
                                  fontSize: 15,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'create_trip_header_subtitle'.tr,
                                style: textRegular.copyWith(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 1. Pickup & Destination Points
                  const PickupDestinationCard(),
                  const SizedBox(height: 16),

                  // 2. Schedule & Recurring Days
                  const ScheduleRecurringCard(),
                  const SizedBox(height: 16),

                  // 3. Seats & Passenger Selection
                  const SeatsAndPassengersCard(),
                  const SizedBox(height: 16),

                  // 4. Payment Responsibility (Creator Pays vs Each Passenger Pays)
                  const PaymentResponsibilityCard(),
                  const SizedBox(height: 24),

                  // 5. Request Fare Action Button
                  controller.isLoadingFare
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
                          buttonText: 'request_fare'.tr,
                          radius: 12,
                          onPressed: () async {
                            final success = await controller.requestFare();
                            if (success) {
                              Get.to(() =>
                                  const SpecialTripFareConfirmationScreen());
                            }
                          },
                        ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
