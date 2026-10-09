import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:ride_sharing_user_app/common_widgets/from_to_icon_widget.dart';
import 'package:ride_sharing_user_app/features/details_tripe/widgets/details_tripe_text_from_to_widgets.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class DetailsTripeFromToWidget extends StatelessWidget {
  const DetailsTripeFromToWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.13,
      width: size.width * 0.90,
      padding: EdgeInsets.only(top: size.height * 0.01),
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
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          DetailsTripeTextFromToWidgets(),
          SizedBox(
            width: size.width * 0.02,
          ),
          FromToIconWidget(
            color: Colors.transparent,
          ),
          SizedBox(
            width: size.width * 0.03,
          ),
          Column(
            spacing: size.height * 0.02 + 3,
            children: [
              _defaultTextTime(
                context,
                text: '18:30\nمساءً',
                fontWeight: FontWeight.w500,
              ),
              _defaultTextTime(
                context,
                text: '1:20\nمساءً',
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
          SizedBox(
            width: size.width * 0.08,
          ),
        ],
      ),
    );
  }

  Widget _defaultTextTime(
    BuildContext context, {
    required String text,
    required FontWeight fontWeight,
  }) {
    return Text(
      maxLines: 2,
      textAlign: TextAlign.center,
      text,
      style: textSemiBold.copyWith(
        color: Theme.of(context).primaryColorDark,
        fontSize: 12,
        fontWeight: fontWeight,
      ),
    );
  }
}
