import 'package:flutter/material.dart';
import 'package:talento/Utils/appColors.dart';

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
    return SafeArea(
      child: Container(
        color: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            if (showBackButton)
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.white,
                    border: Border.all(color: AppColors.grey)
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            if (action != null) action!,
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
