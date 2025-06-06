import 'package:flutter/material.dart';
import 'package:talento/Utils/appColors.dart';
import 'package:talento/Widgets/gradientButton.dart';
import 'package:talento/Views/login.dart';
import 'package:talento/Views/register.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              
              // Logo with surrounding lines
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/Images/sphere.png', 
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/Images/logo.png',
                          height: 100,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Login Button
              GradientButton(
                label: 'Login',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                height: 60,
                width: double.infinity,
              ),
              const SizedBox(height: 16),

              // Register Button
              GradientButton(
                label: 'Register',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  Register()),
                  );
                },
                height: 60,
                width: double.infinity,
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

