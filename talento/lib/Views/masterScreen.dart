import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talento/Utils/appColors.dart';
import 'package:talento/Views/feedScreen.dart';
import 'package:talento/Views/uploadPost.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    FeedScreen(),
    ProfileScreen(),
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
        elevation: 10,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildIconButton('assets/Icons/home.png', 0),
              const SizedBox(width: 40),
              _buildIconButton('assets/Icons/profile.png', 3),
            ],
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          final currentUser = FirebaseAuth.instance.currentUser;
          final currentUserId = currentUser?.uid ?? '';

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  UploadPostScreen(currentUserId: currentUserId),
            ),
          );
        },
        child: Container(
          height: 60,
          width: 60,
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

  Widget _buildIconButton(String assetPath, int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: ShaderMask(
          shaderCallback: (bounds) => isSelected
              ? AppColors.gradient.createShader(bounds)
              : const LinearGradient(colors: [Colors.grey, Colors.grey])
                  .createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: SvgPicture.asset(
            assetPath,
            height: 26,
            width: 26,
            colorFilter: isSelected
                ? null
                : const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

// Dummy Profile Screen for testing
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Profile Screen'));
}
