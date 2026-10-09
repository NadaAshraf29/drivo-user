import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../features/location/controllers/location_controller.dart';
import '../features/profile/controllers/profile_controller.dart';
import '../features/profile/screens/sos_screen.dart';
import '../helper/display_helper.dart';
import 'button_widget.dart';

class SosButton extends StatelessWidget {
  const SosButton({super.key, required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context) {
    return ButtonWidget(
      buttonText: 'SoS',
      backgroundColor: Colors.red,
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Activate SoS".tr),
                        IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: Icon(Icons.close),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "This will alert Drivo and notify your emergency contact".tr,
                    ),
                    SizedBox(height: 16),
                    ButtonWidget(
                      buttonText: "Send SoS",
                      onPressed: () {
                        Get.back(); // close confirmation dialog
                        final locationController =
                            Get.find<LocationController>();
                        final userAddress = locationController.getUserAddress();
                        final lat = userAddress?.latitude;
                        final lng = userAddress?.longitude;

                        final profileController = Get.find<ProfileController>();
                        profileController
                            .sendSos(
                              tripId: tripId,
                              latitude: lat,
                              longitude: lng,
                            )
                            .then((response) async {
                              if (response.statusCode == 200) {
                                showCustomSnackBar(
                                  'sos_sent_successfully'.tr,
                                  isError: false,
                                );
                                final emergencyPhone = profileController
                                    .profileModel
                                    ?.data
                                    ?.emergencyContactPhone;
                                if (emergencyPhone != null &&
                                    emergencyPhone.isNotEmpty) {
                                  final Uri launchUri = Uri(
                                    scheme: 'tel',
                                    path: emergencyPhone,
                                  );
                                  if (await canLaunchUrl(launchUri)) {
                                    await launchUrl(launchUri);
                                  }
                                }
                              } else if (response.statusCode == 403) {
                                showCustomSnackBar(
                                  response.body?['message'] ??
                                      'Please save an emergency contact name and phone before sending SOS.'
                                          .tr,
                                );
                                Get.to(() => const SosScreen());
                              }
                            });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
