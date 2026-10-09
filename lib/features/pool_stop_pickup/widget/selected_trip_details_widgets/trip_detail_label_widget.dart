import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class TripDetailLabelWidget extends StatelessWidget {
  final String text;

  const TripDetailLabelWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: textBold.copyWith(
        fontSize: 11,
        color: const Color(0xFF94A3B8),
        letterSpacing: 0.5,
      ),
    );
  }
}
