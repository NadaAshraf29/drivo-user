import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/splash/screens/splash_screen.dart';

class RouteHelper {
  static const String splash = '/splash';
  static getSplashRoute({Map<String,dynamic>? notificationData}) {
    notificationData?.remove('body');
    String userName = (notificationData?['user_name'] ?? '').replaceAll('&','a');
    notificationData?.remove('user_name');

    return '$splash?notification=${jsonEncode(notificationData)}&userName=$userName';
  }
  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () {
        print("ROUTE_HELPER: building SplashScreen page route");
        Map<String, dynamic>? notifData;
        try {
          final notifParam = Get.parameters['notification'];
          if (notifParam != null && notifParam != 'null' && notifParam.isNotEmpty) {
            notifData = jsonDecode(notifParam);
          }
        } catch (e) {
          print("ROUTE_HELPER: error parsing notification parameter: $e");
        }
        return SplashScreen(
          notificationData: notifData,
          userName: Get.parameters['userName']?.replaceAll('a', '&'),
        );
      },
    ),
  ];

  static goPageAndHideTextField(BuildContext context, Widget page){
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    currentFocus.requestFocus(FocusNode());
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    Future.delayed(const Duration(milliseconds: 300)).then((_){
      Get.to(() => page);

    });

  }

}