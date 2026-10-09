import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import '../../../common_widgets/from_to_icon_widget.dart';

class SearchTripsFromToAndTextWidgets extends StatelessWidget {
  const SearchTripsFromToAndTextWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FromToIconWidget(),
          SizedBox(width: size.height * 0.013),
          Column(
            spacing: size.height * 0.02 + 3,
            children: [
              _defaultTextTime(
                context,
                text: '18:30\nمساءً',
                fontWeight: FontWeight.w500,
              ),
              _defaultTextTime(
                context,
                text: '1:20\nمساءً',
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
        ]);
  }

  Widget _defaultTextTime(
    BuildContext context, {
    required String text,
    required FontWeight fontWeight,
  }) {
    return Text(
      maxLines: 2,
      textAlign: TextAlign.center,
      text,
      style: textSemiBold.copyWith(
        color: Theme.of(context).primaryColor,
        fontSize: 12,
        fontWeight: fontWeight,
      ),
    );
  }
}
