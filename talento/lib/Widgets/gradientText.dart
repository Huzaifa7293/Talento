import 'package:flutter/material.dart';
import 'package:talento/Utils/appColors.dart'; 
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient? gradient;

  const GradientText({
    super.key,
    required this.text,
    this.style,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    // Use the passed gradient or default to the orange app gradient
    final usedGradient = gradient ?? AppColors.gradient;

    final defaultStyle = const TextStyle(
      fontFamily: 'Urbanist',
      fontSize: 24,
      fontWeight: FontWeight.w700,
    );

    return ShaderMask(
      shaderCallback: (bounds) =>
          usedGradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: defaultStyle.merge(style),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
