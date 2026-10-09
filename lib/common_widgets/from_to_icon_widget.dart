import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';

class FromToIconWidget extends StatelessWidget {
  final double? heightLine;
  final Color? color;
  final bool? isLeft;
  final double? widthImage;
  final double? heightImage;

  const FromToIconWidget({
    super.key,
    this.heightLine,
    this.color,
    this.isLeft,
    this.widthImage,
    this.heightImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: Dimensions.iconSizeLarge,
        child: Image.asset(
          height: heightImage,
          color: Theme.of(context).primaryColor,
          colorBlendMode: BlendMode.modulate,
          width: widthImage,
          Images.currentLocation,
          // color: Theme.of(context).primaryColor,
        ),
      ),
      SizedBox(
          height: heightLine ?? MediaQuery.of(context).size.height * 0.04,
          width: 10,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0),
            child: VerticalDivider(
                thickness: 2.5,
                color: color ?? Theme.of(context).primaryColorDark),
          )),
      SizedBox(
        width: Dimensions.iconSizeLarge,
        child: Transform.rotate(
          angle: isLeft == true ? 94 : 90,
          child: Image.asset(
              height: heightImage,
              width: widthImage,
              Images.activityDirection,
              color: Theme.of(context).primaryColor
              // color: Theme.of(context).primaryColor,
              ),
        ),
      ),
    ]);
  }
}
