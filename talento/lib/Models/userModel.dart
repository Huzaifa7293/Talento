class UserModel {
  final String id;
  final String fullName;
  final String username;
  final String email;
  final String password;
  final String bio;
  final String profilePhotoUrl;
  final String coverPhotoUrl;
  final int postCount;
  final List<String> followers;
  final List<String> following;


  UserModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
    required this.bio,
    required this.profilePhotoUrl,
    required this.coverPhotoUrl,
    required this.postCount,
    required this.followers,
    required this.following,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['fullName'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      bio: json['bio'],
      profilePhotoUrl: json['profilePhotoUrl'],
      coverPhotoUrl: json['coverPhotoUrl'],
      postCount: json['postCount'] ?? 0,
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'email': email,
      'password': password,
      'bio': bio,
      'profilePhotoUrl': profilePhotoUrl,
      'coverPhotoUrl': coverPhotoUrl,
      'postCount': postCount,
      'followers': followers,
      'following': following,
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? username,
    String? phone,
    String? email,
    String? password,
    String? bio,
    String? profilePhotoUrl,
    String? coverPhotoUrl,
    int? postCount,
    List<String>? followers,
    List<String>? following,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      bio: bio ?? this.bio,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      postCount: postCount ?? this.postCount,
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }
}
