import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class FromToTextArrowIconWidget extends StatelessWidget {
  final double? width;
  final bool? isShowArrowButton;
  const FromToTextArrowIconWidget(
      {super.key, this.width, this.isShowArrowButton = true});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: width ?? size.width * 0.8,
        height: size.height * .07 - 5,
        padding:
            EdgeInsets.only(left: size.width * 0.08, right: size.width * 0.04),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(1, 2),
            )
          ],
        ),
        child: Row(
          children: [
            isShowArrowButton == true
                ? Image.asset(
                    Images.arrowLeft2Icon,
                    color: Theme.of(context).primaryColor,
                    height: size.height * 0.02,
                    width: size.width * 0.02,
                  )
                : SizedBox(),
            Spacer(),
            Text(
              'سموحة',
              style: _defaultTextStyle(),
            ),
            SizedBox(
              width: size.width * .02,
            ),
            Image.asset(
              Images.arrowLeft1Icon,
              height: size.height * 0.06,
              width: size.width * 0.06,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(
              width: size.width * .01,
            ),
            Text(
              'مصر الجديدة',
              style: _defaultTextStyle(),
            ),
            SizedBox(
              width: size.width * 0.01,
            ),
            Image.asset(
              Images.clockIcon,
              color: Theme.of(context).primaryColor,
              height: size.height * 0.06,
              width: size.width * 0.06,
            ),
          ],
        ),
      ),
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
