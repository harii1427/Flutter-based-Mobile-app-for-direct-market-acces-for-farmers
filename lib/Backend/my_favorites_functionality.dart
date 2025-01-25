import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:far/utils/api.dart';
import 'package:far/Frontend/details_page.dart';

class MyFavoritesFunctions {
  static Future<void> initFavoriteVegetablesCollection(StateSetter setState,
      Function(CollectionReference, User?) setCollection) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      CollectionReference favoriteVegetablesCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('favoriteVegetables');
      setCollection(favoriteVegetablesCollection, currentUser);
    }
  }

  static Future<void> removeFavorite(
      Vegetable vegetable,
      CollectionReference collection,
      List<Vegetable> favoriteVegetables,
      StateSetter setState) async {
    final doc = collection.doc(vegetable.id);
    await doc.delete();
    setState(() {
      favoriteVegetables.removeWhere((v) => v.id == vegetable.id);
    });
  }

  static void navigateToDetailsPage(BuildContext context, Vegetable vegetable) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsPage(
          vegetable: vegetable,
          onVegetableUpdated: (updatedVegetable) {}, animal: null,
        ),
      ),
    );
  }

  static String getShortDescription(String description) {
    final lines = description.split('\n');
    final firstLine = lines.first;
    return firstLine.length > 30
        ? '${firstLine.substring(0, 30)}...more'
        : '$firstLine...more';
  }
}
