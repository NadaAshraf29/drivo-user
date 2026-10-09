import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/loader_widget.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/dashboard/controllers/bottom_menu_controller.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';

class AccessLocationScreen extends StatelessWidget {
  const AccessLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    const Color brandPrimary = Color(0xFF06AAF2);
    final Color bgColor = isDark ? const Color(0xFF14171A) : const Color(0xFFF8FAFC);
    final Color cardBg = isDark ? const Color(0xFF1E242B) : Colors.white;
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Row(
                children: [
                  if (Navigator.canPop(context))
                    InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF2D3748)
                                : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: titleColor,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      'set_location'.tr,
                      textAlign: TextAlign.center,
                      style: textSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: titleColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Balance the back button
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                    vertical: Dimensions.paddingSizeDefault,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),

                        // Hero Visual Graphic
                        _buildHeroIllustration(isDark, brandPrimary, cardBg),

                        const SizedBox(height: 36),

                        // Title
                        Text(
                          'find_driver_near_you'.tr,
                          textAlign: TextAlign.center,
                          style: textBold.copyWith(
                            fontSize: 24,
                            color: titleColor,
                            height: 1.25,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                          ),
                          child: Text(
                            'please_select_you_location_to_start_finding_available_driver_near_you'.tr,
                            textAlign: TextAlign.center,
                            style: textRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: subtitleColor,
                              height: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Micro feature badges
                        _buildFeaturePills(isDark, brandPrimary),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.paddingSizeLarge,
                Dimensions.paddingSizeSmall,
                Dimensions.paddingSizeLarge,
                Dimensions.paddingSizeLarge,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: const BottomButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Modern layered location hero illustration
  Widget _buildHeroIllustration(bool isDark, Color brandPrimary, Color cardBg) {
    return SizedBox(
      height: 220,
      width: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ripple ring
          Container(
            height: 220,
            width: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: brandPrimary.withValues(alpha: isDark ? 0.04 : 0.05),
              border: Border.all(
                color: brandPrimary.withValues(alpha: isDark ? 0.08 : 0.12),
                width: 1.5,
              ),
            ),
          ),

          // Middle ripple ring
          Container(
            height: 165,
            width: 165,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: brandPrimary.withValues(alpha: isDark ? 0.08 : 0.09),
              border: Border.all(
                color: brandPrimary.withValues(alpha: isDark ? 0.16 : 0.22),
                width: 1.5,
              ),
            ),
          ),

          // Center prominent elevated badge
          Container(
            height: 110,
            width: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cardBg,
              boxShadow: [
                BoxShadow(
                  color: brandPrimary.withValues(alpha: 0.25),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                Images.mapLocationIcon,
                height: 54,
                width: 54,
                color: brandPrimary,
              ),
            ),
          ),

          // Floating GPS indicator badge (top-right)
          Positioned(
            top: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: brandPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: brandPrimary.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.near_me_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),

          // Floating Driver badge (bottom-left)
          Positioned(
            bottom: 24,
            left: 24,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF242C35) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: brandPrimary.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.directions_car_rounded,
                size: 16,
                color: brandPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Feature pills highlighting app capabilities
  Widget _buildFeaturePills(bool isDark, Color brandPrimary) {
    final Color pillBg = isDark
        ? const Color(0xFF1E242B)
        : brandPrimary.withValues(alpha: 0.06);
    final Color pillBorder = isDark
        ? const Color(0xFF2D3748)
        : brandPrimary.withValues(alpha: 0.12);
    final Color pillTextColor = isDark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF334155);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildPill(
          icon: Icons.gps_fixed_rounded,
          label: 'precise_location'.tr.isNotEmpty && 'precise_location'.tr != 'precise_location'
              ? 'precise_location'.tr
              : 'Precise Pickup',
          bgColor: pillBg,
          borderColor: pillBorder,
          iconColor: brandPrimary,
          textColor: pillTextColor,
        ),
        _buildPill(
          icon: Icons.bolt_rounded,
          label: 'fast_matching'.tr.isNotEmpty && 'fast_matching'.tr != 'fast_matching'
              ? 'fast_matching'.tr
              : 'Fast Matching',
          bgColor: pillBg,
          borderColor: pillBorder,
          iconColor: brandPrimary,
          textColor: pillTextColor,
        ),
        _buildPill(
          icon: Icons.security_rounded,
          label: 'safe_rides'.tr.isNotEmpty && 'safe_rides'.tr != 'safe_rides'
              ? 'safe_rides'.tr
              : 'Safe & Secure',
          bgColor: pillBg,
          borderColor: pillBorder,
          iconColor: brandPrimary,
          textColor: pillTextColor,
        ),
      ],
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color borderColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: textMedium.copyWith(
              fontSize: 12,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class BottomButton extends StatelessWidget {
  const BottomButton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    const Color brandPrimary = Color(0xFF06AAF2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Primary Button: Use Current Location
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              if (GetPlatform.isIOS) {
                saveAndNavigate();
              } else {
                Get.find<LocationController>().checkPermission(() async {
                  saveAndNavigate();
                });
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF06AAF2),
                    Color(0xFF0095DC),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: brandPrimary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.my_location_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'use_current_location'.tr,
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary Button: Set From Map
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Get.to(
              () => const PickMapScreen(type: LocationType.accessLocation),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              height: 52,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E242B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: brandPrimary.withValues(alpha: 0.85),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.map_outlined,
                    color: brandPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'set_from_map'.tr,
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: brandPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void saveAndNavigate() async {
    Get.dialog(const LoaderWidget(), barrierDismissible: false);
    Address? address =
        await Get.find<LocationController>().getCurrentLocation();
    if (address != null) {
      await Get.find<LocationController>().saveUserAddress(address);
      Get.find<BottomMenuController>().navigateToDashboard();
    } else {
      Get.back();
      bool isLocationServiceEnable =
          await Geolocator.isLocationServiceEnabled();
      if (isLocationServiceEnable) {
        showCustomSnackBar('service_not_available'.tr);
      } else {
        showCustomSnackBar('your_location_access_first'.tr);
      }
    }
  }
}
