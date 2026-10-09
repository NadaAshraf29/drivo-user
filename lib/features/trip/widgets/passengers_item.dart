import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class PassengersItem extends StatelessWidget {
  const PassengersItem({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      // width: s,
      height: size.height * 0.08,
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).hintColor.withValues(alpha: 0.1),
            blurRadius: 25,
            spreadRadius: 1,
            offset: const Offset(1, 5),
          )
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
        child: Row(
          children: [
            Container(
              width: size.width * 0.09,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.teal,
              ),
            ),
            SizedBox(
              width: size.width * 0.03,
            ),
            Text(
              'علي عبدالعزيز',
              style: textBold.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontSize: Dimensions.fontSizeDefault + 1),
            ),
            Spacer(),
            Image.asset(
              Images.trashIcon,
              width: size.width * 0.05,
            ),
          ],
        ),
      ),
    );
  }
}
