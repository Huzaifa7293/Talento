import 'package:flutter/material.dart';
import 'package:talento/Utils/appColors.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final TextStyle? textStyle;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    const defaultTextStyle = TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    return SizedBox(
      height: 60,
      width: double.infinity,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.gradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: defaultTextStyle.merge(textStyle),
            ),
          ),
        ),
      ),
    );
  }
}
