// ignore_for_file: unused_local_variable, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:far/controllers/user_controller.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:far/Frontend/landing_page.dart';

class LoginPageFunctions {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String?> getEmailFromPhoneNumber(String phoneNumber) async {
    try {
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      final List<DocumentSnapshot> documents = result.docs;
      if (documents.isNotEmpty) {
        return documents.first['email'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching email from phone number: $e');
      return null;
    }
  }

  static Future<void> handleTwitterSignIn(BuildContext context) async {
    try {
      final twitterLogin = TwitterLogin(
        apiKey: 'iFoMEBXS7ESlDRF5nUyguVcPI',
        apiSecretKey: 'LHOnMok01A1KC3w8JbgwklZDEYuQR6fRDxQ5K8Qw65ZXxCIgfK',
        redirectURI: 'my-far-app://',
      );

      final authResult = await twitterLogin.login();

      if (authResult.status == TwitterLoginStatus.loggedIn) {
        final twitterAuthCredential = TwitterAuthProvider.credential(
          accessToken: authResult.authToken!,
          secret: authResult.authTokenSecret!,
        );

        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(twitterAuthCredential);

        if (userCredential.user != null) {
          await storeUserData(userCredential.user!);
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LandingPage()));
        }
      } else {
        print('Twitter login failed: ${authResult.errorMessage}');
      }
    } catch (e) {
      print('Twitter Sign-In Error: $e');
    }
  }

  static Future<void> handleGoogleSignIn(BuildContext context) async {
    try {
      final user = await UserController.loginWithGoogle();
      if (user != null) {
        await storeUserData(user);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LandingPage()));
      }
    } on FirebaseAuthException catch (error) {
      print(error.message);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? "Something went wrong")));
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  static Future<void> storeUserData(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      await userDoc.set({
        'email': user.email,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error storing user data: $e');
    }
  }

  static Future<void> login(BuildContext context, String emailOrPhone, String password) async {
    if (emailOrPhone.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please fill in all fields.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    String? email;

    if (emailOrPhone.contains('@')) {
      email = emailOrPhone;
    } else {
      email = await getEmailFromPhoneNumber(emailOrPhone);
    }

    if (email == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('No account found for this phone number.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      Navigator.pushReplacementNamed(context, '/LandingPage');
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Invalid email or password.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
