import 'package:flutter/material.dart';
import 'package:talento/Utils/appColors.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final TextStyle? textStyle;
  final double? height;
  final double? width;
  final double? textSize;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.textStyle,
    this.height,
    this.width,
    this.textSize,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextStyle = TextStyle(
      color: Colors.white,
      fontSize: textSize ?? 18,
      fontWeight: FontWeight.bold,
    ).merge(textStyle);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: height ?? 0,
        minWidth: width ?? 0,
      ),
      child: IntrinsicWidth(
        child: IntrinsicHeight(
          child: Material(
            borderRadius: BorderRadius.circular(borderRadius ?? 10),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(borderRadius ?? 10),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AppColors.gradient,
                  borderRadius: BorderRadius.circular(borderRadius ?? 10),
                ),
                padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Center(
                  child: Text(
                    label,
                    style: effectiveTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
