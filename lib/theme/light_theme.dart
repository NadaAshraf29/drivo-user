import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';

ThemeData lightTheme = ThemeData(
  iconTheme: const IconThemeData(
    color: Color(0xFF211F20),
  ),
  fontFamily: AppConstants.fontFamily,
  primaryColor: const Color(0xff211F20),
  primaryColorDark: const Color.fromARGB(255, 94, 94, 94),
  disabledColor: const Color(0xFFBABFC4),
  scaffoldBackgroundColor: const Color(0xFFF8FAFC),
  shadowColor: Colors.black.withValues(alpha: 0.03),
  buttonTheme: ButtonThemeData(
      colorScheme: ColorScheme.light(
        primary: Color(0xff211F20),
        //  secondary: Color(0xFF008C7B),
        error: Color(0xFFFF6767),
        surface: Color(0xFFF3F3F3),
        tertiary: Color(0xFF7CCD8B),
        tertiaryContainer: Color(0xFFC98B3E),
        secondaryContainer: Color(0xFFEE6464),
        onTertiary: Color(0xFFD9D9D9),
        onSecondary: Color(0xFF00FEE1),
        onSecondaryContainer: Color(0xFFA8C5C1),
        onTertiaryContainer: Color(0xFF425956),
        outline: Color.fromARGB(255, 100, 100, 100),
        onPrimaryContainer: Color(0xFFDEFFFB),
        primaryContainer: Color(0xFFFFA800),
        onErrorContainer: Color(0xFFFFE6AD),
        onPrimary: Color.fromARGB(255, 0, 0, 0),
        surfaceTint: Color.fromARGB(255, 209, 209, 209),
        errorContainer: Color(0xFFF6F6F6),
        inverseSurface: Color(0xFF0148AF),
        surfaceContainer: Color(0xFF0094FF),
        secondaryFixedDim: Color.fromARGB(255, 241, 243, 243),
        scrim: Colors.black,
        secondary: Color.fromARGB(255, 255, 255, 255),
      ),
      buttonColor: Color(0xFF242424)),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Color(0xff1D2D2B)),
    bodySmall: TextStyle(color: Color(0xff6B7675)),
    bodyLarge: TextStyle(color: Color(0xff48615E)),
    titleMedium: TextStyle(color: Color(0xff1D2D2B)),
  ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
  brightness: Brightness.light,
  hintColor: const Color(0xFF9F9F9F),
  cardColor: Colors.white,
  colorScheme: const ColorScheme.light(
    primary: Color.fromARGB(255, 170, 170, 170),
    //  secondary: Color(0xFF008C7B),
    error: Color(0xFFFF6767),
    surface: Color(0xFFF3F3F3),
    tertiary: Color.fromARGB(255, 0, 0, 0),
    tertiaryContainer: Color(0xFFC98B3E),
    secondaryContainer: Color(0xFFEE6464),
    onTertiary: Color(0xFFD9D9D9),
    onSecondary: Color.fromARGB(255, 0, 0, 0),
    onSecondaryContainer: Color(0xFFA8C5C1),
    onTertiaryContainer: Color(0xFF425956),
    outline: Color(0xFF8CFFF1),
    onPrimaryContainer: Color(0xFFDEFFFB),
    primaryContainer: Color(0xFFFFA800),
    onErrorContainer: Color(0xFFFFE6AD),
    onPrimary: Color.fromARGB(255, 163, 163, 163),
    surfaceTint: Color.fromARGB(255, 146, 147, 146),
    errorContainer: Color(0xFFF6F6F6),
    inverseSurface: Color(0xFF0148AF),
    surfaceContainer: Color.fromARGB(255, 0, 0, 0),
    secondaryFixedDim: Color(0xff808080),
  ),
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFF00A0E9))),
  dialogTheme: DialogThemeData(
    backgroundColor: Colors.white,
    elevation: 6,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: Colors.white,
    elevation: 6,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.black.withValues(alpha: 0.1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    headerBackgroundColor: const Color(0xFF00A0E9),
    headerForegroundColor: Colors.white,
    headerHeadlineStyle: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headerHelpStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.white.withValues(alpha: 0.9),
    ),
    weekdayStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: Color(0xFF00A0E9),
    ),
    dayStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF0F172A),
    ),
    dayForegroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      if (states.contains(WidgetState.disabled)) {
        return const Color(0xFFCBD5E1);
      }
      return const Color(0xFF0F172A);
    }),
    dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFF00A0E9);
      }
      return Colors.transparent;
    }),
    dayOverlayColor: WidgetStateProperty.all(
        const Color(0xFF00A0E9).withValues(alpha: 0.12)),
    todayForegroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return const Color(0xFF00A0E9);
    }),
    todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFF00A0E9);
      }
      return const Color(0xFFE0F2FE);
    }),
    todayBorder: const BorderSide(color: Color(0xFF00A0E9), width: 1.5),
    yearStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Color(0xFF0F172A),
    ),
    yearForegroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      if (states.contains(WidgetState.disabled)) {
        return const Color(0xFFCBD5E1);
      }
      return const Color(0xFF0F172A);
    }),
    yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFF00A0E9);
      }
      return Colors.transparent;
    }),
    dividerColor: const Color(0xFFE2E8F0),
    cancelButtonStyle: TextButton.styleFrom(
      foregroundColor: const Color(0xFF64748B),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
    confirmButtonStyle: TextButton.styleFrom(
      foregroundColor: const Color(0xFF00A0E9),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: Colors.white,
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    dialBackgroundColor: const Color(0xFFF1F5F9),
    dialHandColor: const Color(0xFF00A0E9),
    dialTextColor: const Color(0xFF0F172A),
    dialTextStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    hourMinuteColor: const Color(0xFFE0F2FE),
    hourMinuteTextColor: const Color(0xFF00A0E9),
    hourMinuteShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(
        color: Color(0xFFBAE6FD),
        width: 1,
      ),
    ),
    dayPeriodColor: const Color(0xFFE0F2FE),
    dayPeriodTextColor: const Color(0xFF00A0E9),
    dayPeriodShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(
        color: Color(0xFFBAE6FD),
        width: 1,
      ),
    ),
    entryModeIconColor: const Color(0xFF00A0E9),
    helpTextStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Color(0xFF64748B),
    ),
    cancelButtonStyle: TextButton.styleFrom(
      foregroundColor: const Color(0xFF64748B),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
    confirmButtonStyle: TextButton.styleFrom(
      foregroundColor: const Color(0xFF00A0E9),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
  ),
);
