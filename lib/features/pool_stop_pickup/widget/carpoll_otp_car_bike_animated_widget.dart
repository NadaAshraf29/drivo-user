import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/pool_stop_pickup/controller/carpoll_ride_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';

class CarPollOtpCarBikeAnimatedWidget extends StatelessWidget {
  const CarPollOtpCarBikeAnimatedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CarPollRideController>(builder: (rideController) {
      return Container(
        height: 100,
        width: 100,
        child: SvgPicture.asset((Get.find<CarPollRideController>()
                        .tripDetails
                        ?.vehicleCategory
                        ?.type ??
                    'car') ==
                'car'
            ? Images.animatedCar
            : Images.animatedBike),
      );
    });
  }
}
