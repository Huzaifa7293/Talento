import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talento/Models/userModel.dart';

class UserProvider extends ChangeNotifier {
  TalentoUser? _user;

  TalentoUser? get user => _user;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch the user from Firestore using the current user's UID
  Future<void> fetchUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final doc = await _firestore.collection('TalentoUsers').doc(currentUser.uid).get();
        if (doc.exists && doc.data() != null) {
          _user = TalentoUser.fromJson(doc.data()!);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error fetching Talento user: $e");
    }
  }

  /// Manually set user (e.g., after signup)
  void setUser(TalentoUser userModel) {
    _user = userModel;
    notifyListeners();
  }

  /// Clear user (e.g., on logout)
  void clearUser() {
    _user = null;
    notifyListeners();
  }

  /// Update a single field in Firestore and local model
  Future<void> updateUserField(String field, dynamic value) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection('TalentoUsers').doc(uid).update({field: value});
        _user = _user?.copyWith(
          id: field == 'id' ? value : _user!.id,
          fullName: field == 'fullName' ? value : _user!.fullName,
          username: field == 'username' ? value : _user!.username,
          phone: field == 'phone' ? value : _user!.phone,
          email: field == 'email' ? value : _user!.email,
          notification: field == 'notification' ? value : _user!.notification,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Failed to update $field: $e");
    }
  }
}
