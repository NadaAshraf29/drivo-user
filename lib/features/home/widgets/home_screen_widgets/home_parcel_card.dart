import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/parcel/screens/parcel_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class HomeParcelCard extends StatelessWidget {
  const HomeParcelCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(() => const ParcelScreen()),
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8F3),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFDDF2E4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(Images.parcel, height: 32, width: 32),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'send_a_parcel'.tr,
                    style: textBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'fast_and_reliable_delivery'.tr,
                          style: textRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDF2E4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'from_40_egp'.tr,
                          style: textSemiBold.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: const Color(0xFF1E8E3E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  Images.parcel,
                  height: 48,
                  width: 48,
                ),
                Positioned(
                  right: 0,
                  top: 12,
                  child: Icon(
                    Icons.fast_forward,
                    size: 14,
                    color: Colors.brown[300],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF1E8E3E),
            ),
          ],
        ),
      ),
    );
  }
}
