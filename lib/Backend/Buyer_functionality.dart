// ignore_for_file: invalid_use_of_protected_member, use_build_context_synchronously, avoid_print, file_names

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:background_location/background_location.dart';
import 'package:far/Frontend/Buyer_page.dart';
import 'package:far/utils/api.dart';
import 'dart:math';

class HomeFunctions {
  static Future<void> initFavoriteVegetables(HomeState state) async {
    state.currentUser = FirebaseAuth.instance.currentUser;
    if (state.currentUser != null) {
      state.favoriteVegetablesCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(state.currentUser!.uid)
          .collection('favoriteVegetables');
      QuerySnapshot snapshot = await state.favoriteVegetablesCollection.get();
      state.setState(() {
        state.favoriteVegetables = snapshot.docs.map((doc) {
          return Vegetable(
            id: doc['id'] ?? '', // Provide a default empty string if null
            categoryId: '', // Default empty category ID
            description: doc['description'] ?? '', // Provide a default empty string if null
            images: List<String>.from(doc['images'] ?? []), // Ensure a default empty list if null
            price: doc['price'] ?? '', // Provide a default empty string if null
            name: '', // Default empty string if null
            age: '', // Default empty string if null
            characteristic: '', // Default empty string if null
            videos: [], // Default empty list if null
            pinCode: doc['pinCode'] ?? '', // Provide a default empty string if null
            address: '', // Default empty string if null
            additionalFields: Map<String, dynamic>.from(doc['additionalFields'] ?? {}), // Ensure a default empty map if null
            latitude: doc['latitude']?.toDouble() ?? 0.0, // Default to 0.0 if null
            longitude: doc['longitude']?.toDouble() ?? 0.0, // Default to 0.0 if null
          );
        }).toList();
      });
    }
  }

  static Future<void> fetchCategories(HomeState state) async {
    state.setState(() {
      state.isLoading = true;
      state.errorMessage = '';
    });

    try {
      final categories = await ApiService.fetchCategories();
      state.setState(() {
        state.categories = categories;
      });
    } catch (e) {
      state.setState(() {
        state.errorMessage = e.toString();
      });
    } finally {
      state.setState(() {
        state.isLoading = false;
      });
    }
  }

  static Future<void> initBackgroundLocation(HomeState state) async {
    BackgroundLocation.startLocationService(distanceFilter: 20);
    BackgroundLocation.getLocationUpdates((location) {
      state.setState(() {});
      ApiService().setCoordinates(location.latitude, location.longitude);
      if (state.pincode != null) {
        fetchVegetablesBasedOnPincode(state, state.pincode!);
      }
    });
  }

