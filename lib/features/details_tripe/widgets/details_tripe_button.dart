import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/image_title_subtitle.dart';

class DetailsTripeButton extends StatelessWidget {
  const DetailsTripeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ButtonWidget(
        buttonText: 'حجز',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageTitleSubTitle(
                title: 'تم ارسال طلب حجز الرحلة!',
                subTitle: 'تم ارسال طلب حجز الرحلة الي السائق وفي\n انتظار رده',
              ),
            ),
          );
        },
        fontSize: 20,
      ),
    );
  }
}
