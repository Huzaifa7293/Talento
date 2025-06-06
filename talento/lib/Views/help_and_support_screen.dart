import 'package:flutter/material.dart';
import 'package:talento/Widgets/appBarWidget.dart';
import 'package:talento/Widgets/gradientButton.dart';
import 'package:talento/Widgets/gradientText.dart';
import 'package:talento/Widgets/textFieldWidget.dart';
import 'package:talento/utils/appColors.dart';
import 'package:url_launcher/url_launcher.dart';


class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _queryController = TextEditingController();

  Future<void> _sendEmail() async {
    final String email = 'support@talento.com';
    final String subject = Uri.encodeComponent("Support Query");
    final String body = Uri.encodeComponent(_queryController.text.trim());

    final Uri emailUri = Uri.parse("mailto:$email?subject=$subject&body=$body");

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not launch email app")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(title: "Help"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10,),
            const Text(
              "Contact Support",
              style: TextStyle(color: AppColors.textColor, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "For queries and support, please reach out to us at:",
              style: TextStyle(color: AppColors.textColor, fontSize: 14),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _sendEmail,
              child: const GradientText(
                    text: "support@talento.com",
                    style: TextStyle(fontSize: 14),
                  ),
            ),
            const SizedBox(height: 20),
            
            // Query Input Field
            CustomTextField(
                hintText: "Enter your query here ...",
                controller: _queryController,
                maxLinesss: 4
              ),
            const SizedBox(height: 20),

            // Send Email Button
            GradientButton(
                label: "Send Email",
                onPressed: _sendEmail,
                height: 60,
                width: double.infinity,
              ),
          ],
        ),
      ),
    );
  }
}
