import 'package:flutter/material.dart';
import 'package:talento/Utils/appColors.dart';
import 'dart:async';

import 'package:talento/Views/onboarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Images/logo.png',
              height: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return AppColors.gradient.createShader(bounds);
              },
            ),
          ],
        ),
      ),
    );
  }
}
