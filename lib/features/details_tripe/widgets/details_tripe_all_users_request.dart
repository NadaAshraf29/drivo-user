import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class DetailsTripeAllUsersRequest extends StatelessWidget {
  const DetailsTripeAllUsersRequest({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.90,
      height: size.height * 0.09,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).hintColor.withValues(alpha: 0.2),
            blurRadius: 25,
            spreadRadius: 1,
            offset: const Offset(1, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(
          3,
          (index) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: size.width * 0.09,
                height: size.height * 0.05,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.teal),
              ),
              Text(
                'علي عبدالعزيز',
                style: textRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
