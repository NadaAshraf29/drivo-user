import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_pop_scope_widget.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/refer_and_earn/controllers/refer_and_earn_controller.dart';
import 'package:ride_sharing_user_app/features/refer_and_earn/screens/referral_details_screen.dart';
import 'package:ride_sharing_user_app/features/refer_and_earn/screens/referral_earning_screen.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  static const Color _primaryBlue = Color(0xFF00A3EC);
  static const Color _textDark = Color(0xFF1E2432);
  static const Color _textSubtle = Color(0xFF8C94A3);
  static const Color _cardBorder = Color(0xFFEBEFF5);

  @override
  void initState() {
    Get.find<ReferAndEarnController>().getEarningHistoryList(1);
    Get.find<ReferAndEarnController>().getReferralDetails();
    Get.find<ProfileController>().getProfileInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 246, 248, 248),
        resizeToAvoidBottomInset: false,
        body: GetBuilder<ReferAndEarnController>(
          builder: (referAndEarnController) {
            return BodyWidget(
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Column(
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
                                'refer_and_earn'.tr,
                                style: textBold.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark,
                                ),
                              ),
                              Text(
                                'Invite friends and earn rewards'.tr,
                                style: textRegular.copyWith(
                                  fontSize: 12,
                                  color: _textSubtle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Segmented Tab Selector
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _cardBorder),
                        ),
                        child: Row(
                          children: List.generate(
                            referAndEarnController.referAndEarnType.length,
                            (index) {
                              final isSelected =
                                  referAndEarnController.currentTabIndex ==
                                      index;
                              return Expanded(
                                child: InkWell(
                                  onTap: () {
                                    referAndEarnController
                                        .updateCurrentTabIndex(index);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? _primaryBlue
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      referAndEarnController
                                          .referAndEarnType[index].tr,
                                      style: textSemiBold.copyWith(
                                        color: isSelected
                                            ? Colors.white
                                            : _textSubtle,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tab View Content
                      Expanded(
                        child: referAndEarnController.currentTabIndex == 0
                            ? const ReferralDetailsScreen()
                            : const ReferralEarningScreen(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
