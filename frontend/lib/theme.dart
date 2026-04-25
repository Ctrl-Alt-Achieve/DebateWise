import 'package:flutter/material.dart';

class AppTheme {
  static const Color backgroundBlack = Color(0xFF000000);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF9CA3AF);
  static const Color borderGray = Color(0xFF1F2937); // gray-800
  static const Color cardGray = Color(0xFF111827); // gray-900

  // Colors used in glowing borders and gradients
  static const Color brandPink = Color(0xFFEC4899);
  static const Color brandOrange = Color(0xFFFB923C);
  static const Color brandYellow = Color(0xFFFBBF24);
  static const Color brandGreen = Color(0xFF34D399);
  static const Color brandBlue = Color(0xFF3B82F6);
  static const Color brandPurple = Color(0xFF8B5CF6);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundBlack,
    fontFamily: 'Inter', // Assuming standard sans-serif
    colorScheme: const ColorScheme.dark(
      background: backgroundBlack,
      surface: cardGray,
      primary: brandBlue,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textWhite),
      bodyMedium: TextStyle(color: textGray),
    ),
  );
}
