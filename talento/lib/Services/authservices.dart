import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talento/Models/userModel.dart';
import 'package:talento/Providers/userProvider.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _verificationId;

  ///  Login with email and password
  Future<String?> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      debugPrint(" Logging in with: $email");

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot snapshot = await _firestore
          .collection('TalentoUsers')
          .doc(userCredential.user!.uid)
          .get();

      if (snapshot.exists) {
        TalentoUser user = TalentoUser.fromJson(snapshot.data() as Map<String, dynamic>);
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        debugPrint("Login success: ${user.id}");
      } else {
        debugPrint(" No user data found in Firestore");
      }

      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint(" FirebaseAuth error: ${e.message}");
      return e.message;
    } catch (e) {
      debugPrint(" Login error: $e");
      return "An unexpected error occurred.";
    }
  }

  ///  Signup with email and password
  Future<String?> signUpUser({
    required String fullName,
    required String username,
    required String email,
    required String phone,
    required String password,
    required BuildContext context,
  }) async {
    try {
      debugPrint(" Signing up: $email");

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint(" Firebase user created: ${userCredential.user!.uid}");

      TalentoUser newUser = TalentoUser(
        id: userCredential.user!.uid,
        fullName: fullName,
        username: username,
        phone: phone,
        email: email,
        notification: true,
      );

      debugPrint(" Saving user to Firestore: ${newUser.toJson()}");

      await _firestore
          .collection('TalentoUsers')
          .doc(newUser.id)
          .set(newUser.toJson());

      Provider.of<UserProvider>(context, listen: false).setUser(newUser);

      debugPrint(" User stored & provider updated.");
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint(" FirebaseAuth signup error: ${e.message}");
      if (e.code == 'email-already-in-use') {
        return 'This email is already registered.';
      } else if (e.code == 'weak-password') {
        return 'The password is too weak.';
      } else {
        return e.message;
      }
    } catch (e, st) {
      debugPrint(" Unexpected signup error: $e");
      debugPrint(" Stacktrace: $st");
      return 'An unexpected error occurred';
    }
  }

  /// 📲 Send SMS verification code
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function() onCodeSent,
    required Function(String error) onVerificationFailed,
  }) async {
    try {
      debugPrint(" Sending SMS to: $phoneNumber");

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          debugPrint(" Auto sign-in complete.");
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint(" Phone verification failed: ${e.message}");
          onVerificationFailed(e.message ?? 'Phone verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          debugPrint(" Code sent. Verification ID stored.");
          onCodeSent();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          debugPrint("⏱ Code auto-retrieval timed out.");
        },
      );
    } catch (e) {
      debugPrint(" Phone verification error: $e");
      onVerificationFailed(e.toString());
    }
  }

  /// 🔍 Check if user exists in Firestore
  Future<bool> checkIfUserExists(String uid) async {
    try {
      final doc = await _firestore.collection('TalentoUsers').doc(uid).get();
      return doc.exists;
    } catch (e) {
      debugPrint(" Error checking user existence: $e");
      return false;
    }
  }

  ///  Sign in with SMS code and route based on existence
  Future<String> signInWithSmsCodeAndCheckUser({
    required String smsCode,
    required BuildContext context,
  }) async {
    if (_verificationId == null) throw Exception('Verification ID not found. Request code first.');

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    try {
      debugPrint(" Signing in with SMS code...");

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('User not found after sign-in.');
      }

      final uid = userCredential.user!.uid;
      final exists = await checkIfUserExists(uid);

      if (exists) {
        DocumentSnapshot snapshot = await _firestore.collection('TalentoUsers').doc(uid).get();
        if (snapshot.exists) {
          TalentoUser user = TalentoUser.fromJson(snapshot.data() as Map<String, dynamic>);
          Provider.of<UserProvider>(context, listen: false).setUser(user);
        }
        debugPrint(" SMS login: user exists");
        return 'feed';
      } else {
        debugPrint(" SMS login: user needs profile setup");
        return 'profileSetup';
      }
    } catch (e) {
      debugPrint(" SMS sign-in failed: $e");
      throw Exception('Failed to sign in with SMS code: $e');
    }
  }
}
