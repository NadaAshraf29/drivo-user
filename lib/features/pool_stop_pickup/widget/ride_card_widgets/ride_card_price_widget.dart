import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class RideCardPriceWidget extends StatelessWidget {
  final int price;

  const RideCardPriceWidget({
    super.key,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$price',
          style: textBold.copyWith(
            fontSize: 16,
            color: const Color(0xFF078ECC),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'egp'.tr,
          style: textBold.copyWith(
            fontSize: 10,
            color: const Color(0xFF078ECC),
          ),
        ),
      ],
    );
  }
}
