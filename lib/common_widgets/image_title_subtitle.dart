import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/features/home/screens/home_screen.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class ImageTitleSubTitle extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final dynamic Function()? onPressed;

  const ImageTitleSubTitle(
      {super.key, this.title, this.subTitle, this.onPressed});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: Theme.of(context).cardColor,
      // appBar:

      body: BodyWidget(
        // appBar:  ,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  Images.cityDriverIcon,
                  width: size.width * 0.5,
                ),
              ),
              SizedBox(height: size.height * 0.01 + 5),
              Column(
                children: [
                  Text(
                    textDirection: TextDirection.rtl,
                    title ?? '',
                    style: textBold.copyWith(
                        color: Theme.of(context).textTheme.labelLarge!.color,
                        fontSize: 20),
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    subTitle ?? '',
                    style: textMedium.copyWith(
                        color: Theme.of(context).textTheme.bodySmall!.color,
                        fontSize: 16),
                  ),
                ],
              ),
              SizedBox(
                height: size.height * 0.05,
              ),
              ButtonWidget(
                buttonText: 'موافق',
                fontSize: 20,
                onPressed: onPressed ??
                    () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => HomeScreen()));
                    },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
