import 'package:cloud_firestore/cloud_firestore.dart';
import 'commentModel.dart';

class PostModel {
  final String postId;
  final String uId;
  final String mediaUrl;
  final String caption;
  final String mood;
  final int likesCount;
  final int commentCount;
  final List<String> likedBy;
  final List<Comment> commentBy;
  final List<String> tags;
  final Timestamp timestamp;
  final String username;
  final String userProfilePic; // 👈 NEW field

  PostModel({
    required this.postId,
    required this.uId,
    required this.mediaUrl,
    required this.caption,
    required this.mood,
    required this.likesCount,
    required this.commentCount,
    required this.likedBy,
    required this.commentBy,
    required this.tags,
    required this.timestamp,
    required this.username,
    required this.userProfilePic, // 👈 NEW field
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      postId: json['postId'],
      uId: json['uId'],
      mediaUrl: json['mediaUrl'],
      caption: json['caption'],
      mood: json['mood'],
      likesCount: json['likesCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      likedBy: List<String>.from(json['likedBy'] ?? []),
      commentBy: (json['commentBy'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tags: List<String>.from(json['tags'] ?? []),
      timestamp: json['timestamp'] ?? Timestamp.now(),
      username: json['username'] ?? "User",
      userProfilePic: json['userProfilePic'] ??
          'https://via.placeholder.com/150', // 👈 Fallback image
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'uId': uId,
      'mediaUrl': mediaUrl,
      'caption': caption,
      'mood': mood,
      'likesCount': likesCount,
      'commentCount': commentCount,
      'likedBy': likedBy,
      'commentBy': commentBy.map((c) => c.toJson()).toList(),
      'tags': tags,
      'timestamp': timestamp,
      'username': username,
      'userProfilePic': userProfilePic, // 👈 NEW field
    };
  }
}
