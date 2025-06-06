import 'package:flutter/material.dart';
import 'package:talento/Services/authservices.dart';
import 'package:talento/Utils/appColors.dart';
import 'package:talento/Utils/appFonts.dart';
import 'package:talento/Utils/appToasts.dart';
import 'package:talento/Views/login.dart';
import 'package:talento/Views/masterScreen.dart';
import 'package:talento/Widgets/gradientButton.dart';
import 'package:talento/Widgets/textfieldWidget.dart';
import 'package:talento/utils/appStrings.dart';

class Register extends StatelessWidget {
  Register({super.key});

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _signup(BuildContext context) async {
    final fullName = _fullNameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (fullName.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ToastUtils.showToast(message: "Please fill all fields");
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      ToastUtils.showToast(message: "Please enter a valid email address");
      return;
    }

    if (password.length < 6) {
      ToastUtils.showToast(message: "Password must be at least 6 characters");
      return;
    }

    if (password != confirmPassword) {
      ToastUtils.showToast(message: "Passwords do not match");
      return;
    }

    final result = await AuthService().signUpUser(
      fullName: fullName,
      username: username,
      email: email,
      password: password,
      context: context,
    );

    if (result == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MasterScreen()),  
        (Route<dynamic> route) => false,
      );
      ToastUtils.showToast(message: "Signup successful");
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  Text(
                    AppStrings.signupHeading,
                    style: FontStyles.header(context).copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    hintText: 'Full Name',
                    controller: _fullNameController,
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    hintText: 'Username',
                    controller: _usernameController,
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    hintText: 'Email',
                    controller: _emailController,
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    hintText: 'Password',
                    isPassword: true,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    hintText: 'Confirm Password',
                    isPassword: true,
                    controller: _confirmPasswordController,
                  ),
                  const SizedBox(height: 40),

                  GradientButton(
                    label: "Register",
                    onPressed: () => _signup(context),
                    height: 60,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),

          // Stick-to-bottom login prompt
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(color: AppColors.textColor),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text(
                    "Login Now",
                    style: TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w600,
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
