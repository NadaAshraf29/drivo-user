import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SearchTripeNameAndPriceWidget extends StatelessWidget {
  const SearchTripeNameAndPriceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Row(
      children: [
        Text('55 جنيه',
            textDirection: TextDirection.rtl,
            style: textSemiBold.copyWith(
              color: Theme.of(context).textTheme.bodyMedium!.color!,
              fontSize: Dimensions.fontSizeExtraLarge,
              fontWeight: FontWeight.w700,
            )),
        Spacer(),
        Text('علي عبدالعزيز',
            style: textSemiBold.copyWith(
              color: Theme.of(context).textTheme.bodyMedium!.color!,
              fontSize: Dimensions.fontSizeSmall,
              fontWeight: FontWeight.w400,
            )),
        SizedBox(
          width: size.width * 0.02,
        ),
        Padding(
          padding: EdgeInsets.only(right: size.width * 0.01 + 2),
          child: Container(
            width: size.width * 0.07,
            height: size.height * 0.07,
            decoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
                image: DecorationImage(image: AssetImage(Images.userIcon))),
          ),
        ),
      ],
    );
  }
}
