import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:talento/Utils/appColors.dart';

class ToastUtils {
  static void showToast({
    required String message,
    Color backgroundColor = AppColors.orange,
    Color textColor = AppColors.white,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast toastLength = Toast.LENGTH_SHORT,
    double fontSize = 14.0,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
    );
  }
}
