// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:far/Frontend/Buyer_page.dart';
// Ensure this path is correct to your MyHomePage and HomePage

/// Registers a new user with Firebase Authentication and stores additional data in Firestore.
Future<void> registerUser(
  BuildContext context,
  TextEditingController usernameController,
  TextEditingController phoneController,
  TextEditingController emailController,
  TextEditingController passwordController,
  TextEditingController pincodeController,
) async {
  try {
    print('Registering user with email: ${emailController.text.trim()}');
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    String? userId = userCredential.user?.uid;

    if (userId != null) {
      print('User ID: $userId');
      // Store user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'username': usernameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'pincode': pincodeController.text.trim(),
        'role': 'user', // Default role is user
      });

      _showDialog(context, 'Success', 'User registered successfully.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } else {
      _showDialog(context, 'Error', 'User ID is null.');
    }
  } on FirebaseAuthException catch (e) {
    print('FirebaseAuthException: ${e.code} - ${e.message}');
    if (e.code == 'email-already-in-use') {
      _showDialog(context, 'Error', 'The email address is already in use.');
    } else if (e.code == 'phone-number-already-in-use') {
      _showDialog(context, 'Error', 'The phone number is already in use.');
    } else {
      _showDialog(context, 'Registration Error',
          e.message ?? 'An unknown error occurred.');
    }
  } catch (e) {
    print('Unexpected error: $e');
    _showDialog(context, 'Error', e.toString());
  }
}

/// Logs in a user with Firebase Authentication.
Future<String?> loginUser(
  BuildContext context,
  String emailOrPhone,
  String password,
) async {
  try {
    print('Logging in with email/phone: $emailOrPhone');

    // Check if the input is an email or phone number
    bool isEmail =
        RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(emailOrPhone);

    UserCredential userCredential;
    if (isEmail) {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailOrPhone.trim(),
        password: password.trim(),
      );
    } else {
      // Query Firestore to find the user with the given phone number
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: emailOrPhone.trim())
          .get();

      if (querySnapshot.docs.isEmpty) {
        _showDialog(context, 'Error', 'No user found with this phone number.');
        return null;
      }

      String email = querySnapshot.docs.first.get('email');
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    }

    User? user = userCredential.user;
    if (user != null) {
      String userId = user.uid;
      print('User ID: $userId');
      return userId; // Return the logged-in user's ID
    } else {
      _showDialog(context, 'Error', 'Login failed.');
      return null; // Return null on login failure
    }
  } on FirebaseAuthException catch (e) {
    print('FirebaseAuthException: ${e.code} - ${e.message}');
    _showDialog(
        context, 'Login Error', e.message ?? 'An unknown error occurred.');
    return null; // Return null on login failure
  } catch (e) {
    print('Unexpected error: $e');
    _showDialog(context, 'Error', e.toString());
    return null; // Return null on login failure
  }
}

/// Signs in a user with Google.
Future<void> signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      // User cancelled the sign-in
      return;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    User? user = userCredential.user;
    if (user != null) {
      String userId = user.uid;

      // Check if user exists in Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (!userDoc.exists) {
        // If the user does not exist, create a new document
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'username': googleUser.displayName,
          'email': googleUser.email,
          'role': 'user', // Default role is user
        });
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    }
  } catch (e) {
    print('Google sign-in error: $e');
    _showDialog(context, 'Error', 'Google sign-in failed. Please try again.');
  }
}
void _showDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
