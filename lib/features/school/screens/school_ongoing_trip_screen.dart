import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/message/screens/message_screen.dart';
import 'package:ride_sharing_user_app/features/school/controllers/school_controller.dart';
import 'package:ride_sharing_user_app/features/school/domain/models/school_active_trip_model.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_ongoing_actions_card.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_ongoing_driver_card.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_ongoing_map_card.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_ongoing_passengers_card.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_ongoing_route_card.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_ongoing_sos_card.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_ongoing_trip_code_card.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_ongoing_trip_header.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_sos_confirmation_dialog.dart';
import 'package:ride_sharing_user_app/features/school/widgets/school_top_bar.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class SchoolOngoingTripScreen extends StatefulWidget {
  final SchoolActiveTripModel? trip;

  const SchoolOngoingTripScreen({
    super.key,
    this.trip,
  });

  @override
  State<SchoolOngoingTripScreen> createState() =>
      _SchoolOngoingTripScreenState();
}

class _SchoolOngoingTripScreenState extends State<SchoolOngoingTripScreen> {
  bool _isOtpGiven = false;

  @override
  void initState() {
    super.initState();
    final activeTrip = widget.trip ??
        (Get.isRegistered<SchoolController>()
            ? Get.find<SchoolController>().activeTrip
            : null);
    _isOtpGiven = activeTrip?.isOtpGiven ?? false;
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        showCustomSnackBar('cannot_make_phone_call'.tr);
      }
    } catch (_) {
      showCustomSnackBar('cannot_make_phone_call'.tr);
    }
  }

  void _triggerSos(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SchoolSosConfirmationDialog(
        onConfirm: () => _makePhoneCall('122'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SchoolController>(
      builder: (schoolCtrl) {
        final activeTrip = widget.trip ?? schoolCtrl.activeTrip;

        if (activeTrip == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: SafeArea(
              child: Column(
                children: [
                  const SchoolTopBar(showBackButton: true),
                  Expanded(
                    child: Center(
                      child: Text(
                        'no_active_school_trip_found'.tr,
                        style: textMedium.copyWith(
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

        final effectiveOtpGiven = _isOtpGiven || activeTrip.isOtpGiven;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: Column(
              children: [
                const SchoolTopBar(showBackButton: true),
                const SizedBox(height: 6),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: school trip / Seat 2 of 4 • Route to Downtown / [On route]
                        SchoolOngoingTripHeader(
                          title: 'school_trip'.tr,
                          subtitle:
                              '${activeTrip.seatLabel} · ${activeTrip.routeSubtitle}',
                          status: effectiveOtpGiven
                              ? 'ongoing'
                              : activeTrip.status,
                        ),
                        const SizedBox(height: 14),

                        // Live Map Card
                        SchoolOngoingMapCard(
                          trip: activeTrip,
                          isOtpGiven: effectiveOtpGiven,
                        ),
                        const SizedBox(height: 14),

                        // Route Card
                        SchoolOngoingRouteCard(trip: activeTrip),
                        const SizedBox(height: 14),

                        // Driver Card
                        SchoolOngoingDriverCard(driver: activeTrip.driver),
                        const SizedBox(height: 14),

                        // Start Trip PIN Code Card
                        SchoolOngoingTripCodeCard(
                          pinCode: activeTrip.startTripCode,
                          isOtpGiven: effectiveOtpGiven,
                          onGiveOtp: () {
                            setState(() {
                              _isOtpGiven = true;
                            });
                          },
                        ),
                        const SizedBox(height: 14),

                        // Communication Actions (Message & Call)
                        SchoolOngoingActionsCard(
                          onMessage: () {
                            Get.to(
                              () => MessageScreen(
                                channelId: activeTrip.id,
                                tripId: activeTrip.id,
                                userName: activeTrip.driver.name,
                              ),
                            );
                          },
                          onCall: () {
                            final phone =
                                activeTrip.driver.phone ?? '+201001234567';
                            _makePhoneCall(phone);
                          },
                        ),
                        const SizedBox(height: 14),

                        // Passengers Card
                        SchoolOngoingPassengersCard(
                          passengers: activeTrip.passengers,
                          totalPassengersText: activeTrip.totalPassengersText,
                        ),
                        const SizedBox(height: 14),

                        // Emergency SOS Card
                        SchoolOngoingSosCard(
                          onSos: () => _triggerSos(context),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
