import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/passengers_item.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/passengers_view.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TripePassengersScreen extends StatelessWidget {
  const TripePassengersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BodyWidget(
        appBar: AppBarWidget(title: ''),
        body: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                'passengers'.tr,
                style: textBold.copyWith(fontSize: 20),
              ),
              Expanded(child: PassengersView()),
            ],
          ),
        ),
      ),
    );
  }
}
