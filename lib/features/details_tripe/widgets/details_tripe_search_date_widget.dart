import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class DetailsTripeSearchDateWidget extends StatelessWidget {
  const DetailsTripeSearchDateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          '28 مايو 2025',
          style: textBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
        ),
      ),
    );
  }
}
