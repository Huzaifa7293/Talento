import 'package:flutter/material.dart';
import 'package:talento/Utils/appColors.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talento/Views/onboarding.dart';
import 'package:talento/Views/masterScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkAuthAndNavigate();
  }

  Future<void> checkAuthAndNavigate() async {
    await Future.delayed(
      const Duration(seconds: 2),
    ); // Keep splash visible for 2 seconds

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => user != null ? MasterScreen() : OnboardingScreen(),
      ),
    );
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
              'assets/images/logo.png',
              height: 150,
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
