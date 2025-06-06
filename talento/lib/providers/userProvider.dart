import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talento/Models/userModel.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch the user from Firestore using the current user's UID
  Future<void> fetchUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final doc = await _firestore.collection('TalentoUsers').doc(currentUser.uid).get();
        if (doc.exists && doc.data() != null) {
          _user = UserModel.fromJson(doc.data()!);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error fetching user: $e");
    }
  }

  /// Manually set user (e.g., after signup)
  void setUser(UserModel userModel) {
    _user = userModel;
    notifyListeners();
  }

  /// Clear user (e.g., on logout)
  void clearUser() {
    _user = null;
    notifyListeners();
  }

  /// Update a field in the user and Firestore
  Future<void> updateUserField(String field, dynamic value) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection('TalentoUsers').doc(uid).update({field: value});
        // Update local user model
        _user = _user?.copyWith(
          id: field == 'id' ? value : _user!.id,
          fullName: field == 'fullName' ? value : _user!.fullName,
          username: field == 'username' ? value : _user!.username,
          email: field == 'email' ? value : _user!.email,
          password: field == 'password' ? value : _user!.password,
          bio: field == 'bio' ? value : _user!.bio,
          profilePhotoUrl: field == 'profilePhotoUrl' ? value : _user!.profilePhotoUrl,
          coverPhotoUrl: field == 'coverPhotoUrl' ? value : _user!.coverPhotoUrl,
          postCount: field == 'postCount' ? value : _user!.postCount,
          followers: field == 'followers' ? List<String>.from(value) : _user!.followers,
          following: field == 'following' ? List<String>.from(value) : _user!.following,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Failed to update $field: $e");
    }
  }
}
