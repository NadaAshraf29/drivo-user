import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/settings/widget/language_select_bottomsheet.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/auth/screens/reset_password_screen.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  static const Color _primaryBlue = Color(0xFF00A3EC);
  static const Color _textDark = Color(0xFF1E2432);
  static const Color _textSubtle = Color(0xFF8C94A3);
  static const Color _cardBorder = Color(0xFFEBEFF5);

  @override
  void initState() {
    Get.find<LocalizationController>().setInitialIndex();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String languageName = '';
    for (var element in AppConstants.languages) {
      if (element.languageCode ==
          Get.find<LocalizationController>().locale.languageCode) {
        languageName = element.languageName;
        break;
      }
    }

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
                        onTap: () => Get.back(),
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
                          'settings'.tr,
                          style: textBold.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                        Text(
                          'Manage your app settings & security'.tr,
                          style: textRegular.copyWith(
                            fontSize: 12,
                            color: _textSubtle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // SECTION: GENERAL SETTINGS
                Text(
                  'PREFERENCES & SECURITY'.tr,
                  style: textSemiBold.copyWith(
                    color: _textSubtle,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),

                Container(
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        // Language Row
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                isDismissible: false,
                                enableDrag: false,
                                backgroundColor: Theme.of(context).cardColor,
                                context: context,
                                builder: (context) {
                                  return const LanguageSelectBottomSheet();
                                },
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F6FE),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      Images.languageSetting,
                                      width: 20,
                                      height: 20,
                                      color: _primaryBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      'language'.tr,
                                      style: textSemiBold.copyWith(
                                        fontSize: 15,
                                        color: _textDark,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F5F8),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      languageName,
                                      style: textSemiBold.copyWith(
                                        fontSize: 13,
                                        color: _primaryBlue,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 22,
                                    color: Color(0xFFB0B7C3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(
                            height: 1,
                            thickness: 0.8,
                            color: Color(0xFFF0F3F7),
                          ),
                        ),

                        // Change Password Row
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Get.to(
                              () => const ResetPasswordScreen(
                                fromChangePassword: true,
                                phoneNumber: '',
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F6FE),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      Images.password,
                                      width: 20,
                                      height: 20,
                                      color: _primaryBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      'change_password'.tr,
                                      style: textSemiBold.copyWith(
                                        fontSize: 15,
                                        color: _textDark,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 22,
                                    color: Color(0xFFB0B7C3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // APP INFO FOOTER
                Center(
                  child: Column(
                    children: [
                      Text(
                        AppConstants.appName,
                        style: textBold.copyWith(
                          fontSize: 14,
                          color: _textSubtle,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Version ${AppConstants.appVersion}',
                        style: textRegular.copyWith(
                          fontSize: 12,
                          color: const Color(0xFFB0B7C3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
