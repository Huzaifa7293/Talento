import 'package:flutter/material.dart';
import 'package:talento/Services/authServices.dart';
import 'package:talento/Utils/appColors.dart';
import 'package:talento/Utils/appFonts.dart';
import 'package:talento/Utils/appStrings.dart';
import 'package:talento/Utils/appToasts.dart';
import 'package:talento/Views/forgetPassword.dart';
import 'package:talento/Views/masterScreen.dart';
import 'package:talento/Views/register.dart';
import 'package:talento/Widgets/gradientButton.dart';
import 'package:talento/Widgets/gradientText.dart';
import 'package:talento/Widgets/textfieldWidget.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login(BuildContext context) async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    ToastUtils.showToast(message: "Please fill all fields");
    return;
  }

  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(email)) {
    ToastUtils.showToast(message: "Enter a valid email");
    return;
  }

  ToastUtils.showToast(message: "Logging in...");

  String? result = await AuthService().loginUser(
  email: email,
  password: password,
  context: context,
);

  if (result == null) {
    // Successful login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MasterScreen()), // Replace with your home screen
      (route) => false,
    );
  } else {
    ToastUtils.showToast(message: result);
  }
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: false,
    backgroundColor: AppColors.white,
    body: SafeArea(
      child: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  Text(
                    AppStrings.loginHeading,
                    style: FontStyles.header(context).copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    hintText: 'Enter your email',
                    controller: _emailController,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    hintText: 'Enter your password',
                    isPassword: true,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: GradientText(
                        text: "Forgot Password?",
                        gradient: AppColors.gradient,
                        style: FontStyles.bodyText(context).copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GradientButton(
                    label: "Login",
                    onPressed: () => _login(context),
                    height: 60,
                width: double.infinity,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Stick-to-bottom footer
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(color: AppColors.textColor),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Register()),
                    );
                  },
                  child: GradientText(
                    text: 'Register now',
                    gradient: AppColors.gradient,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

}
