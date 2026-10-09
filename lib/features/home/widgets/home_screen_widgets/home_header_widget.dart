import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/screens/profile_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

import '../../../notification/screens/notification_screen.dart';
import 'package:ride_sharing_user_app/features/walkthrough/controllers/walkthrough_controller.dart';
import 'package:ride_sharing_user_app/features/walkthrough/domain/models/walkthrough_model.dart';
import 'package:ride_sharing_user_app/features/walkthrough/helpers/walkthrough_helper.dart';
import 'package:ride_sharing_user_app/features/walkthrough/widgets/how_it_works_button.dart';

class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({super.key});

  String _greetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'good_morning'.tr;
    } else if (hour < 17) {
      return 'good_afternoon'.tr;
    } else if (hour < 21) {
      return 'good_evening'.tr;
    } else {
      return 'good_night'.tr;
    }
  }

  String _profileImageUrl(String? profileImage) {
    if (profileImage == null || profileImage.isEmpty) return '';
    if (profileImage.startsWith('http://') ||
        profileImage.startsWith('https://')) {
      return profileImage;
    }
    return '${Get.find<ConfigController>().config!.imageBaseUrl!.profileImage}/$profileImage';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Notification Button
              InkWell(
                onTap: () => Get.to(() => const NotificationScreen()),
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
                      Icons.notifications_none_rounded,
                      size: 20,
                      color: Color(0xFF4A5568),
                    ),
                  ),
                ),
              ),

              // Center: Location Pill
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: InkWell(
                    onTap: () => Get.to(() => const PickMapScreen(
                          type: LocationType.accessLocation,
                        )),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(30),
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
                          const SizedBox(width: 8),
                          Flexible(
                            child: GetBuilder<LocationController>(
                              builder: (locationController) {
                                final userAddress =
                                    locationController.getUserAddress();
                                final addressText = userAddress?.address ??
                                    (locationController.address.isNotEmpty
                                        ? locationController.address
                                        : 'select_your_location'.tr);
                                return Text(
                                  addressText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textMedium.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: const Color(0xFF4A5568),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Right: Profile Avatar
              InkWell(
                onTap: () => Get.to(() => const ProfileScreen()),
                borderRadius: BorderRadius.circular(20),
                child: GetBuilder<ProfileController>(
                  builder: (profileController) {
                    final profileImg =
                        profileController.profileModel?.data?.profileImage;
                    final fName =
                        profileController.profileModel?.data?.firstName ?? '';
                    final initial =
                        fName.isNotEmpty ? fName[0].toUpperCase() : 'Z';

                    return SizedBox(
                      width: 38,
                      height: 38,
                      child: ClipOval(
                        child: profileImg != null && profileImg.isNotEmpty
                            ? ImageWidget(
                                image: _profileImageUrl(profileImg),
                                placeholder: Images.personPlaceholder,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: const Color(0xFFE0F2FE),
                                alignment: Alignment.center,
                                child: Text(
                                  initial,
                                  style: textBold.copyWith(
                                    fontSize: 14,
                                    color: const Color(0xFF0284C7),
                                  ),
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Greeting & How it works
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GetBuilder<ProfileController>(
                      builder: (profileController) {
                        final firstName = profileController.customerFirstName();
                        final displayName =
                            firstName.isNotEmpty ? firstName : 'guest'.tr;
                        return Text(
                          '${_greetingMessage()}, $displayName 👋',
                          style: textBold.copyWith(
                            fontSize: 22,
                            color: const Color(0xFF0F172A),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'where_do_you_want_to_go'.tr,
                      style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              HowItWorksButton(
                onTap: () {
                  if (Get.isRegistered<WalkthroughController>()) {
                    Get.find<WalkthroughController>().startFlow(
                      WalkthroughFlowType.home,
                      WalkthroughHelper.getHomeSteps(),
                      isManual: true,
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
