// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordFunctions {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> sendPasswordResetEmail(
      BuildContext context, String email) async {
    if (email.isEmpty) {
      _showDialog(context, 'Error', 'Please enter your email.');
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showDialog(
          context, 'Success', 'A password reset link has been sent to $email');
    } on FirebaseAuthException catch (e) {
      _showDialog(
          context, 'Error', e.message ?? 'An error occurred. Please try again.');
    }
  }

  static void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
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
