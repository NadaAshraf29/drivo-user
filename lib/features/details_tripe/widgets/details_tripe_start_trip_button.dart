import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class DetailsTripeStartTripButton extends StatelessWidget {
  const DetailsTripeStartTripButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        spacing: MediaQuery.of(context).size.height * 0.01,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ButtonWidget(
            buttonText: ' بدأ الرحلة',
            onPressed: () {},
            fontSize: 20,
          ),
          Text(
            'هذا النص يمكن استبداله',
            style: textRegular.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontSize: Dimensions.fontSizeDefault),
          )
        ],
      ),
    );
  }
}