  static Future<void> fetchVegetablesBasedOnPincode(
      HomeState state, String pincode) async {
    state.setState(() {
      state.isLoading = true;
      state.errorMessage = '';
    });

    try {
      final locations = await locationFromAddress(pincode).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('The geocoding request timed out.');
        },
      );
      if (locations.isNotEmpty) {
        final pincodeLat = locations.first.latitude;
        final pincodeLong = locations.first.longitude;

        final allVegetables = await ApiService.fetchVegetables();
        final filteredVegetables =
            await Future.wait(allVegetables.map((vegetable) async {
          final vegetableLocations = await locationFromAddress(vegetable.pinCode);
          if (vegetableLocations.isNotEmpty) {
            final vegetableLat = vegetableLocations.first.latitude;
            final vegetableLong = vegetableLocations.first.longitude;
            final distance = calculateDistance(
                pincodeLat, pincodeLong, vegetableLat, vegetableLong);
            return {'vegetable': vegetable, 'distance': distance};
          }
          return null;
        })).then((values) => values.whereType<Map>().toList());

        state.setState(() {
          state.vegetables = filteredVegetables
              .where((item) => item['distance'] <= 20)
              .map((item) => item['vegetable'] as Vegetable)
              .toList();
          if (state.vegetables.isEmpty) {
            state.errorMessage = state.isTamil
                ? '20 கி.மீ சுற்றளவில் காய்கறிகள் இல்லை'
                : 'No vegetables available within 20 km radius';
          }
        });

        if (state.vegetables.isEmpty) {
          bool showAllVegetables = await showDialog<bool>(
                context: state.context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      state.isTamil
                          ? '20 கி.மீ சுற்றளவில் காய்கறிகள் இல்லை, மற்றவற்றை சரிபார்க்க விரும்புகிறீர்களா?'
                          : 'No vegetables available within 20 km radius. Do you want to check others?',
                      style: const TextStyle(fontSize: 16),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text(
                          state.isTamil ? 'ஆம்' : 'Yes',
                          style: const TextStyle(fontSize: 14),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  );
                },
              ) ??
              false;

          if (showAllVegetables) {
            state.setState(() {
              state.vegetables = allVegetables;
              state.errorMessage = '';
            });
          }
        }
      }
    } catch (e) {
      state.setState(() {
        state.errorMessage = e is TimeoutException
            ? 'Geocoding request timed out. Please try again.'
            : e.toString();
      });
    } finally {
      state.setState(() {
        state.isLoading = false;
      });
    }
  }

  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Pi/180
    const c = cos;
    final a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    final distance = 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
    return distance;
  }

  static Future<void> fetchVegetables(HomeState state,
      {String? query, String? weight, String? price, String? category}) async {
    state.setState(() {
      state.isLoading = true;
      state.errorMessage = '';
    });

    try {
      final vegetables = await ApiService.fetchVegetables();
      state.setState(() {
        state.vegetables = vegetables.where((vegetable) {
          final matchesQuery = query == null ||
              vegetable.name.contains(query) ||
              vegetable.description.contains(query);
          final matchesPrice = price == null ||
              price == 'See all' ||
              matchesPriceRange(vegetable.price, price);
          final matchesCategory =
              category == null || vegetable.categoryId == category;

          return matchesQuery &&
              matchesPrice &&
              matchesCategory;
        }).toList();
      });
    } catch (e) {
      state.setState(() {
        state.errorMessage = e.toString();
      });
    } finally {
      state.setState(() {
        state.isLoading = false;
      });
    }
  }

  
  static bool matchesPriceRange(String vegetablePrice, String? selectedPrice) {
    if (selectedPrice == null || selectedPrice == 'See all') return true;
    final price = int.tryParse(vegetablePrice) ?? 0;

    switch (selectedPrice) {
      case 'Below 50':
        return price >= 0 && price <= 50;
      case '50-100':
        return price >= 51 && price <= 100;
      case '100-150':
        return price >= 101 && price <= 150;
      case 'Above 150':
        return price >= 151;
      default:
        return false;
    }
  }

  static Future<void> fetchCategoryFields(
      HomeState state, String categoryId) async {
    state.setState(() {
      state.isLoading = true;
      state.errorMessage = '';
      state.categoryFields = {};
    });

    try {
      final fields = await ApiService.fetchFieldsForCategory(categoryId);
      state.setState(() {
        state.categoryFields = fields;
      });
    } catch (e) {
      state.setState(() {
        state.errorMessage = e.toString();
      });
    } finally {
      state.setState(() {
        state.isLoading = false;
      });
    }
  }

  static Future<void> addOrRemoveFavorite(
      HomeState state, Vegetable vegetable) async {
    final doc = state.favoriteVegetablesCollection.doc(vegetable.id);
    final docSnapshot = await doc.get();

    if (docSnapshot.exists) {
      await doc.delete();
      state.setState(() {
        state.favoriteVegetables.removeWhere((v) => v.id == vegetable.id);
      });
    } else {
      await doc.set({
        'id': vegetable.id,
        'description': vegetable.description,
        'images': vegetable.images,
        'latitude': vegetable.latitude,
        'longitude': vegetable.longitude,
        'pinCode': vegetable.pinCode,
        'price': vegetable.price,
        'name': vegetable.name,
        'weight': vegetable.weight,
        'characteristic': vegetable.characteristic,
        'address': vegetable.address,
        'videos': vegetable.videos,
        'additionalFields': vegetable.additionalFields,
      });
      state.setState(() {
        state.favoriteVegetables.add(vegetable);
      });
    }
  }

  static Future<void> printVegetablePincodeLocation(Vegetable vegetable) async {
    try {
      final locations = await locationFromAddress(vegetable.pinCode).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('The geocoding request timed out.');
        },
      );
      if (locations.isNotEmpty) {
        final latitude = locations.first.latitude;
        final longitude = locations.first.longitude;

        print(
            'Vegetable Pincode: ${vegetable.pinCode}, Latitude: $latitude, Longitude: $longitude');
      }
    } catch (e) {
      print('Error converting pincode to location: $e');
    }
  }

  static String getShortDescription(String description) {
    final lines = description.split('\n');
    final firstLine = lines.first;
    return firstLine.length > 30
        ? '${firstLine.substring(0, 30)}...more'
        : '$firstLine...more';
  }

  static String getAdditionalFields(Map<String, dynamic> additionalFields) {
    return additionalFields.entries
        .where(
            (entry) => entry.key != 'PHONE_NUMBER' && entry.key != 'INSTAGRAM')
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(',');
  }
}
