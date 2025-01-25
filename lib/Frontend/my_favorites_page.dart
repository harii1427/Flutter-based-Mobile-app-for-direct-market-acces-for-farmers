// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:far/Backend/my_favorites_functionality.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:far/utils/api.dart';

class MyFavorites extends StatefulWidget {
  final List<Vegetable> favoriteVegetables;

  const MyFavorites({super.key, required this.favoriteVegetables});

  @override
  _MyFavoritesState createState() => _MyFavoritesState();
}

class _MyFavoritesState extends State<MyFavorites> {
  late CollectionReference favoriteVegetablesCollection;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    MyFavoritesFunctions.initFavoriteVegetablesCollection(
        setState, _setFavoriteVegetablesCollection);
  }

  void _setFavoriteVegetablesCollection(
      CollectionReference collection, User? user) {
    setState(() {
      favoriteVegetablesCollection = collection;
      currentUser = user;
    });
  }

  Future<void> _removeFavorite(Vegetable vegetable) async {
    MyFavoritesFunctions.removeFavorite(
        vegetable, favoriteVegetablesCollection, widget.favoriteVegetables, setState);
  }

  String _getShortDescription(String description) {
    return MyFavoritesFunctions.getShortDescription(description);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 83, 134, 72),
          ),
          child: AppBar(
            title: const Text(
              'far',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: widget.favoriteVegetables.isEmpty
          ? const Center(
              child: Text(
                'No favorites added yet!',
                style: TextStyle(fontSize: 18),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: widget.favoriteVegetables
                    .map((vegetable) => buildFavoriteVegetable(vegetable, context))
                    .toList(),
              ),
            ),
      bottomNavigationBar: buildBottomNavigationBar(context),
    );
  }

  Widget buildFavoriteVegetable(Vegetable vegetable, BuildContext context) {
    return GestureDetector(
      onTap: () {
        MyFavoritesFunctions.navigateToDetailsPage(context, vegetable);
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            if (vegetable.images.isNotEmpty)
              Container(
                height: 100,
                width: 100,
                margin: const EdgeInsets.only(right: 10),
                child: Image.network(
                  vegetable.images[0],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 100),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "₹${vegetable.price}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _getShortDescription(vegetable.description),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete,
                  color: Color.fromARGB(255, 227, 19, 19)),
              onPressed: () {
                _removeFavorite(vegetable);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomNavigationBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 83, 134, 72),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home, size: 30, color: Colors.white),
                Text('Home', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
