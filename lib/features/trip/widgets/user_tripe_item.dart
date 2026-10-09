import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

import '../../../common_widgets/from_to_icon_widget.dart';

List<String> _stateTrip = [
  'قيد المراجعة',
  'مقبولة',
  'مرفوضة',
];

class UserTripeItem extends StatelessWidget {
  final int index;

  const UserTripeItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
      child: Container(
        // width: size.width,
        height: size.height * 0.17 + 8,
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
                    _dateAndTime(context),
                  ],
                ),
                Row(
                  spacing: size.width * 0.03,
                  children: [
                    Image.asset(
                      Images.carTripeIcon,
                      width: size.width * 0.05 - 2,
                    ),
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
                    // _statTripeText
                    // (context),
                  ],
                ),
              ],
            ),
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
        Text(
          _stateTrip[index],
          style: textBold.copyWith(
            color: _stateColor(context),
          ),
        ),
      ],
    );
  }

  Color _stateColor(BuildContext context) {
    if (_stateTrip[index] == 'قيد المراجعة') {
      return Theme.of(context).hintColor;
    } else if (_stateTrip[index] == 'مقبولة') {
      return Theme.of(context).colorScheme.primary;
    } else if (_stateTrip[index] == 'مرفوضة') {
      return Theme.of(context).colorScheme.error;
    } else {
      return Colors.transparent;
    }
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
