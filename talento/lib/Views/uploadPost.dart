import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/postModel.dart';

class UploadPostScreen extends StatefulWidget {
  final String currentUserId;

  const UploadPostScreen({super.key, required this.currentUserId});

  @override
  State<UploadPostScreen> createState() => _UploadPostScreenState();
}

class _UploadPostScreenState extends State<UploadPostScreen> {
  File? _mediaFile;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool _isUploading = false;

  final picker = ImagePicker();

  Future<void> _pickMedia() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _mediaFile = File(picked.path);
      });
    }
  }

  Future<String> _uploadMediaToStorage(File file) async {
    String fileId = const Uuid().v4();
    final ref = FirebaseStorage.instance.ref().child('posts').child('$fileId.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _uploadPost() async {
    if (_mediaFile == null || _titleController.text.trim().isEmpty) return;

    setState(() => _isUploading = true);
    try {
      String mediaUrl = await _uploadMediaToStorage(_mediaFile!);

      final postId = const Uuid().v4();
      final newPost = PostModel(
        postId: postId,
        uId: widget.currentUserId,
        mediaUrl: mediaUrl,
        caption: _titleController.text.trim(),
        tags: [],
        mood: '',
        likesCount: 0,
        commentCount: 0,
        likedBy: [],
        commentBy: [],
        timestamp: Timestamp.fromDate(DateTime.now()),
        username: '', // TODO: Replace with actual username if available
        userProfilePic: '', // TODO: Replace with actual user profile pic URL if available
      );

      await FirebaseFirestore.instance.collection('posts').doc(postId).set(newPost.toJson());

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post uploaded!")),
        );
      }
    } catch (e) {
      debugPrint('Upload error: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 56), // Space for AppBar buttons
                    GestureDetector(
                      onTap: _pickMedia,
                      child: Container(
                        height: mediaSize.width * 0.6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: _mediaFile == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  Text("Upload your media here",
                                      style: TextStyle(color: Colors.grey.shade600)),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(_mediaFile!, fit: BoxFit.cover),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      decoration: const InputDecoration.collapsed(hintText: "Title"),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bodyController,
                      decoration: const InputDecoration.collapsed(hintText: "Body text (optional)"),
                      maxLines: null,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Top Bar
            Positioned(
              top: 16,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, size: 28),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                child: const Text("Post", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
