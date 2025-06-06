import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talento/Widgets/appBarWidget.dart';
import 'package:talento/Widgets/gradientButton.dart';
import 'package:talento/utils/appToasts.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../Models/postModel.dart';

class UploadPostScreen extends StatefulWidget {
  final String? currentUserId;

  const UploadPostScreen({super.key, required this.currentUserId});

  @override
  State<UploadPostScreen> createState() => _UploadPostScreenState();
}

class _UploadPostScreenState extends State<UploadPostScreen> {
  File? _mediaFile;
  String? _mediaType; // 'image' or 'video'
  VideoPlayerController? _videoController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool _isUploading = false;

  final picker = ImagePicker();

  Future<void> _pickMedia() async {
    final mediaType = await showModalBottomSheet<String>(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text('Pick Image'),
                  onTap: () => Navigator.pop(context, 'image'),
                ),
                ListTile(
                  leading: const Icon(Icons.videocam),
                  title: const Text('Pick Video'),
                  onTap: () => Navigator.pop(context, 'video'),
                ),
              ],
            ),
          ),
    );

    if (mediaType == null) return;

    XFile? picked;
    if (mediaType == 'image') {
      picked = await picker.pickImage(source: ImageSource.gallery);
      _mediaType = 'image';
    } else if (mediaType == 'video') {
      picked = await picker.pickVideo(source: ImageSource.gallery);
      _mediaType = 'video';
    }

    if (picked != null) {
      setState(() {
        _mediaFile = File(picked!.path);
      });
      if (_mediaType == 'video') {
        // Dispose previous controller before creating a new one
        await _videoController?.dispose();
        _videoController = VideoPlayerController.file(_mediaFile!);
        await _videoController!.initialize();
        _videoController!.setLooping(true);
        _videoController!.play();
        setState(() {});
      }
    }
  }

  Future<String> _uploadMediaToStorage(File file) async {
    String fileId = const Uuid().v4();
    final ref = FirebaseStorage.instance
        .ref()
        .child('posts')
        .child('$fileId.jpg');
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
        uId: widget.currentUserId!,
        mediaUrl: mediaUrl,
        caption: _titleController.text.trim(),
        description: _bodyController.text.trim(), // <-- Add this line
        likesCount: 0,
        commentCount: 0,
        type: _mediaType ?? 'image', // Default to 'image' if null
        likedBy: [],
        commentBy: [],
        timestamp: Timestamp.fromDate(DateTime.now()), // TODO: Replace with actual user profile pic URL if available
      );

      await FirebaseFirestore.instance
          .collection('TalentoPosts')
          .doc(postId)
          .set(newPost.toJson());

      if (context.mounted) {
        Navigator.pop(context);
        ToastUtils.showToast(message: "Post uploaded!");
      }
    } catch (e) {
      debugPrint('Upload error: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Widget _buildVideoPreview(String path) {
    return FutureBuilder<Uint8List?>(
      future: VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.JPEG,
        quality: 25,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Icon(
                Icons.play_circle_outline,
                size: 50,
                color: Colors.white.withOpacity(0.8),
              ),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Upload Post",
      action: GradientButton(
    label: "Upload",
    height: 36,
    width: 80,
    borderRadius: 18,
    textSize: 12,
    onPressed: _uploadPost,
  ),),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
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
                        child:
                            _mediaFile == null
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.image_outlined,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Upload your media here",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                )
                                : _mediaType == 'image'
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    _mediaFile!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: _buildVideoPreview(_mediaFile!.path),
                                ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      decoration: const InputDecoration.collapsed(
                        hintText: "Title",
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bodyController,
                      decoration: const InputDecoration.collapsed(
                        hintText: "Body text (optional)",
                      ),
                      maxLines: null,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
