import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:talento/Utils/appColors.dart';
import 'package:talento/Widgets/appBarWidget.dart';
import 'package:talento/Widgets/gradientButton.dart';
import '../Models/userModel.dart';
import '../Widgets/textFieldWidget.dart'; // Import your custom text field

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController fullNameController;
  late TextEditingController usernameController;
  late TextEditingController bioController;

  File? profileImageFile;
  File? coverImageFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.user.fullName);
    usernameController = TextEditingController(text: widget.user.username);
    bioController = TextEditingController(text: widget.user.bio);
  }

  Future<void> pickImage(bool isProfile) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isProfile) {
          profileImageFile = File(picked.path);
        } else {
          coverImageFile = File(picked.path);
        }
      });
    }
  }

  Future<String> uploadImage(File file, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> saveProfile() async {
    setState(() => isLoading = true);

    String profilePhotoUrl = widget.user.profilePhotoUrl;
    String coverPhotoUrl = widget.user.coverPhotoUrl;

    if (profileImageFile != null) {
      profilePhotoUrl = await uploadImage(profileImageFile!, 'profilePhotos/${widget.user.id}.jpg');
    }
    if (coverImageFile != null) {
      coverPhotoUrl = await uploadImage(coverImageFile!, 'coverPhotos/${widget.user.id}.jpg');
    }

    await FirebaseFirestore.instance.collection('TalentoUsers').doc(widget.user.id).update({
      'fullName': fullNameController.text.trim(),
      'username': usernameController.text.trim(),
      'bio': bioController.text.trim(),
      'profilePhotoUrl': profilePhotoUrl,
      'coverPhotoUrl': coverPhotoUrl,
    });

    setState(() => isLoading = false);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
  title: 'Edit Profile',
  action: GradientButton(
    label: isLoading ? "Saving..." : "Save",
    height: 30,
    width: 80,
    borderRadius: 20,
    textSize: 12,
    onPressed: saveProfile,
  ),
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Cover Photo with centered Profile Photo
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () => pickImage(false),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[300],
                      image: DecorationImage(
                        image: coverImageFile != null
                            ? FileImage(coverImageFile!)
                            : (widget.user.coverPhotoUrl.isNotEmpty
                                ? NetworkImage(widget.user.coverPhotoUrl)
                                : const AssetImage('assets/Images/user.png')) as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: const Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  child: GestureDetector(
                    onTap: () => pickImage(true),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white,
                      backgroundImage: profileImageFile != null
                          ? FileImage(profileImageFile!)
                          : (widget.user.profilePhotoUrl.isNotEmpty
                              ? NetworkImage(widget.user.profilePhotoUrl)
                              : const AssetImage('assets/Images/user.png')) as ImageProvider,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.black54,
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 56),
            CustomTextField(
              controller: fullNameController,
              hintText: 'Full Name',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: usernameController,
              hintText: 'Username',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: bioController,
              hintText: 'Bio',
              maxLinesss: 3,
            ),
          ],
        ),
      ),
    );
  }
}