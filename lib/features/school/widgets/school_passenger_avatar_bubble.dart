import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class SchoolPassengerAvatarBubble extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const SchoolPassengerAvatarBubble({
    super.key,
    required this.text,
    this.backgroundColor = const Color(0xFFFEF3C7),
    this.textColor = const Color(0xFFD97706),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          text,
          style: textBold.copyWith(
            fontSize: 12,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
