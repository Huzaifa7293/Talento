import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talento/Models/postModel.dart';
import 'package:talento/Utils/appColors.dart';
import 'package:talento/Views/uploadPost.dart';
import 'package:talento/Widgets/postCardWidget.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<PostModel> _posts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('TalentoPosts')
          .orderBy('timestamp', descending: true)
          .get();

      final postList =
          snapshot.docs.map((doc) => PostModel.fromJson(doc.data())).toList();

      setState(() {
        _posts = postList;
      });
    } catch (e) {
      print("Error fetching posts: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    await _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Talento",
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.chat_bubble_outline, color: Colors.orange),
          ),
        ],
      ),
      body: Column(
        children: [
          /// --- Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Here",
                hintStyle: const TextStyle(fontSize: 14),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),

          /// --- Post Feed
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: _posts.isEmpty
                        ? const Center(child: Text("No posts found."))
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _posts.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: PostCard(post: _posts[index]),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),

      /// --- Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const UploadPostScreen()),
            );
          }
          // Add more navigation handling for index 0 and 2 as needed
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundColor: Colors.orange,
              radius: 16,
              child: Icon(Icons.add, color: Colors.white, size: 20),
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
