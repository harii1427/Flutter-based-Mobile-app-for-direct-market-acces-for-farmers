import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import for Firestore

class ProfileFunctions {
  static Future<void> pickImage(
      StateSetter setState, Function(File?) setImage) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setImage(File(pickedFile.path));
    }
  }

  static Future<String> uploadProfileImage(File? profileImage, User? currentUser) async {
    if (profileImage == null) return '';

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_pictures')
        .child(currentUser!.uid);

    await storageRef.putFile(profileImage);

    return await storageRef.getDownloadURL();
  }

  static Future<void> updateUserProfile(
      DocumentReference userDoc,
      TextEditingController usernameController,
      TextEditingController emailController,
      TextEditingController phoneController,
      TextEditingController pincodeController,
      TextEditingController addressController,
      String profileImageUrl) async {
    await userDoc.update({
      'username': usernameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'pincode': pincodeController.text,
      'address': addressController.text,
      'profileImageUrl': profileImageUrl,
    });
  }
}
