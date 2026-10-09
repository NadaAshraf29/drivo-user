import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  fontFamily: 'SFProText',
  primaryColor: Color(0xFF211f20),
  brightness: Brightness.dark,
  cardColor: const Color(0xFF242424),
  hintColor: const Color(0xFF9F9F9F),
  scaffoldBackgroundColor: const Color(0xff444444),
  primaryColorDark: const Color(0xff14b162),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF02B8A2),
    error: Color(0xFFFF6767),
    secondary: Color(0xFF008C7B),
    tertiary: Color(0xFF7CCD8B),
    tertiaryContainer: Color(0xFFC98B3E),
    secondaryContainer: Color(0xFFEE6464),
    onTertiary: Color(0xFFD9D9D9),
    onSecondary: Color(0xFF00FEE1),
    onSecondaryContainer: Color(0xFFA8C5C1),
    onTertiaryContainer: Color(0xFF425956),
    outline: Color(0xFFffffff),
    onPrimaryContainer: Color(0xFF929494),
    primaryContainer: Color(0xFFFFA800),
    onSurface: Color(0xFFFFE6AD),
    onPrimary: Color(0xFF064A42),
    surfaceContainer: Color(0xFF0094FF),
    secondaryFixedDim: Color(0xFF808080),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: const Color(0xFF00735f)),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontWeight: FontWeight.w300,
      color: Color(0xFF202020),
    ),
    displayMedium: TextStyle(
      fontWeight: FontWeight.w300,
      color: Color(0xFF393939),
    ),
    displaySmall: TextStyle(
      fontWeight: FontWeight.w300,
      color: Color(0xFF282828),
    ),
    bodyLarge: TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF272727)),
    bodyMedium: TextStyle(
      fontWeight: FontWeight.w300,
      color: Color(0xffffffff),
    ),
    bodySmall: TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF1D2D2B)),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFF1E293B),
    elevation: 6,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: const Color(0xFF1E293B),
    elevation: 6,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.black.withValues(alpha: 0.3),
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
      color: Color(0xFF38BDF8),
    ),
    dayStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFFF8FAFC),
    ),
    dayForegroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      if (states.contains(WidgetState.disabled)) {
        return const Color(0xFF475569);
      }
      return const Color(0xFFF8FAFC);
    }),
    dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFF00A0E9);
      }
      return Colors.transparent;
    }),
    dayOverlayColor: WidgetStateProperty.all(
        const Color(0xFF00A0E9).withValues(alpha: 0.16)),
    todayForegroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return const Color(0xFF38BDF8);
    }),
    todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFF00A0E9);
      }
      return const Color(0xFF0369A1).withValues(alpha: 0.3);
    }),
    todayBorder: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
    yearStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Color(0xFFF8FAFC),
    ),
    yearForegroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      if (states.contains(WidgetState.disabled)) {
        return const Color(0xFF475569);
      }
      return const Color(0xFFF8FAFC);
    }),
    yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const Color(0xFF00A0E9);
      }
      return Colors.transparent;
    }),
    dividerColor: const Color(0xFF334155),
    cancelButtonStyle: TextButton.styleFrom(
      foregroundColor: const Color(0xFF94A3B8),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
    confirmButtonStyle: TextButton.styleFrom(
      foregroundColor: const Color(0xFF38BDF8),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
  ),
  timePickerTheme: TimePickerThemeData(
    backgroundColor: const Color(0xFF1E293B),
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    dialBackgroundColor: const Color(0xFF334155),
    dialHandColor: const Color(0xFF00A0E9),
    dialTextColor: const Color(0xFFF8FAFC),
    dialTextStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    hourMinuteColor: const Color(0xFF0369A1),
    hourMinuteTextColor: Colors.white,
    hourMinuteShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(
        color: Color(0xFF0284C7),
        width: 1,
      ),
    ),
    dayPeriodColor: const Color(0xFF0369A1),
    dayPeriodTextColor: Colors.white,
    dayPeriodShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(
        color: Color(0xFF0284C7),
        width: 1,
      ),
    ),
    entryModeIconColor: const Color(0xFF38BDF8),
    helpTextStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Color(0xFF94A3B8),
    ),
    cancelButtonStyle: TextButton.styleFrom(
      foregroundColor: const Color(0xFF94A3B8),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
    confirmButtonStyle: TextButton.styleFrom(
      foregroundColor: const Color(0xFF38BDF8),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
  ),
);
