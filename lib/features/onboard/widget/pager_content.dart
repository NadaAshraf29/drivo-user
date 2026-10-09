import 'package:flutter/material.dart';

class PagerContent extends StatelessWidget {
  const PagerContent({
    super.key,
    required this.image,
    required this.text,
    required this.index,
  });

  final String image;
  final String text;
  final int index;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Center(
        child: Image.asset(
          image,
          width: screenWidth,
          height: screenHeight,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}