import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SearchTripsTextFromToWidgets extends StatelessWidget {
  const SearchTripsTextFromToWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.4 + 3,
      child: Column(
        spacing: size.height * 0.01,
        children: [
          _defaultText(
            text: 'القاهرة مصر الجديدة امام مجمع المحاكم',
            fontSize: Dimensions.fontSizeDefault,
            context: context,
          ),
          _defaultText(
            text: 'الاسكندرية محطة الرمل ميدان السلطان حسين',
            fontSize: Dimensions.fontSizeDefault,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _defaultText({
    required String text,
    Color? color,
    required double fontSize,
    required BuildContext context,
  }) {
    return Text(text,
        maxLines: 2,
        textAlign: TextAlign.end,
        style: textSemiBold.copyWith(
          color: color ?? Theme.of(context).textTheme.bodyMedium!.color!,
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
        ));
  }
}
