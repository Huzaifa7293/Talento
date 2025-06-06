import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talento/Models/userModel.dart';
import 'package:talento/providers/userProvider.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Existing email/password login (unchanged)
  Future<String?> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot snapshot =
          await _firestore
              .collection('TalentoUsers')
              .doc(userCredential.user!.uid)
              .get();

      if (snapshot.exists) {
        UserModel user = UserModel.fromJson(
          snapshot.data() as Map<String, dynamic>,
        );
        Provider.of<UserProvider>(context, listen: false).setUser(user);
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      debugPrint("Login error: $e");
      return "An unexpected error occurred.";
    }
  }

  /// Existing signup (unchanged)
  Future<String?> signUpUser({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        fullName: fullName,
        username: username,
        email: email,
        password: password,
        bio: '',
        profilePhotoUrl: '',
        coverPhotoUrl: '',
        postCount: 0,
        followers: [],
        following: [],
      );

      await _firestore
          .collection('TalentoUsers')
          .doc(newUser.id)
          .set(newUser.toJson());

      Provider.of<UserProvider>(context, listen: false).setUser(newUser);

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }
}
