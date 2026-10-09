import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:ride_sharing_user_app/features/details_tripe/screens/details_trips_screen.dart';
import 'package:ride_sharing_user_app/features/search_trips/widgets/search_tripe_details_widget.dart';
import 'package:ride_sharing_user_app/features/search_trips/widgets/search_tripe_name_and_price_widget.dart';
import 'package:ride_sharing_user_app/features/search_trips/widgets/search_tripe_name_car_nad_icon_widget.dart';
import 'package:ride_sharing_user_app/features/search_trips/widgets/search_trips_from_to_and_time_widgets.dart';
import 'package:ride_sharing_user_app/features/search_trips/widgets/search_trips_text_from_to_widgets.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';

class SearchTripeItemWidget extends StatelessWidget {
  const SearchTripeItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => DetailsTripScreen(
                      isMyTrip: false,
                    )));
      },
      child: Container(
          height: size.height * 0.3 - 25,
          width: size.width * 0.90,
          margin: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeExtraLarge,
          ),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 25,
                spreadRadius: 0,
                offset: const Offset(15, 0),
              )
            ],
            color: Get.isDarkMode
                ? Theme.of(context).primaryColorDark
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SearchTripeNameAndPriceWidget(),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SearchTripsTextFromToWidgets(),
                  SizedBox(width: size.height * 0.01),
                  SearchTripsFromToAndTextWidgets(),
                ],
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              SearchTripeNameCarNadIconWidget(),
              SizedBox(height: size.height * 0.01),
              SearchTripeDetailsWidget(),
            ],
          )),
    );
  }
}
