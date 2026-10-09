import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/from_to_icon_widget.dart';
import 'package:ride_sharing_user_app/features/details_tripe/screens/details_trips_screen.dart';
import 'package:ride_sharing_user_app/features/trip/screens/tripe_passengers_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class RideRequestItem extends StatelessWidget {
  const RideRequestItem({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
      child: Container(
        // width: size.width,
        height: size.height * 0.23,
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).hintColor.withValues(alpha: 0.1),
              blurRadius: 25,
              spreadRadius: 1,
              offset: const Offset(1, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FromToIconWidget(
                      widthImage: size.width * 0.100,
                      heightLine: size.height * 0.03,
                      isLeft: true,
                      color: Theme.of(context).primaryColor,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _defaultText(context, 'مصر الجديدة، القاهرة'),
                        SizedBox(
                          height: size.height * 0.04,
                        ),
                        _defaultText(context, 'مصر الجديدة، القاهرة'),
                      ],
                    ),
                    SizedBox(width: size.width * 0.16),
                    SizedBox(
                      height: size.height * 0.1 + 9,
                      child: Expanded(
                        child: VerticalDivider(
                          color: Theme.of(context).primaryColor,
                          thickness: 2.1,
                          // indent: 1,
                          // endIndent: 10,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.02,
                    ),
                    _priceAndSeat(context),
                  ],
                ),
                Row(
                  spacing: size.width * 0.04,
                  children: [
                    Container(
                      width: size.width * 0.08,
                      height: size.height * 0.04,
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage(Images.userIcon),
                            fit: BoxFit.cover),
                      ),
                    ),
                    _defaultText(context, 'علي عبدالعزيز'),
                    // SizedBox(width: size.width * 0.08,),
                    // _statTripeText(context),
                  ],
                ),
                Row(
                  spacing: size.width * 0.04,
                  children: [
                    _defaultButton(context,
                        text: "قبول",
                        color: Theme.of(context).colorScheme.primary,
                        onTap: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (_)=>TripePassengersScreen()));
                    }),
                    _defaultButton(context,
                        text: "رفض",
                        color: Theme.of(context).colorScheme.error, onTap: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (_)=>DetailsTripScreen(
                      //   isMyTrip: false,isEndTrip: true,
                      // )));
                    }),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultButton(
    BuildContext context, {
    required Color color,
    required String text,
    required VoidCallback onTap,
  }) {
    var size = MediaQuery.of(context).size;

    return ButtonWidget(
        buttonText: text,
        radius: 50,
        width: size.width * 0.35,
        height: size.height * 0.04,
        backgroundColor: color,
        onPressed: onTap);
  }

  Widget _priceAndSeat(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Column(
      spacing: size.height * 0.01 - 3,
      children: [
        SizedBox(
          height: size.height * 0.01,
        ),
        Image.asset(Images.user1Icon, width: size.width * 0.05),
        _defaultText(context, '1 مقعد'),
        Image.asset(Images.coinIcon, width: size.width * 0.05),
        _defaultText(context, '55 جنيه'),
      ],
    );
  }

  Widget _defaultText(BuildContext context, String text, {Color? color}) {
    return Text(
      // textDirection: TextDirection.ltr,
      text,
      style: textBold.copyWith(
        color: color ?? Theme.of(context).textTheme.bodyMedium!.color,
        fontSize: Dimensions.fontSizeDefault,
      ),
    );
  }
}
