import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:talento/Views/feedScreen.dart';
import 'package:talento/Views/profileScreen.dart';
import 'package:talento/Views/uploadPost.dart';
import 'package:talento/utils/appColors.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    FeedScreen(),
    ProfileScreen(userId: FirebaseAuth.instance.currentUser?.uid),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: AppColors.white,
        notchMargin: 12.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem('assets/Icons/home.svg', 'Home', 0),
              const SizedBox(width: 40),
              _buildNavItem('assets/Icons/user.svg', 'Profile', 1),
            ],
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadPostScreen(currentUserId: FirebaseAuth.instance.currentUser?.uid,)),
          );
        },
          child: Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.gradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(String assetPath, String label, int index) {
    final isSelected = _selectedIndex == index;
    final gradient = AppColors.gradient;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => isSelected
                ? gradient.createShader(bounds)
                : const LinearGradient(colors: [Colors.grey, Colors.grey])
                    .createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: SvgPicture.asset(
              assetPath,
              height: 24,
              width: 24,
              colorFilter: isSelected
                  ? null
                  : const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
            ),
          ),
          const SizedBox(height: 4),
          isSelected
              ? ShaderMask(
                  shaderCallback: (bounds) => gradient.createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                )
        ],
      ),
    );
  }
}



