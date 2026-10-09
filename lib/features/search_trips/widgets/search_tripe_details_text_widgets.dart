import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SearchTripeDetailsTextWidgets extends StatelessWidget {
  const SearchTripeDetailsTextWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('تفاصيل الرحلة',
        style: textBold.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          color: Theme.of(context).textTheme.bodyMedium!.color,
        ));
  }
}
