import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/message/controllers/message_controller.dart';
import 'package:ride_sharing_user_app/features/university/controllers/university_controller.dart';
import 'package:ride_sharing_user_app/features/university/domain/models/university_active_trip_model.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_ongoing_actions_card.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_ongoing_driver_card.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_ongoing_map_card.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_ongoing_passengers_card.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_ongoing_route_card.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_ongoing_sos_card.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_ongoing_trip_code_card.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_ongoing_trip_header.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_sos_confirmation_dialog.dart';
import 'package:ride_sharing_user_app/features/university/widgets/university_top_bar.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class UniversityOngoingTripScreen extends StatefulWidget {
  final UniversityActiveTripModel? trip;

  const UniversityOngoingTripScreen({
    super.key,
    this.trip,
  });

  @override
  State<UniversityOngoingTripScreen> createState() =>
      _UniversityOngoingTripScreenState();
}

class _UniversityOngoingTripScreenState
    extends State<UniversityOngoingTripScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<UniversityController>()) {
        Get.find<UniversityController>().getActiveTrip();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: GetBuilder<UniversityController>(
          builder: (uniController) {
            final activeTrip = widget.trip ?? uniController.activeTrip;

            if (activeTrip == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.directions_bus_outlined,
                          size: 48, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 12),
                      Text(
                        'no_active_trip_found'.tr,
                        style: textMedium.copyWith(
                          color: const Color(0xFF64748B),
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('back'.tr),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top address bar & profile
                  const UniversityTopBar(showBackButton: false),

                  // Sub-header with back button, trip title & status badge
                  UniversityOngoingTripHeader(
                    title: 'university_trip'.tr,
                    subtitle:
                        '${activeTrip.seatLabel} · ${activeTrip.routeSubtitle}',
                    statusText: activeTrip.statusText.isNotEmpty
                        ? activeTrip.statusText
                        : 'on_route'.tr,
                    onBack: () => Get.back(),
                  ),
                  const SizedBox(height: 10),

                  // Content Cards Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Map preview card
                        UniversityOngoingMapCard(trip: activeTrip),
                        const SizedBox(height: 14),

                        // 2. Route & Timings card
                        UniversityOngoingRouteCard(
                          pickupAddress: activeTrip.pickupAddress,
                          destinationAddress: activeTrip.destinationAddress,
                          pickupEta: '${activeTrip.pickupEtaMinutes} min',
                          arrivalTime: activeTrip.estimatedArrival,
                          departureDate:
                              '${'today'.tr} · ${activeTrip.departureTime}',
                          carpoolSeatInfo:
                              '${'carpool_seat'.tr} ${activeTrip.seatLabel.replaceAll(RegExp(r'[^0-9/]'), '').trim()}',
                        ),
                        const SizedBox(height: 14),

                        // 3. Driver card
                        UniversityOngoingDriverCard(
                          driver: activeTrip.driver,
                        ),
                        const SizedBox(height: 14),

                        // 4. Start trip code card
                        UniversityOngoingTripCodeCard(
                          startTripCode: activeTrip.startTripCode,
                        ),
                        const SizedBox(height: 14),

                        // 5. Message & Call action buttons
                        UniversityOngoingActionsCard(
                          onMessage: () => _handleMessage(activeTrip),
                          onCall: () => _handleCall(activeTrip.driver.phone),
                        ),
                        const SizedBox(height: 14),

                        // 6. Riding with you passengers card
                        UniversityOngoingPassengersCard(
                          passengers: activeTrip.passengers,
                          additionalPassengersCount:
                              activeTrip.additionalPassengersCount,
                          totalPassengersText: activeTrip.totalPassengersText,
                        ),
                        const SizedBox(height: 14),

                        // 7. SOS Emergency card
                        UniversityOngoingSosCard(
                          onSosPressed: _handleSos,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleCall(String phone) async {
    final cleanPhone = phone.replaceAll(' ', '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      showCustomSnackBar('cannot_make_phone_call'.tr);
    }
  }

  void _handleMessage(UniversityActiveTripModel trip) {
    if (Get.isRegistered<MessageController>() && trip.driver.id.isNotEmpty) {
      Get.find<MessageController>().createChannel(
        trip.driver.id,
        trip.id,
      );
    } else {
      showCustomSnackBar('${'message'.tr} ${trip.driver.name}');
    }
  }

  void _handleSos() {
    Get.dialog(
      UniversitySosConfirmationDialog(
        onConfirm: () {
          final uri = Uri.parse('tel:122');
          launchUrl(uri);
        },
      ),
    );
  }
}
