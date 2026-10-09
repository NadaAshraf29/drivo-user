import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/wallet/widget/point_to_wallet_money_widget.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/price_converter.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/wallet/controllers/wallet_controller.dart';

class WalletMoneyAmountWidget extends StatelessWidget {
  final bool walletMoney;
  const WalletMoneyAmountWidget({super.key, this.walletMoney = false});

  static const Color _primaryBlue = Color(0xFF00A3EC);
  static const Color _textDark = Color(0xFF1E2432);
  static const Color _textSubtle = Color(0xFF8C94A3);
  static const Color _cardBorder = Color(0xFFEBEFF5);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(builder: (walletController) {
      return GetBuilder<ProfileController>(
        initState: (context) {
          Get.find<ProfileController>().getProfileInfo();
        },
        builder: (profileController) {
          final balance =
              profileController.profileModel?.data?.wallet?.walletBalance ?? 0.0;
          final points =
              profileController.profileModel?.data?.loyaltyPoints ?? '0';

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  if (!walletMoney) {
                    if (Get.find<ConfigController>().config?.conversionStatus ??
                        false) {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) => const PointToWalletMoneyWidget(),
                      );
                    } else {
                      showCustomSnackBar(
                        'point_conversion_is_currently_unavailable'.tr,
                      );
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Icon Capsule
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: walletMoney
                              ? const Color(0xFFE8F6FE)
                              : const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          walletMoney
                              ? Icons.account_balance_wallet_rounded
                              : Icons.stars_rounded,
                          color: walletMoney
                              ? _primaryBlue
                              : const Color(0xFFFFB300),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Text Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              walletMoney
                                  ? 'Wallet Balance'.tr
                                  : 'Loyalty Points'.tr,
                              style: textMedium.copyWith(
                                fontSize: 13,
                                color: _textSubtle,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              walletMoney
                                  ? PriceConverter.convertPrice(
                                      balance.toDouble())
                                  : points.toString(),
                              style: textBold.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (!walletMoney)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F6FE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Convert'.tr,
                                style: textSemiBold.copyWith(
                                  color: _primaryBlue,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: _primaryBlue,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
