import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class ButtonWidget extends StatelessWidget {
  final Function()? onPressed;
  final String buttonText;
  final bool transparent;
  final EdgeInsets margin;
  final double height;
  final double width;
  final double? fontSize;
  final double radius;
  final IconData? icon;
  final bool showBorder;
  final double borderWidth;
  final Color? borderColor;
  final Color? textColor;
  final Color? backgroundColor;
  final bool boldText;
  const ButtonWidget(
      {super.key,
      this.onPressed,
      required this.buttonText,
      this.transparent = false,
      this.margin = EdgeInsets.zero,
      this.width = Dimensions.webMaxWidth,
      this.height = 45,
      this.fontSize,
      this.radius = 5,
      this.icon,
      this.showBorder = false,
      this.borderWidth = 1,
      this.borderColor,
      this.textColor,
      this.backgroundColor,
      this.boldText = true});

  @override
  Widget build(BuildContext context) {
    final Color resolvedBackgroundColor = backgroundColor ??
        (onPressed == null
            ? Theme.of(context).disabledColor
            : transparent
                ? const Color.fromARGB(0, 0, 0, 0)
                : const Color(0xCC06AAF2));

    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
        backgroundColor: showBorder ? const Color.fromARGB(255, 255, 255, 255) : resolvedBackgroundColor,
        minimumSize: Size(width, height),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: showBorder
                ? BorderSide(
                    color: borderColor ?? const Color(0xFF06AAF2),
                    width: borderWidth)
                : const BorderSide(color: Color.fromARGB(0, 0, 0, 0))));

    return Center(
        child: SizedBox(
            width: width,
            child: Padding(
              padding: margin,
              child: TextButton(
                onPressed: onPressed,
                style: flatButtonStyle,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  icon != null
                      ? Padding(
                          padding: const EdgeInsets.only(
                              right: Dimensions.paddingSizeExtraSmall),
                          child: Icon(icon,
                              color: transparent
                                  ? Theme.of(context).primaryColor
                                  : Colors.white))
                      : const SizedBox(),
                  Text(buttonText,
                      textAlign: TextAlign.center,
                      style: boldText
                          ? textBold.copyWith(
                              color: textColor ??
                                  (showBorder
                                      ? Colors.white
                                      : transparent
                                          ? Theme.of(context).primaryColor
                                          : Colors.white),
                              fontSize: fontSize ?? Dimensions.fontSizeDefault,
                            )
                          : textRegular.copyWith(
                              color: textColor ??
                                  (showBorder
                                      ? Colors.white
                                      : transparent
                                          ? Theme.of(context).primaryColor
                                          : Colors.white),
                              fontSize: fontSize ?? Dimensions.fontSizeLarge)),
                ]),
              ),
            )));
  }
}
