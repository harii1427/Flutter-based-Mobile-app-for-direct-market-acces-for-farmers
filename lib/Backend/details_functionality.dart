// ignore_for_file: deprecated_member_use, use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:far/utils/api.dart'; // Import the Vegetable model if needed
import 'package:url_launcher/url_launcher.dart';

class DetailsPageFunctions {
  // Updated: Now accepts BuildContext context
  static Future<void> launchUrl(BuildContext context, String url) async {
    try {
      if (url.startsWith('tel:')) {
        await launch(url);
      } else if (url.startsWith('https://www.instagram.com/') ||
          url.startsWith('https://wa.me/')) {
        await launch(url);
      } else {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      }
    } catch (e) {
      // Handle error gracefully, e.g., show a snackbar or dialog to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch the URL: $e')),
      );
    }
  }

  // Function to update vegetable details
  static Future<void> updateVegetable(
    BuildContext context,
    Vegetable vegetable,
    String name,
    String price,
    String description,
    String characteristic,
    String address,
  ) async {
    // Build the updated fields map, using provided values or retaining the original ones if not updated
    final updatedFields = {
      'NAME': name.isNotEmpty ? name : vegetable.name,
      'PRICE': price.isNotEmpty ? price : vegetable.price,
      'DESCRIPTION': description.isNotEmpty ? description : vegetable.description,
      'CHARACTERISTIC': characteristic.isNotEmpty ? characteristic : vegetable.characteristic,
      'ADDRESS': address.isNotEmpty ? address : vegetable.address,
      'IMAGE': vegetable.images, // Unchanged images
      'VIDEO': vegetable.videos, // Unchanged videos
      'PIN_CODE': vegetable.pinCode,
      ...vegetable.additionalFields, // Keep the additional fields intact
    };

    // Call the API service to update the vegetable.
    final success = await ApiService.updateVegetable(
        vegetable.id, vegetable.categoryId, updatedFields);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vegetable details updated successfully')),
      );
      Navigator.pop(context, updatedFields); // Return updated fields to the previous screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update vegetable details')),
      );
    }
  }

  // Function to update the user's role and add them to the "buyer" collection
  static Future<void> updateRoleAndAddToBuyerCollection(
    BuildContext context,
    Vegetable vegetable,
    String newRole,
  ) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;
        String email = user.email ?? '';

        // Update the role in the users collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'role': newRole});

        // Add to buyer collection
        await FirebaseFirestore.instance
            .collection('buyer')
            .doc(vegetable.id)
            .set({
          'userId': userId,
          'email': email,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Role updated to $newRole and added to buyer collection')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user is currently logged in.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Failed to update role and add to buyer collection: $e')),
      );
    }
  }
}
