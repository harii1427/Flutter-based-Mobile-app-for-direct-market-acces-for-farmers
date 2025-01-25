// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> registerUser(
  BuildContext context,
  TextEditingController usernameController,
  TextEditingController phoneController,
  TextEditingController emailController,
  TextEditingController passwordController,
  TextEditingController pincodeController,
) async {
  final String username = usernameController.text.trim();
  final String phone = phoneController.text.trim();
  final String email = emailController.text.trim();
  final String password = passwordController.text.trim();
  final String pincode = pincodeController.text.trim();

  if (username.isEmpty ||
      phone.isEmpty ||
      email.isEmpty ||
      password.isEmpty ||
      pincode.isEmpty) {
    _showDialog(context, 'Error', 'Please fill in all fields.');
    return;
  }

  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    User? user = userCredential.user;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': username,
        'phone': phone,
        'email': email,
        'pincode': pincode,
        'uid': user.uid,
      });

      _showDialog(context, 'Success', 'Registration successful!');
    }
  } on FirebaseAuthException catch (e) {
    _showDialog(context, 'Error', e.message ?? 'An error occurred.');
  } catch (e) {
    _showDialog(context, 'Error', 'An error occurred.');
  }
}

void _showDialog(BuildContext context, String title, String message) {
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
