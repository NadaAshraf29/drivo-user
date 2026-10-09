import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/profile/widgets/edit_profile_account_info.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';

class EditProfileScreen extends StatefulWidget {
  final bool fromLogin;
  const EditProfileScreen({super.key, this.fromLogin = false});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color _primaryBlue = Color(0xFF00A3EC);
  static const Color _textDark = Color(0xFF1E2432);
  static const Color _textSubtle = Color(0xFF8C94A3);
  static const Color _cardBorder = Color(0xFFEBEFF5);

  void onBackPressed() {
    if (widget.fromLogin) {
      Get.find<BottomMenuController>().exitApp();
    } else {
      Get.back();
    }
  }

  @override
  void initState() {
    Get.find<ProfileController>().identityImages.clear();
    Get.find<ProfileController>().clearSelectedImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 248, 248),
      body: BodyWidget(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Navigation Bar
                Row(
                  children: [
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: onBackPressed,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _cardBorder),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: _textDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'edit_profile'.tr,
                          style: textBold.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                        Text(
                          'Update your personal information'.tr,
                          style: textRegular.copyWith(
                            fontSize: 12,
                            color: _textSubtle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Top Profile Hero Header
                GetBuilder<ProfileController>(builder: (profileController) {
                  final profileData = profileController.profileModel?.data;
                  final userRating = profileData?.userRating ?? '5.0';

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar with camera change button
                        InkWell(
                          onTap: () => profileController.pickImage(false, true),
                          borderRadius: BorderRadius.circular(40),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFF3F5F8),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                    width: 1.5,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: profileController.pickedProfileFile ==
                                          null
                                      ? ImageWidget(
                                          height: 68,
                                          width: 68,
                                          image: _profileImageUrl(
                                            profileData?.profileImage,
                                          ),
                                          placeholder: Images.personPlaceholder,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(profileController
                                              .pickedProfileFile!.path),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _primaryBlue,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(5),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Name & Rating
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profileController.customerName(),
                                style: textBold.copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  // Rating pill
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF8E1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          size: 14,
                                          color: Color(0xFFFFB300),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          userRating,
                                          style: textBold.copyWith(
                                            fontSize: 12,
                                            color: const Color(0xFF8D6E63),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (profileData?.level?.name != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F6FE),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        profileData!.level!.name!,
                                        style: textSemiBold.copyWith(
                                          fontSize: 11,
                                          color: _primaryBlue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Form Fields inside scrollable area
                Expanded(
                  child: EditProfileAccountInfo(fromAccount: widget.fromLogin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _profileImageUrl(String? profileImage) {
    if (profileImage == null || profileImage.isEmpty) return '';
    if (profileImage.startsWith('http://') ||
        profileImage.startsWith('https://')) {
      return profileImage;
    }
    return '${Get.find<ConfigController>().config!.imageBaseUrl!.profileImage}/$profileImage';
  }
}
