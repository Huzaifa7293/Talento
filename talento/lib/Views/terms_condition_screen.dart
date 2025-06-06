
import 'package:flutter/material.dart';
import 'package:talento/Widgets/appBarWidget.dart';
import 'package:talento/utils/appColors.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(title: "Terms and Conditions"),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                "Your privacy is important to us. This policy outlines how we collect, use, and protect your information. Please read thoroughly.",
                style: TextStyle(color: AppColors.textColor, fontSize: 14),
              ),
              SizedBox(height: 20),

              // Data Collection
              SectionTitle(title: "Data Collection"),
              SectionContent(
                content:
                    "We collect personal information when you register, make a purchase, or interact with our services.",
              ),
              SizedBox(height: 20),

              // Data Usage
              SectionTitle(title: "Data Usage"),
              SectionContent(
                content:
                    "Your data helps us provide a better experience, personalize content, and communicate updates.",
              ),
              SizedBox(height: 20),

              // Data Protection
              SectionTitle(title: "Data Protection"),
              SectionContent(
                content:
                    "We implement security measures to protect your information against unauthorized access.",
              ),
              SizedBox(height: 20),

              // User Rights
              SectionTitle(title: "User Rights"),
              SectionContent(
                content:
                    "You have the right to access, modify, or delete your data. Contact us for any inquiries regarding your data.",
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable Title Widget
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Reusable Content Widget
class SectionContent extends StatelessWidget {
  final String content;
  const SectionContent({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: const TextStyle(
        color: AppColors.textColor,
        fontSize: 14,
      ),
    );
  }
}