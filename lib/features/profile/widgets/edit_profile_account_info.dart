import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/location/view/access_location_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';

class EditProfileAccountInfo extends StatefulWidget {
  final bool fromAccount;
  const EditProfileAccountInfo({super.key, this.fromAccount = false});

  @override
  State<EditProfileAccountInfo> createState() => _EditProfileAccountInfoState();
}

class _EditProfileAccountInfoState extends State<EditProfileAccountInfo> {
  static const Color _primaryBlue = Color(0xFF00A3EC);
  static const Color _textDark = Color(0xFF1E2432);
  static const Color _textSubtle = Color(0xFF8C94A3);
  static const Color _cardBorder = Color(0xFFEBEFF5);

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController idNumberController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + Get.height * 0.3,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void initState() {
    super.initState();
    final profile = Get.find<ProfileController>().profileModel?.data;
    firstNameController.text = profile?.firstName ?? '';
    lastNameController.text = profile?.lastName ?? '';
    phoneController.text = profile?.phone ?? '';
    idNumberController.text = profile?.identificationNumber ?? '';

    if (profile != null &&
        profile.identificationType != null &&
        (profile.identificationType == 'nid' ||
            profile.identificationType == 'passport')) {
      Get.find<ProfileController>()
          .setIdentityType(profile.identificationType!, notify: false);
    } else {
      Get.find<ProfileController>()
          .setIdentityType('nid', notify: false);
    }

    Get.find<ProfileController>().setGender(
      profile?.gender,
      notify: false,
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    idNumberController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileController) {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CARD 1: PERSONAL INFORMATION
                  _buildSectionTitle('PERSONAL INFORMATION'.tr),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('first_name'.tr),
                        const SizedBox(height: 6),
                        CustomTextField(
                          prefixIcon: Images.editProfileName,
                          borderRadius: 12,
                          capitalization: TextCapitalization.words,
                          showBorder: true,
                          controller: firstNameController,
                          hintText: 'enter_first_name'.tr,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                        const SizedBox(height: 14),

                        _buildFieldLabel('last_name'.tr),
                        const SizedBox(height: 6),
                        CustomTextField(
                          prefixIcon: Images.editProfileName,
                          borderRadius: 12,
                          capitalization: TextCapitalization.words,
                          showBorder: true,
                          controller: lastNameController,
                          hintText: 'enter_last_name'.tr,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                        const SizedBox(height: 14),

                        _buildFieldLabel('phone'.tr),
                        const SizedBox(height: 6),
                        CustomTextField(
                          isEnabled: false,
                          prefixIcon: Images.editProfilePhone,
                          borderRadius: 12,
                          controller: phoneController,
                          textColor: _textSubtle,
                          showBorder: true,
                          hintText: 'enter_your_phone'.tr,
                          fillColor: const Color(0xFFF1F5F9),
                        ),
                        const SizedBox(height: 14),

                        _buildFieldLabel('gender'.tr),
                        const SizedBox(height: 6),
                        Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              hint: Text(
                                'select_gender'.tr,
                                style: textRegular.copyWith(
                                  color: _textSubtle,
                                  fontSize: 14,
                                ),
                              ),
                              value: profileController.selectedGender,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: _textSubtle,
                              ),
                              items: profileController.genderList
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value.tr,
                                    style: textMedium.copyWith(
                                      color: _textDark,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  profileController.setGender(val),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CARD 2: IDENTITY VERIFICATION
                  _buildSectionTitle('IDENTITY VERIFICATION'.tr),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('identity_type'.tr),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              // National ID Button
                              Expanded(
                                child: _buildIdentityTypeButton(
                                  title: 'National ID'.tr,
                                  icon: Icons.badge_outlined,
                                  isSelected:
                                      profileController.identityType == 'nid',
                                  onTap: () {
                                    profileController.setIdentityType('nid');
                                  },
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Passport Button
                              Expanded(
                                child: _buildIdentityTypeButton(
                                  title: 'Passport'.tr,
                                  icon: Icons.menu_book_rounded,
                                  isSelected: profileController.identityType ==
                                      'passport',
                                  onTap: () {
                                    profileController
                                        .setIdentityType('passport');
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        _buildFieldLabel(profileController.identityType == 'nid'
                            ? 'National ID'.tr
                            : 'Passport'.tr),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            controller: idNumberController,
                            keyboardType:
                                profileController.identityType == 'nid'
                                    ? TextInputType.number
                                    : TextInputType.text,
                            inputFormatters:
                                profileController.identityType == 'nid'
                                    ? [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(14),
                                      ]
                                    : [
                                        LengthLimitingTextInputFormatter(20),
                                      ],
                            style: textMedium.copyWith(
                              fontSize: 14,
                              color: _textDark,
                            ),
                            decoration: InputDecoration(
                              hintText: profileController.identityType == 'nid'
                                  ? 'Enter National ID'.tr
                                  : 'Enter Passport'.tr,
                              hintStyle: textRegular.copyWith(
                                fontSize: 14,
                                color: _textSubtle.withOpacity(0.6),
                              ),
                              prefixIcon: Icon(
                                profileController.identityType == 'nid'
                                    ? Icons.badge_outlined
                                    : Icons.menu_book_rounded,
                                color: _primaryBlue,
                                size: 20,
                              ),
                              suffixIcon: profileController.identityType == 'nid'
                                  ? ValueListenableBuilder<TextEditingValue>(
                                      valueListenable: idNumberController,
                                      builder: (context, value, child) {
                                        final length = value.text.length;
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 14),
                                          child: Text(
                                            '$length/14',
                                            style: textMedium.copyWith(
                                              fontSize: 12,
                                              color: length == 14
                                                  ? _primaryBlue
                                                  : _textSubtle
                                                      .withOpacity(0.6),
                                              fontWeight: length == 14
                                                  ? FontWeight.w700
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Existing Identity Images
                        if (profileController.profileModel?.data
                                ?.identificationImage !=
                            null &&
                            profileController.profileModel!.data!
                                .identificationImage!.isNotEmpty) ...[
                          _buildFieldLabel('Uploaded Documents'.tr),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: profileController.profileModel?.data
                                ?.identificationImage?.length,
                            itemBuilder: (BuildContext context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: SizedBox(
                                    height: 120,
                                    width: double.infinity,
                                    child: ImageWidget(
                                      image:
                                          "${Get.find<ConfigController>().config?.imageBaseUrl?.identityImage}/${profileController.profileModel?.data?.identificationImage?[index] ?? ''}",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],

                        // New Picked Identity Images / Picker Slot
                        _buildFieldLabel('Add Document Images'.tr),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: profileController.identityImages.length >= 2
                              ? 2
                              : profileController.identityImages.length + 1,
                          itemBuilder: (BuildContext context, index) {
                            if (index == profileController.identityImages.length) {
                              return InkWell(
                                onTap: () async {
                                  bool res = await profileController.pickImage(
                                    false,
                                    false,
                                  );
                                  if (res) {
                                    _scrollDown();
                                  }
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: DottedBorder(
                                  strokeWidth: 1.5,
                                  dashPattern: const [6, 4],
                                  color: _primaryBlue.withOpacity(0.5),
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(14),
                                  child: Container(
                                    height: 90,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F7FD),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.cloud_upload_outlined,
                                          color: _primaryBlue,
                                          size: 28,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tap to upload ID document'.tr,
                                          style: textMedium.copyWith(
                                            color: _primaryBlue,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
                                      File(profileController
                                          .identityImages[index].path),
                                      width: double.infinity,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: InkWell(
                                    onTap: () =>
                                        profileController.removeImage(index),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.65),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // SUBMIT BUTTON
          profileController.isUpdating
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: SpinKitCircle(
                      color: _primaryBlue,
                      size: 40.0,
                    ),
                  ),
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ButtonWidget(
                    buttonText: "update_profile".tr,
                    radius: 16,
                    backgroundColor: _primaryBlue,
                    onPressed: () async {
                      if (profileController.identityType == 'nid' &&
                          idNumberController.text.isNotEmpty &&
                          idNumberController.text.length != 14) {
                        showCustomSnackBar(
                          'national_id_must_be_14_digits'.tr,
                          isError: true,
                        );
                      } else if (idNumberController.text.isNotEmpty &&
                          (idNumberController.text.length < 4 ||
                              idNumberController.text.length > 50)) {
                        showCustomSnackBar(
                          'identity_number_is_invalid'.tr,
                          isError: true,
                        );
                      } else {
                        Response response =
                            await profileController.updateProfile(
                          firstNameController.text,
                          lastNameController.text,
                          profileController.identityType,
                          idNumberController.text,
                          profileController.selectedGender,
                        );
                        if (response.statusCode == 200) {
                          showCustomSnackBar(
                            'profile_updated_successfully'.tr,
                            isError: false,
                          );
                          if (widget.fromAccount) {
                            Get.offAll(() => const AccessLocationScreen());
                          }
                        }
                      }
                    },
                  ),
                ),
        ],
      );
    });
  }

  Widget _buildIdentityTypeButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? _primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _primaryBlue.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : _textSubtle,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: isSelected
                  ? textBold.copyWith(
                      fontSize: 13,
                      color: Colors.white,
                    )
                  : textMedium.copyWith(
                      fontSize: 13,
                      color: _textDark,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: textSemiBold.copyWith(
          color: _textSubtle,
          fontSize: 11,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: textSemiBold.copyWith(
        fontSize: 13,
        color: _textDark,
      ),
    );
  }
}