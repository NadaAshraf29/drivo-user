import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/features/notification/screens/notification_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/screens/profile_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SchoolTopBar extends StatelessWidget {
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const SchoolTopBar({
    super.key,
    this.showBackButton = false,
    this.onBackPressed,
  });

  String _profileImageUrl(String? profileImage) {
    if (profileImage == null || profileImage.isEmpty) return '';
    if (profileImage.startsWith('http://') ||
        profileImage.startsWith('https://')) {
      return profileImage;
    }
    return '${Get.find<ConfigController>().config?.imageBaseUrl?.profileImage ?? ''}/$profileImage';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Back button or Notification bell icon
          if (showBackButton)
            InkWell(
              onTap: onBackPressed ?? () => Get.back(),
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
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            )
          else
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

          // Center: Location Pill (● Current Location ⌵)
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GetBuilder<LocationController>(
                builder: (locationController) {
                  final address = locationController.getUserAddress();
                  final locationText = address?.address ??
                      (locationController.address.isNotEmpty
                          ? locationController.address
                          : 'select_your_location'.tr);
                  return InkWell(
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
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00A0E9),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              locationText,
                              style: textMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: const Color(0xFF4A5568),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Color(0xFF4A5568),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Right: User Profile Avatar
          InkWell(
            onTap: () => Get.to(() => const ProfileScreen()),
            borderRadius: BorderRadius.circular(20),
            child: GetBuilder<ProfileController>(
              builder: (profileCtrl) {
                final profileImg =
                    profileCtrl.profileModel?.data?.profileImage;
                final fName =
                    profileCtrl.profileModel?.data?.firstName ?? '';
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
                              style: const TextStyle(
                                color: Color(0xFF00A0E9),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
    );
  }
}

