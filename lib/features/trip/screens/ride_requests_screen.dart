import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/features/trip/widgets/ride_request_view.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class RideRequestsScreen extends StatelessWidget {
  const RideRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BodyWidget(
          appBar: AppBarWidget(title: ''),
          body: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  'ride_requests'.tr,
                  style: textBold.copyWith(fontSize: 20),
                ),
                Expanded(child: RideRequestView()),
              ],
            ),
          )),
    );
  }
}
