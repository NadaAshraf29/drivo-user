import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/confirmation_dialog_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/features/address/screens/my_address.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/message/screens/message_list.dart';
import 'package:ride_sharing_user_app/features/my_offer/screens/my_offer_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/screens/edit_profile_screen.dart';
import 'package:ride_sharing_user_app/features/profile/widgets/profile_item.dart';
import 'package:ride_sharing_user_app/features/profile/screens/sos_screen.dart';
import 'package:ride_sharing_user_app/features/refer_and_earn/screens/refer_and_earn_screen.dart';
import 'package:ride_sharing_user_app/features/settings/domain/html_enum_types.dart';
import 'package:ride_sharing_user_app/features/settings/screens/policy_screen.dart';
import 'package:ride_sharing_user_app/features/settings/screens/setting_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/support/screens/support_screen.dart';
import 'package:ride_sharing_user_app/features/trip/screens/trip_screen.dart';
import 'package:ride_sharing_user_app/features/wallet/screens/wallet_screen.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color _primaryBlue = Color(0xFF00A3EC);
  static const Color _textDark = Color(0xFF1E2432);
  static const Color _textSubtle = Color(0xFF8C94A3);
  static const Color _cardBorder = Color(0xFFEBEFF5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 248, 248),
      body: GetBuilder<ProfileController>(builder: (profileController) {
        final profileData = profileController.profileModel?.data;
        final totalRides = profileData?.totalRideCount ?? 0;
        final loyaltyPoints = profileData?.loyaltyPoints ?? 0;
        final walletBalance = profileData?.wallet?.walletBalance ?? 0.0;
        final userRating = profileData?.userRating ?? '5.0';

        return BodyWidget(
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // SCREEN TITLE
                Text(
                  'profile'.tr,
                  style: textBold.copyWith(
                    color: _textDark,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'manage_account_preferences_security'.tr,
                  style: textRegular.copyWith(
                    color: _textSubtle,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 18),

                // USER PROFILE HERO CARD
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Avatar + Details + Edit Button Row
                        Row(
                          children: [
                            // Profile Avatar without harsh blue frame
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
                                borderRadius: BorderRadius.circular(50),
                                child: ImageWidget(
                                  height: 68,
                                  width: 68,
                                  image: _profileImageUrl(
                                    profileData?.profileImage,
                                  ),
                                  placeholder: Images.personPlaceholder,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // User Name, Rating & Level
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profileController.customerName(),
                                    style: textBold.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: _textDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),

                                  // Rating & Level Badges Row
                                  Row(
                                    children: [
                                      // Rating Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF8E1),
                                          borderRadius:
                                              BorderRadius.circular(12),
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

                                      // Level Badge (if enabled)
                                      if (Get.find<ConfigController>()
                                              .config
                                              ?.levelStatus ??
                                          false) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8F6FE),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            profileData?.level?.name ??
                                                'Level 1',
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

                            // Edit Icon Button
                            Material(
                              color: const Color(0xFFF3F5F8),
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () =>
                                    Get.to(() => const EditProfileScreen()),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    Images.editIcon,
                                    width: 18,
                                    height: 18,
                                    color: _primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                        const Divider(height: 1, color: Color(0xFFF0F3F7)),
                        const SizedBox(height: 14),

                        // Stats Summary Capsules Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                title: 'total_ride'.tr,
                                value: '$totalRides',
                                icon: Icons.directions_car_rounded,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 36,
                              color: const Color(0xFFEBEFF5),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                title: 'total_point'.tr,
                                value: '$loyaltyPoints',
                                icon: Icons.stars_rounded,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 36,
                              color: const Color(0xFFEBEFF5),
                            ),
                            Expanded(
                              child: _buildStatItem(
                                title: 'My Wallet'.tr,
                                value: PriceConverter.convertPrice(
                                    walletBalance.toDouble()),
                                icon: Icons.account_balance_wallet_rounded,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // SECTION 1: ACCOUNT & SAFETY
                _buildSectionHeader('account_and_safety'.tr),
                const SizedBox(height: 8),
                _buildGroupedCard([
                  ProfileMenuItem(
                    title: 'profile',
                    subtitle: 'edit_profile_subtitle',
                    icon: Images.profileProfile,
                    onTap: () => Get.to(() => const EditProfileScreen()),
                  ),
                  ProfileMenuItem(
                    title: 'sos',
                    subtitle: 'sos_subtitle',
                    icon: Images.profileHelpSupport,
                    onTap: () => Get.to(() => const SosScreen()),
                  ),
                  ProfileMenuItem(
                    title: 'my_address',
                    subtitle: 'my_address_subtitle',
                    icon: Images.location,
                    divider: false,
                    onTap: () => Get.to(() => const MyAddressScreen()),
                  ),
                ]),

                const SizedBox(height: 20),

                // SECTION 2: ACTIVITY & MESSAGES
                _buildSectionHeader('activity_and_offers'.tr),
                const SizedBox(height: 8),
                _buildGroupedCard([
                  ProfileMenuItem(
                    title: 'messages',
                    subtitle: 'messages_subtitle',
                    icon: Images.profileMessage,
                    onTap: () => Get.to(() => const MessageListScreen()),
                  ),
                  ProfileMenuItem(
                    title: 'my_offers',
                    subtitle: 'my_offers_subtitle',
                    icon: Images.paymentAndVoucher,
                    onTap: () => Get.to(() => MyOfferScreen()),
                  ),
                  ProfileMenuItem(
                    title: 'my_wallet',
                    subtitle: 'my_wallet_subtitle',
                    icon: Images.profileMyWallet,
                    onTap: () => Get.to(() => const WalletScreen()),
                  ),
                  ProfileMenuItem(
                    title: 'my_trips',
                    subtitle: 'my_trips_subtitle',
                    icon: Images.profileMyTrip,
                    divider: (Get.find<ConfigController>()
                                .config
                                ?.referralEarningStatus ??
                            false) ||
                        ((profileData?.wallet?.referralEarn ?? 0) > 0),
                    onTap: () =>
                        Get.to(() => const TripScreen(fromProfile: true)),
                  ),
                  if ((Get.find<ConfigController>()
                              .config
                              ?.referralEarningStatus ??
                          false) ||
                      ((profileData?.wallet?.referralEarn ?? 0) > 0))
                    ProfileMenuItem(
                      title: 'refer_and_earn',
                      subtitle: 'refer_and_earn_subtitle',
                      icon: Images.referralIcon1,
                      divider: false,
                      onTap: () => Get.to(() => const ReferAndEarnScreen()),
                    ),
                ]),

                const SizedBox(height: 20),

                // SECTION 3: PREFERENCES & SUPPORT
                _buildSectionHeader('preferences_and_support'.tr),
                const SizedBox(height: 8),
                _buildGroupedCard([
                  ProfileMenuItem(
                    title: 'help_support',
                    subtitle: 'help_support_subtitle',
                    icon: Images.profileHelpSupport,
                    onTap: () => Get.to(() => const HelpAndSupportScreen()),
                  ),
                  ProfileMenuItem(
                    title: 'settings',
                    subtitle: 'settings_subtitle',
                    icon: Images.profileSetting,
                    onTap: () => Get.to(() => const SettingScreen()),
                  ),
                  ProfileMenuItem(
                    title: 'privacy_policy',
                    icon: Images.privacyPolicyIcon,
                    onTap: () => Get.to(() => PolicyScreen(
                          htmlType: HtmlType.privacyPolicy,
                          image: Get.find<ConfigController>()
                                  .config
                                  ?.privacyPolicy
                                  ?.image ??
                              '',
                        )),
                  ),
                  ProfileMenuItem(
                    title: 'refund_policy',
                    icon: Images.privacyPolicyIcon,
                    onTap: () => Get.to(() => PolicyScreen(
                          htmlType: HtmlType.refundPolicy,
                          image: Get.find<ConfigController>()
                                  .config
                                  ?.refundPolicy
                                  ?.image ??
                              '',
                        )),
                  ),
                  ProfileMenuItem(
                    title: 'terms_and_condition',
                    icon: Images.termsAndCondition,
                    divider: false,
                    onTap: () => Get.to(() => PolicyScreen(
                          htmlType: HtmlType.termsAndConditions,
                          image: Get.find<ConfigController>()
                                  .config
                                  ?.termsAndConditions
                                  ?.image ??
                              '',
                        )),
                  ),
                ]),

                const SizedBox(height: 20),

                // SECTION 4: ACCOUNT ACTIONS
                _buildSectionHeader('account_actions'.tr),
                const SizedBox(height: 8),
                _buildGroupedCard([
                  ProfileMenuItem(
                    title: 'logout',
                    icon: Images.profileLogout,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return GetBuilder<AuthController>(
                              builder: (authController) {
                            return ConfirmationDialogWidget(
                              icon: Images.profileLogout,
                              isLoading: authController.isLoading,
                              description:
                                  'do_you_want_to_log_out_this_account'.tr,
                              onYesPressed: () {
                                Get.find<AuthController>().logOut();
                              },
                            );
                          });
                        },
                      );
                    },
                  ),
                  ProfileMenuItem(
                    title: 'permanently_delete_account',
                    icon: Images.deleteAccountIcon,
                    isDestructive: true,
                    divider: false,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return GetBuilder<AuthController>(
                              builder: (authController) {
                            return ConfirmationDialogWidget(
                              icon: Images.profileLogout,
                              isLoading: authController.isLoading,
                              description:
                                  'are_you_sure_permanent_delete_smg'.tr,
                              onYesPressed: () {
                                Get.find<AuthController>().permanentlyDelete();
                              },
                            );
                          });
                        },
                      );
                    },
                  ),
                ]),

                const SizedBox(height: 120),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
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

  Widget _buildGroupedCard(List<Widget> children) {
    return Container(
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
          children: children,
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: _primaryBlue),
            const SizedBox(width: 4),
            Text(
              value,
              style: textBold.copyWith(
                color: _textDark,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: textMedium.copyWith(
            fontSize: 11,
            color: _textSubtle,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
