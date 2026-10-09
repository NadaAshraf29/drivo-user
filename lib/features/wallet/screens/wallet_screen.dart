import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_pop_scope_widget.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/wallet/controllers/wallet_controller.dart';
import 'package:ride_sharing_user_app/features/wallet/screens/loyality_point_screen.dart';
import 'package:ride_sharing_user_app/features/wallet/widget/animated_expanded_fab_button.dart';
import 'package:ride_sharing_user_app/features/wallet/widget/animated_fab_button.dart';
import 'package:ride_sharing_user_app/features/wallet/widget/wallet_money_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  static const Color _primaryBlue = Color(0xFF00A3EC);
  static const Color _textDark = Color(0xFF1E2432);
  static const Color _textSubtle = Color(0xFF8C94A3);
  static const Color _cardBorder = Color(0xFFEBEFF5);

  bool _isExpandBafButton = true;

  @override
  void initState() {
    super.initState();
    Get.find<WalletController>().getTransactionList(1);
    Get.find<WalletController>().getLoyaltyPointList(1);
    Get.find<ProfileController>().getProfileInfo();
    Get.find<WalletController>().scrollController.addListener(() {
      if (Get.find<WalletController>().scrollController.offset > 20) {
        if (_isExpandBafButton) {
          setState(() {
            _isExpandBafButton = false;
          });
        }
      } else {
        if (!_isExpandBafButton) {
          setState(() {
            _isExpandBafButton = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _primaryBlue,
      onRefresh: () async {
        Get.find<ProfileController>().getProfileInfo();
      },
      child: CustomPopScopeWidget(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 246, 248, 248),
          resizeToAvoidBottomInset: false,
          body: GetBuilder<WalletController>(builder: (walletController) {
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
                                'My Wallet'.tr,
                                style: textBold.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark,
                                ),
                              ),
                              Text(
                                'Manage funds and transaction history'.tr,
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
                            walletController.walletType.length,
                            (index) {
                              final isSelected =
                                  walletController.currentTabIndex == index;
                              return Expanded(
                                child: InkWell(
                                  onTap: () {
                                    walletController
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
                                      walletController.walletType[index].tr,
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

                      // Content View
                      Expanded(
                        child: walletController.currentTabIndex == 0
                            ? const WalletMoneyScreen()
                            : const LoyaltyPointScreen(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          floatingActionButton:
              GetBuilder<WalletController>(builder: (walletController) {
            return (((Get.find<ConfigController>().config?.externalSystem ??
                            false) &&
                        Get.find<AuthController>().isLoggedIn()) &&
                    walletController.currentTabIndex == 0)
                ? _isExpandBafButton
                    ? AnimatedExpandedFabButton()
                    : AnimatedFabButton()
                : const SizedBox();
          }),
        ),
      ),
    );
  }
}
