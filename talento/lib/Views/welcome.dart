import 'package:flutter/material.dart';
import 'package:talento/Utils/appColors.dart';
import 'package:talento/Utils/appFonts.dart';
import 'package:talento/Widgets/gradientButton.dart';
import 'package:talento/Widgets/gradientText.dart';
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
                      'assets/images/sphere.png', 
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 60,
                        ),
                        const SizedBox(height: 10),
                        GradientText(
                          text: "Talento",
                          style: FontStyles.header(context),
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
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

