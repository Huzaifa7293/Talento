import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talento/Models/postModel.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool isLiked;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    isLiked = user != null && widget.post.likedBy.contains(user.uid);
    likeCount = widget.post.likesCount;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          /// --- Post Image with overlay content
          Stack(
            children: [
              /// Background Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  widget.post.mediaUrl,
                  height: 360,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              /// User Info (Top Left)
              Positioned(
                top: 16,
                left: 16,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(
                          widget.post.userProfilePic.isNotEmpty
                              ? widget.post.userProfilePic
                              : 'https://via.placeholder.com/150',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          timeago.format(widget.post.timestamp.toDate()),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// Comments & Likes (Right Center)
              Positioned(
                right: 16,
                top: 120,
                child: Column(
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 22),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.post.commentCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LikeButton(
                      size: 32,
                      isLiked: isLiked,
                      likeCount: likeCount,
                      likeBuilder: (isLiked) => Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      countBuilder: (count, isLiked, text) => Text(
                        '${count ?? 0}',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      onTap: (isLikedNow) async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return !isLikedNow;

                        final ref = FirebaseFirestore.instance
                            .collection('TalentoPosts')
                            .doc(widget.post.postId);

                        if (isLikedNow) {
                          await ref.update({
                            'likedBy': FieldValue.arrayRemove([user.uid]),
                            'likesCount': FieldValue.increment(-1),
                          });
                          setState(() {
                            isLiked = false;
                            likeCount--;
                          });
                        } else {
                          await ref.update({
                            'likedBy': FieldValue.arrayUnion([user.uid]),
                            'likesCount': FieldValue.increment(1),
                          });
                          setState(() {
                            isLiked = true;
                            likeCount++;
                          });
                        }

                        return !isLikedNow;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          /// Bottom Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Center(
              child: Text(
                '(${widget.post.commentCount} Comments)',
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
