import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:talento/Utils/appColors.dart';
import 'package:talento/Utils/appFonts.dart';
import 'package:talento/Views/login.dart';
import 'package:talento/Widgets/gradientButton.dart';
import 'package:talento/Widgets/textfieldWidget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      Fluttertoast.showToast(msg: "Please enter a valid email address.");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Fluttertoast.showToast(msg: "Password reset link sent to $email");
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Arrow
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 16),

              // Heading
              Text(
                "Forgot Password?",
                style: FontStyles.header(context).copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                "Don't worry! It occurs. Please enter the email address linked with your account.",
                style: FontStyles.bodyText(context).copyWith(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 30),

              // Email Field
              CustomTextField(
                hintText: 'Enter your email',
                controller: _emailController,
              ),

              const SizedBox(height: 30),

              // Send Code Button
              GradientButton(
                label: "Send Code",
                onPressed: _sendResetLink,
                height: 60,
                width: double.infinity,
              ),

              const Spacer(),

              // Bottom Text
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Remember Password? ",
                      style: TextStyle(color: Colors.black),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: AppColors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
