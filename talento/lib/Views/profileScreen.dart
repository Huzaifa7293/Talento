import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talento/Models/userModel.dart';
import 'package:talento/Views/profileEdit.dart';
import 'package:talento/Views/settings_screen.dart';
import 'package:talento/Views/chat_details_screen.dart';
import 'package:talento/Widgets/gradientButton.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final currentUser = FirebaseAuth.instance.currentUser?.uid;
  bool isFollowing = false;

  Future<Map<String, List<String>>> fetchUserPosts(String userId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('TalentoPosts')
            .where('uId', isEqualTo: userId)
            .get();

    List<String> allPosts = [];
    List<String> photoImages = [];
    List<String> videoThumbnails = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final mediaUrl = data['mediaUrl'] ?? '';
      final type = data['type'] ?? 'image';

      if (mediaUrl.isNotEmpty) {
        allPosts.add(mediaUrl);
        if (type == 'image') {
          photoImages.add(mediaUrl);
        } else if (type == 'video') {
          videoThumbnails.add(mediaUrl);
        }
      }
    }

    return {'all': allPosts, 'images': photoImages, 'videos': videoThumbnails};
  }

  Future<void> checkIfFollowing(String profileUserId) async {
    if (currentUser == null) return;
    final doc =
        await FirebaseFirestore.instance
            .collection('TalentoUsers')
            .doc(profileUserId)
            .get();
    if (doc.exists) {
      final data = doc.data()!;
      final followers = List<String>.from(data['followers'] ?? []);
      setState(() {
        isFollowing = followers.contains(currentUser);
      });
    }
  }

  Future<void> followUser(String profileUserId) async {
    if (currentUser == null) return;
    await FirebaseFirestore.instance
        .collection('TalentoUsers')
        .doc(profileUserId)
        .update({
          'followers': FieldValue.arrayUnion([currentUser]),
        });
    await FirebaseFirestore.instance
        .collection('TalentoUsers')
        .doc(currentUser)
        .update({
          'following': FieldValue.arrayUnion([profileUserId]),
        });
    setState(() {
      isFollowing = true;
    });
  }

  Future<void> unfollowUser(String profileUserId) async {
    if (currentUser == null) return;
    await FirebaseFirestore.instance
        .collection('TalentoUsers')
        .doc(profileUserId)
        .update({
          'followers': FieldValue.arrayRemove([currentUser]),
        });
    await FirebaseFirestore.instance
        .collection('TalentoUsers')
        .doc(currentUser)
        .update({
          'following': FieldValue.arrayRemove([profileUserId]),
        });
    setState(() {
      isFollowing = false;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.userId != null && widget.userId != currentUser) {
      checkIfFollowing(widget.userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          FirebaseFirestore.instance
              .collection('TalentoUsers')
              .doc(widget.userId)
              .get(),
          fetchUserPosts(widget.userId!), // <-- your method
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('User not found'));
          }

          final userSnapshot = snapshot.data![0] as DocumentSnapshot;
          final postData = snapshot.data![1] as Map<String, List<String>>;

          if (!userSnapshot.exists) {
            return const Center(child: Text('User not found'));
          }

          final user = userSnapshot.data() as Map<String, dynamic>;
          final id = user['id'] ?? '';
          final fullName = user['fullName'] ?? '';
          final username = user['username'] ?? '';
          final bio = user['bio'] ?? '';
          final profilePic = user['profilePhotoUrl'] ?? '';
          final coverPhoto = user['coverPhotoUrl'] ?? '';
          final followers = user['followers']?.length ?? 0;
          final following = user['following']?.length ?? 0;

          final allImages = postData['all'] ?? [];
          final photoImages = postData['images'] ?? [];
          final videoThumbnails = postData['videos'] ?? [];

          return Stack(
            children: [
              // Layer 1: Cover Image
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 250,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Layer 2: White Container with rounded top and shadow
              Positioned(
                top: 150,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 70), // space for avatar
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '@$username',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 40,
                        ),
                        child: Text(
                          bio,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      const SizedBox(height: 15),
                      id == currentUser
                          ? GradientButton(
                            label: "Edit Profile",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => EditProfileScreen(
                                        user: UserModel.fromJson(user),
                                      ),
                                ),
                              );
                            },
                            height: 30,
                            width: 200,
                            textSize: 14,
                            borderRadius: 20,
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GradientButton(
                                label: isFollowing ? "Unfollow" : "Follow",
                                onPressed: () {
                                  if (isFollowing) {
                                    unfollowUser(widget.userId!);
                                  } else {
                                    followUser(widget.userId!);
                                  }
                                },
                                height: 30,
                                width: 100,
                                textSize: 14,
                                borderRadius: 20,
                              ),
                              const SizedBox(width: 10),
                              GradientButton(
                                label: "Message",
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ChatDetailScreen(
                                            peerId: widget.userId!,
                                            peerName: fullName,
                                            peerImage: profilePic,
                                          ),
                                    ),
                                  );
                                },
                                height: 30,
                                width: 100,
                                textSize: 14,
                                borderRadius: 20,
                              ),
                            ],
                          ),

                      const SizedBox(height: 20),

                      // Tab Section (Only this scrolls)
                      Expanded(
                        child: DefaultTabController(
                          length: 3,
                          child: Column(
                            children: [
                              const TabBar(
                                tabs: [
                                  Tab(text: 'All'),
                                  Tab(text: 'Photos'),
                                  Tab(text: 'Videos'),
                                ],
                                labelColor: Colors.orange,
                                unselectedLabelColor: Colors.grey,
                                indicatorColor: Colors.orange,
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    buildScrollableTab(allImages),
                                    buildScrollableTab(photoImages),
                                    buildScrollableTab(videoThumbnails),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Layer 3: Avatar + Followers/Following beside it
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Followers
                    Column(
                      children: [
                        const SizedBox(height: 60),
                        Text(
                          '$followers',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const Text('Followers'),
                      ],
                    ),
                    const SizedBox(width: 60),

                    // Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          profilePic.startsWith('http')
                              ? NetworkImage(profilePic)
                              : const AssetImage('assets/images/user.png')
                                  as ImageProvider,
                    ),
                    const SizedBox(width: 50),

                    // Following
                    Column(
                      children: [
                        const SizedBox(height: 60),
                        Text(
                          '$following',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const Text('Following'),
                      ],
                    ),
                  ],
                ),
              ),
              id == currentUser
                  ? Positioned(
                    top: 50,
                    right: 20,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.settings,
                        color: Colors.white,
                        size: 30,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  )
                  : Positioned(
                    top: 50,
                    left: 20,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 30,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

Widget buildScrollableTab(List<String> imageUrls) {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(10),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(imageUrls[index], fit: BoxFit.cover),
          );
        },
      ),
    ),
  );
}
