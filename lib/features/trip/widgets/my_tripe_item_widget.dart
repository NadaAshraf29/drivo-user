import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:ride_sharing_user_app/common_widgets/from_to_icon_widget.dart';
import 'package:ride_sharing_user_app/features/details_tripe/screens/details_trips_screen.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class MyTripeItemWidget extends StatelessWidget {
  const MyTripeItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => DetailsTripScreen(
                      isMyTrip: true,
                    )));
      },
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: size.width * 0.03, vertical: 10),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              width: size.width,
              height: size.height * 0.15 - 3,
              padding: EdgeInsets.symmetric(
                  horizontal: size.height * 0.01, vertical: size.height * 0.01),
              alignment: Alignment.topRight,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: 0,
                    offset: const Offset(1, 5),
                  )
                ],
                color: Get.isDarkMode
                    ? Theme.of(context).primaryColorDark
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                spacing: size.width * 0.01,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: size.height * 0.01 - 8,
                      ),
                      Row(
                        children: [
                          FromToIconWidget(
                            widthImage: size.width * 0.10,
                            heightImage: size.height * 0.02,
                            heightLine: size.height * 0.03,
                            isLeft: true,
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _defaultText(context, 'مصر الجديدة، القاهرة'),
                              SizedBox(
                                height: size.height * 0.03,
                              ),
                              _defaultText(context, 'مصر الجديدة، القاهرة'),
                            ],
                          ),
                          SizedBox(
                            width: size.width * 0.08,
                          ),
                          SizedBox(
                            height: size.height * 0.1 + 2,
                            child: Expanded(
                              child: VerticalDivider(
                                color: Theme.of(context).primaryColor,
                                thickness: 2.1,
                                // indent: 1,
                                // endIndent: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // SizedBox(
                      //   height: size.height * 0.01 + 5,
                      // ),
                      Row(
                        children: [
                          Image.asset(
                            Images.carTripeIcon,
                            width: size.width * 0.05 - 2,
                          ),
                          SizedBox(
                            width: size.width * 0.06 - 5,
                          ),
                          _defaultText(context, 'تويتا كورولا',
                              color: Theme.of(context).primaryColor),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    width: size.width * 0.00,
                  ),
                  _dateAndTime(context),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  right: size.width * 0.02, left: size.width * 0.02, top: 8),
              child: Align(
                alignment: AlignmentDirectional.topEnd,
                child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    radius: size.width * 0.03 - 2,
                    child: Center(
                      child: Text(
                        '3',
                        style: textBold.copyWith(
                          color: Theme.of(context).cardColor,
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _dateAndTime(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Column(
      spacing: size.height * 0.01 - 3,
      children: [
        Image.asset(Images.clockIcon, width: size.width * 0.05),
        _defaultText(context, '9:00 AM'),
        Image.asset(Images.calender2Icon, width: size.width * 0.05),
        _defaultText(context, '27 مايو 2025'),
      ],
    );
  }

  Widget _defaultText(BuildContext context, String text, {Color? color}) {
    return Text(
      textDirection: TextDirection.ltr,
      text,
      style: textBold.copyWith(
        color: color ?? Theme.of(context).textTheme.bodyMedium!.color,
        fontSize: Dimensions.fontSizeDefault,
      ),
    );
  }
}
