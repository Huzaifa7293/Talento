import 'package:flutter/material.dart';
import 'package:talento/Utils/appColors.dart';

class FontStyles {
  static const String _fontFamily = 'Urbanist';

  // Small helper texts (e.g., placeholders, time)
  static TextStyle helperText(BuildContext context) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      fontFamily: _fontFamily,
      color: AppColors.lightGrey,
    );
  }

  // Standard paragraph/body text
  static TextStyle bodyText(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      fontFamily: _fontFamily,
      color: AppColors.textColor,
    );
  }

  // Light subheadings (section titles, like "Comments")
  static TextStyle subHeading(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      fontFamily: _fontFamily,
      color: AppColors.textColor,
    );
  }

  // Primary section titles (e.g., Profile name, screen heading)
  static TextStyle mainHeading(BuildContext context) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      fontFamily: _fontFamily,
      color: AppColors.textColor,
    );
  }

  // Major headers (e.g., app bar titles – styled with gradient separately)
  static TextStyle header(BuildContext context) {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      fontFamily: _fontFamily,
      color: AppColors.textColor, // gradient overrides in GradientText
    );
  }

  // Captions, comment hints, etc.
  static TextStyle caption(BuildContext context) {
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      fontFamily: _fontFamily,
      color: AppColors.lightGrey,
    );
  }
}
