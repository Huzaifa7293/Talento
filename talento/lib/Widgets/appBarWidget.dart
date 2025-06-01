import 'package:flutter/material.dart';
import 'package:talento/Utils/appColors.dart';
import 'package:talento/Widgets/gradientText.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final Widget? action;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    const gradient = AppColors.gradient;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          toolbarHeight: 58,
          leadingWidth: showBackButton ? 90 : 0,
          leading: showBackButton
              ? GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      ShaderMask(
                        shaderCallback: (bounds) => gradient.createShader(bounds),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Colors.white, // Ignored by ShaderMask
                        ),
                      ),
                      const SizedBox(width: 4),
                      ShaderMask(
                        shaderCallback: (bounds) => gradient.createShader(bounds),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white, // Ignored by ShaderMask
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          title: GradientText(
            text: title,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            if (action != null)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: action,
              ),
          ],
        ),

        // Gradient bottom line under AppBar
        Container(
          height: 2,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            gradient: AppColors.gradient,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(58);
}
