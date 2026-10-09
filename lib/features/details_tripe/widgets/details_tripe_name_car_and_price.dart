import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class DetailsTripeNameCarAndPrice extends StatelessWidget {
  const DetailsTripeNameCarAndPrice({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.06 + 5,
      width: size.width * 0.90,
      padding: EdgeInsets.symmetric(horizontal: size.height * 0.02 + 3),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).hintColor.withValues(alpha: 0.2),
            blurRadius: 25,
            spreadRadius: 1,
            offset: const Offset(1, 5),
          )
        ],
        color: Get.isDarkMode
            ? Theme.of(context).primaryColorDark
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
      ),
      child: Row(
        children: [
          Text(
            textDirection: TextDirection.rtl,
            '55 جنيه',
            style: textBold.copyWith(
                fontSize: Dimensions.fontSizeExtraLarge,
                color: Theme.of(context).primaryColorDark),
          ),
          Spacer(),
          Row(
            children: [
              Text(
                'تويوتا كورولا',
                style:
                    textSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              SizedBox(width: size.width * 0.02),
              Image.asset(
                Images.car,
                width: size.width * 0.06,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
