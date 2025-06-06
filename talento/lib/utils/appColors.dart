import 'package:flutter/material.dart';

class AppColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF121212); // Primary text color
  static const Color grey = Color(0xFFE8ECF4); // Used in search/comment background
  static const Color lightGrey = Color(0xFF8391A1); // Placeholder text, etc.
  static const Color orange = Color(0xFFF56C02); // Main accent color used in icons/buttons

  static const Gradient gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF5A128), // Top gradient color
      Color(0xFFF56C02), // Bottom gradient color
    ],
    stops: [0.0, 0.75],
  );
}
