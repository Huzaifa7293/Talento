import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talento/Utils/appToasts.dart';
import 'package:talento/Views/help_and_support_screen.dart';
import 'package:talento/Views/login.dart';
import 'package:talento/Views/privacy_policy_screen.dart';
import 'package:talento/Views/terms_condition_screen.dart';
import 'package:talento/Widgets/appBarWidget.dart';
import 'package:talento/utils/appColors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void logoutUser(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('TalentoUsers')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: \${e.toString()}")),
      );
    }
  }

  Future<void> deleteUserAccount() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await user.delete();
        await FirebaseFirestore.instance
            .collection('TalentoUsers')
            .doc(user.uid)
            .delete();
      } catch (e) {
        ToastUtils.showToast(message: e.toString());
      }
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(title: "Settings"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            SingleSettingItem(
              icon: Icons.article_outlined,
              text: "Terms and Conditions",
              detail: "View our terms and conditions",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TermsAndConditionsScreen(),
                  ),
                );
              },
            ),
            SingleSettingItem(
              icon: Icons.privacy_tip_outlined,
              text: "Privacy Policy",
              detail: "Check our privacy policy",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            SingleSettingItem(
              icon: Icons.support_agent_outlined,
              text: "Help and Support",
              detail: "Send us your queries",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HelpScreen()),
                );
              },
            ),
            SingleSettingItem(
              icon: Icons.logout,
              text: "Logout",
              detail: "See you soon!",
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirm Logout'),
                      content: Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            logoutUser(context);
                          },
                          child: Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            SingleSettingItem(
              icon: Icons.delete_outline,
              text: "Delete Account",
              detail: "Alas! Saying Goodbye",
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirm Delete'),
                      content: Text(
                        'Are you sure you want to delete your account? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            deleteUserAccount();
                          },
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SingleSettingItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final String detail;
  final VoidCallback onTap;

  const SingleSettingItem({
    super.key,
    required this.icon,
    required this.text,
    required this.detail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.orange, size: 24),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
        mainAxisSize: MainAxisSize.min, // Remove extra space
        children: [
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            detail,
            style: const TextStyle(color: AppColors.textColor, fontSize: 12),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
