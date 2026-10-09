import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:ride_sharing_user_app/common_widgets/from_to_text_arrow_icon_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class HomeRecentTripsWidget extends StatelessWidget {
  const HomeRecentTripsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Column(
      spacing: size.height * .03,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: size.width * .02,
        ),
        Text(
          'recent_trips'.tr,
          style: _defaultTextStyle(),
        ),
        Column(
          spacing: 18,
          children: List.generate(
            (2),
            (index) {
              return FromToTextArrowIconWidget();
            },
          ),
        )
      ],
    );
  }

  TextStyle _defaultTextStyle() {
    return textRegular.copyWith(
      fontSize: Dimensions.fontSizeDefault,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    );
  }
}
