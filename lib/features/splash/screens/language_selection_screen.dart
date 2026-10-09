import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final VoidCallback onLanguageSelected;

  const LanguageSelectionScreen({super.key, required this.onLanguageSelected});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  // --- CUSTOM COLOR PALETTE CONFIGURATION ---
  // Light Theme Palette
  static const Color _lPrimary =
      Color(0xFF06AAF2); // FIXED: Alpha channel updated from 0x00 to 0xFF
  static const Color _lBg = Color(0xFFF8F9FA); // Soft White
  static const Color _lCard = Color(0xFFFFFFFF); // Pure White
  static const Color _lText = Color(0xFF1A1D20); // Dark Charcoal
  static const Color _lBorder = Color(0xFFE9ECEF); // Soft Gray Border

  // Dark Theme Palette
  static const Color _dPrimary = Color(0xFFB9E7FA); // High-Contrast Neon Green
  static const Color _dBg = Color(0xFF121212); // Deep Background
  static const Color _dCard = Color(0xFF1E1E1E); // Elevated Surface Dark
  static const Color _dText = Color(0xFFF8F9FA); // Clean Off-White Text
  static const Color _dBorder = Color(0xFF2C3036); // Deep Border Gray

  @override
  void initState() {
    super.initState();
    Get.find<LocalizationController>().setInitialIndex();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    final Color currentBg = isDark ? _dBg : _lBg;
    final Color currentCard = isDark ? _dCard : _lCard;
    final Color currentPrimary = isDark ? _dPrimary : _lPrimary;
    final Color currentText = isDark ? _dText : _lText;
    final Color currentBorder = isDark ? _dBorder : _lBorder;

    return Scaffold(
      backgroundColor: currentBg,
      body: GetBuilder<LocalizationController>(
        builder: (localizationController) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
                vertical: Dimensions.paddingSizeExtraLarge,
              ),
              child: Column(
                children: [
                  const Spacer(),

                  // App Logo
                  Center(
                    child: Image.asset(
                      Images.icon,
                      width: 180,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Title Text
                  Text(
                    'choose_your_language_to_processed'.tr.isEmpty
                        ? 'Select Language / اختر اللغة'
                        : 'choose_your_language_to_processed'.tr,
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                      color: currentText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Language List
                  ListView.builder(
                    itemCount: AppConstants.languages.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final language = AppConstants.languages[index];
                      final isSelected =
                          localizationController.selectIndex == index;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(
                            bottom: Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          // Fixed background tint logic
                          color: isSelected
                              ? currentPrimary.withOpacity(isDark ? 0.12 : 0.06)
                              : currentCard,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusLarge),
                          border: Border.all(
                            width: isSelected ? 2.0 : 1.0,
                            color: isSelected ? currentPrimary : currentBorder,
                          ),
                          boxShadow: [
                            if (!isDark && !isSelected)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            localizationController.setSelectIndex(index);
                          },
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusLarge),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeLarge,
                              vertical: 18,
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  language.imageUrl,
                                  height: 30,
                                  width: 30,
                                ),
                                const SizedBox(
                                    width: Dimensions.paddingSizeLarge),
                                Expanded(
                                  child: Text(
                                    '${language.countryCode} (${language.languageName})',
                                    style: textSemiBold.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      color: isSelected
                                          ? currentPrimary
                                          : currentText,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: currentPrimary,
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const Spacer(flex: 2),

                  // Continue Button
                  ButtonWidget(
                    buttonText:
                        'continue'.tr.isEmpty ? 'Continue' : 'continue'.tr,
                    onPressed: () {
                      final selectedLanguage = AppConstants
                          .languages[localizationController.selectIndex];
                      localizationController.setLanguage(Locale(
                        selectedLanguage.languageCode,
                        selectedLanguage.countryCode,
                      ));
                      widget.onLanguageSelected();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
