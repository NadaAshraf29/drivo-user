import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SearchTripeNameCarNadIconWidget extends StatelessWidget {
  const SearchTripeNameCarNadIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 6.5,
      children: [
        Text(
          'تويوتا كورولا',
          style: textSemiBold.copyWith(
            color: Theme.of(context).primaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        Image.asset(
          Images.car,
          width: size.width * 0.06,
        ),
      ],
    );
  }
}
