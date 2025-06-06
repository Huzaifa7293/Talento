import 'package:cloud_firestore/cloud_firestore.dart';
import 'commentModel.dart';

class PostModel {
  final String postId;
  final String uId;
  final String mediaUrl;
  final String caption;
  final String description; // 👈 NEW field
  final int likesCount;
  final int commentCount;
  final List<String> likedBy;
  final List<Comment> commentBy;
  final Timestamp timestamp;
  final String type;

  PostModel({
    required this.description,
    required this.postId,
    required this.uId,
    required this.mediaUrl,
    required this.caption,
    required this.likesCount,
    required this.commentCount,
    required this.likedBy,
    required this.commentBy,
    required this.timestamp,
    required this.type,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      postId: json['postId'],
      uId: json['uId'],
      mediaUrl: json['mediaUrl'],
      caption: json['caption'],
      likesCount: json['likesCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      likedBy: List<String>.from(json['likedBy'] ?? []),
      commentBy:
          (json['commentBy'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      timestamp: json['timestamp'] ?? Timestamp.now(),
      type: json['type'] ?? 'image', 
      description: json['description'] ?? '', // 👈 Fallback image
    );
  }

  // Example toJson in PostModel
  Map<String, dynamic> toJson() => {
    'postId': postId,
    'uId': uId,
    'mediaUrl': mediaUrl,
    'caption': caption,
    'description': description, 
    'likesCount': likesCount,
    'commentCount': commentCount,
    'likedBy': likedBy,
    'commentBy': commentBy.map((c) => c.toJson()).toList(),
    'timestamp': timestamp,
    'type': type,
  };
}
