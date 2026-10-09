import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_pop_scope_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/paginated_list_widget.dart';
import 'package:ride_sharing_user_app/features/coupon/controllers/coupon_controller.dart';
import 'package:ride_sharing_user_app/features/coupon/widget/offer_coupon_card_widget.dart';
import 'package:ride_sharing_user_app/features/my_offer/controller/offer_controller.dart';
import 'package:ride_sharing_user_app/features/my_offer/screens/discount_screen.dart';
import 'package:ride_sharing_user_app/features/my_offer/widgets/discount_cart_widget.dart';
import 'package:ride_sharing_user_app/features/my_offer/widgets/no_coupon_widget.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

// ignore: must_be_immutable
class MyOfferScreen extends StatefulWidget {
  bool isCoupon;
  MyOfferScreen({super.key, this.isCoupon = false});

  @override
  State<MyOfferScreen> createState() => _MyOfferScreenState();
}

class _MyOfferScreenState extends State<MyOfferScreen> {
  static const Color _primaryBlue = Color(0xFF00A3EC);
  static const Color _textDark = Color(0xFF1E2432);
  static const Color _textSubtle = Color(0xFF8C94A3);
  static const Color _cardBorder = Color(0xFFEBEFF5);

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    if (Get.find<OfferController>().bestOfferModel == null) {
      Get.find<OfferController>().getOfferList(1);
    }
    if (Get.find<CouponController>().couponModel == null) {
      Get.find<CouponController>().getCouponList(1, isUpdate: false);
    }
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _showInfoBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'we_do_the_best_for_you'.tr,
              style: textBold.copyWith(
                fontSize: 18,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'if_you_have_multiple_eligible_discounts_we_will_automatically_apply_the_discount_that_will_save_you_the_most_to_your_next_trip'
                  .tr,
              style: textRegular.copyWith(
                color: _textSubtle,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 246, 248, 248),
        body: BodyWidget(
          body: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Offers'.tr,
                              style: textBold.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: _textDark,
                              ),
                            ),
                            Text(
                              'Discounts and promo codes'.tr,
                              style: textRegular.copyWith(
                                fontSize: 12,
                                color: _textSubtle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: _showInfoBottomSheet,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _cardBorder),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.info_outline_rounded,
                              size: 20,
                              color: _primaryBlue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Segmented Filter Bar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                widget.isCoupon = false;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !widget.isCoupon
                                    ? _primaryBlue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'discounts'.tr,
                                style: textSemiBold.copyWith(
                                  color: !widget.isCoupon
                                      ? Colors.white
                                      : _textSubtle,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                widget.isCoupon = true;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: widget.isCoupon
                                    ? _primaryBlue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'coupons'.tr,
                                style: textSemiBold.copyWith(
                                  color: widget.isCoupon
                                      ? Colors.white
                                      : _textSubtle,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Content List
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          if (!widget.isCoupon)
                            GetBuilder<OfferController>(
                              builder: (offerController) {
                                if (offerController.bestOfferModel?.data !=
                                        null &&
                                    offerController
                                        .bestOfferModel!.data!.isNotEmpty) {
                                  return PaginatedListWidget(
                                    scrollController: scrollController,
                                    onPaginate: (int? offset) async {
                                      await offerController
                                          .getOfferList(offset!);
                                    },
                                    totalSize: offerController
                                        .bestOfferModel?.totalSize,
                                    offset: int.tryParse(offerController
                                            .bestOfferModel!.offset
                                            .toString()) ??
                                        1,
                                    itemView: ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      itemCount: offerController
                                          .bestOfferModel!.data!.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            Get.to(() => DiscountScreen(
                                                  offerModel: offerController
                                                      .bestOfferModel!
                                                      .data![index],
                                                ));
                                          },
                                          child: DiscountCartWidget(
                                            offerModel: offerController
                                                .bestOfferModel!.data![index],
                                          ),
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 12),
                                    ),
                                  );
                                }
                                return NoCouponWidget(
                                  title: 'no_discount_found'.tr,
                                  description: 'sorry_there_is_no_discount'.tr,
                                );
                              },
                            )
                          else
                            GetBuilder<CouponController>(
                              builder: (couponController) {
                                if (couponController.couponModel?.data !=
                                        null &&
                                    couponController
                                        .couponModel!.data!.isNotEmpty) {
                                  return PaginatedListWidget(
                                    scrollController: scrollController,
                                    onPaginate: (int? offset) async {
                                      await couponController
                                          .getCouponList(offset!);
                                    },
                                    totalSize: couponController
                                        .couponModel?.totalSize,
                                    offset: int.tryParse(couponController
                                            .couponModel!.offset
                                            .toString()) ??
                                        1,
                                    itemView: ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      itemCount: couponController
                                          .couponModel!.data!.length,
                                      itemBuilder: (context, index) {
                                        return OfferCouponCardWidget(
                                          fromCouponScree: true,
                                          coupon: couponController
                                              .couponModel!.data![index],
                                          index: index,
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 12),
                                    ),
                                  );
                                }
                                return NoCouponWidget(
                                  title: 'no_coupon_available'.tr,
                                  description: 'sorry_there_is_no_coupon'.tr,
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
