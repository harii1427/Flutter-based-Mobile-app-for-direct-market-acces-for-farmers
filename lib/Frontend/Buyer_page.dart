// ignore_for_file: unused_local_variable, avoid_print, prefer_const_constructors, unused_import, file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:background_location/background_location.dart';
import 'dart:async';
import 'dart:math';
import 'package:far/Frontend/Explore_buy_page.dart';
import 'package:far/sell.dart';
import 'package:far/Frontend/login_page.dart';
import 'package:far/Frontend/my_favorites_page.dart';
import 'package:far/Frontend/profile_page.dart';
import 'package:far/Frontend/details_page.dart';
import 'package:far/utils/api.dart';
import 'package:far/Backend/Buyer_functionality.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  int selectedIndex = 0;
  bool isTamil = false; // Flag to track current language

  final TextEditingController categoryController = TextEditingController();
  List<Vegetable> vegetables = []; // List to hold the vegetables
  List<Vegetable> favoriteVegetables = []; // List to hold favorite vegetables
  bool isLoading = false; // Loading state
  String errorMessage = ''; // Error message state
  late CollectionReference favoriteVegetablesCollection;
  User? currentUser;

  List<Map<String, dynamic>> categories = [];
  String? selectedCategoryId; // Selected category filter
  Map<String, dynamic> categoryFields =
      {}; // Dynamic fields for selected category
  String? selectedWeight;
  String? selectedPrice;
  String? searchQuery;
  String? pincode;

  final Map<String, String> englishTexts = {
    'appBarTitle': 'farmer',
    'searchHint': '  Search...',
    'welcomeText': 'Welcome!',
    'homeLabel': 'Home',
    'locationLabel': 'Location',
    'filterLabel': 'Filter',
    'profileLabel': 'Profile',
    'sell': 'Sell',
  };

  final Map<String, String> tamilTexts = {
    'appBarTitle': 'கூ',
    'searchHint': 'தேடு...',
    'welcomeText': 'வரவேற்கிறோம்!',
    'homeLabel': 'முகப்பு',
    'locationLabel': 'இடம்',
    'filterLabel': 'வடிகட்டு',
    'profileLabel': 'சுயவிவரம்',
    'sell': 'விற்க',
  };

  final Map<String, String> categoryImages = {
    'banana': 'images/category_Banana.png',
    'grape': 'images/category_Grape.png',
    'onion': 'images/category_Onion.png',
    'potato': 'images/category_Potato.png',
    'tomato': 'images/category_Tomato.png',
    'carrot': 'images/category_Carrot.png',
    'orange': 'images/category_Orange.png',
    'apple': 'images/category_Apple.png',
    'strawberry': 'images/category_Strawberry.png',
    'see_all': 'images/category_seeall.jpg',
  };

  @override
  void initState() {
    super.initState();
    _initStateSetup();
  }

  Future<void> _initStateSetup() async {
    await HomeFunctions.initFavoriteVegetables(this);
    await HomeFunctions.fetchCategories(this);
    HomeFunctions.initBackgroundLocation(this);
    await HomeFunctions.fetchVegetables(this);
  }

  @override
  Widget build(BuildContext context) {
    final texts = isTamil ? tamilTexts : englishTexts;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(texts),
      body: Column(
        children: [
          _buildGradientContainer(texts),
          const SizedBox(height: 10),
          _buildCategoryCircles(), // Add this line
          _buildFilterRow(texts),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : RefreshIndicator(
                        onRefresh: () => HomeFunctions.fetchVegetables(
                          this,
                          query: searchQuery,
                          weight: selectedWeight,
                          price: selectedPrice,
                          category: selectedCategoryId,
                        ),
                        child: _buildVegetablePosts(
                            selectedCategoryId), // Pass the selectedCategoryId
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(texts),
    );
  }

  PreferredSizeWidget _buildAppBar(Map<String, String> texts) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 83, 134, 72),
        ),
        child: AppBar(
          titleSpacing: 0,
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0),
                child: Text(
                  texts['appBarTitle']!,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 5, 0, 2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: texts['searchHint']!,
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                        HomeFunctions.fetchVegetables(
                          this,
                          query: value,
                          weight: selectedWeight,
                          price: selectedPrice,
                          category: selectedCategoryId,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  isTamil = !isTamil;
                });
              },
              child: Text(
                isTamil ? 'Eng' : 'தமிழ்',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientContainer(Map<String, String> texts) {
    return Container(
      width: double.infinity,
      height: 103,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 83, 134, 72),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 30, 0, 0),
                child: _buildNavItem(
                  Icons.location_searching_rounded,
                  texts['locationLabel']!,
                  1,
                  padding: const EdgeInsets.only(top: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(Map<String, String> texts) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 83, 134, 72),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, texts['homeLabel']!, 0,
              padding: const EdgeInsets.only(top: 18)),
          _buildNavItem(Icons.favorite,
              isTamil ? 'எனக்கு பிடித்தவைகள்' : 'My Favorites', 2,
              padding: const EdgeInsets.only(top: 18)),
          _buildNavItem(Icons.person, texts['profileLabel']!, 3,
              padding: const EdgeInsets.only(top: 18)),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index,
      {EdgeInsets? padding}) {
    return GestureDetector(
      onTap: () async {
        if (index == 3) {
          _showProfileMenu(context);
        } else if (index == 2) {
          // Navigate to My Favorites
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MyFavorites(favoriteVegetables: favoriteVegetables),
            ),
          );
        } else if (index == 1) {
          // Navigate to Explore widget (My Location)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExploreBuy()),
          );
          if (result != null && result is String) {
            setState(() {
              pincode = result; // Set the received pincode
              HomeFunctions.fetchVegetablesBasedOnPincode(
                  this, result); // Fetch vegetables based on pincode
            });
            print('Received pincode: $pincode'); // Print the received pincode
          }
        } else {
          setState(() {
            selectedIndex = index;
          });
          if (index == 0) {
            // Navigate to Home widget
          }
        }
      },
      child: Column(
        children: [
          Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: Icon(
              icon,
              color: selectedIndex == index ? Colors.orange : Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: selectedIndex == index ? Colors.orange : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('My profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Profile(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: () {
                  Navigator.pop(context);
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterRow(Map<String, String> texts) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 10),
            _buildFlexibleDropdownButton('PRICE', selectedPrice,
                (String? newValue) {
              setState(() {
                selectedPrice = newValue;
                HomeFunctions.fetchVegetables(
                  this,
                  query: searchQuery,
                  weight: selectedWeight,
                  price: selectedPrice,
                  category: selectedCategoryId,
                );
              });
            }, [
              'See all',
              'Below 50',
              '50-100',
              '100-150',
              'Above 150'
            ]),
            const SizedBox(width: 10),
            if (selectedCategoryId != null && categoryFields.isNotEmpty)
              ..._buildDynamicFilterFields(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDynamicFilterFields() {
    return categoryFields.entries
        .where((entry) => entry.key == 'additionalFields')
        .expand((entry) {
      final additionalFields = entry.value as Map<String, dynamic>;
      return additionalFields.entries
          .where((field) =>
              field.key != 'PHONE_NUMBER' && field.key != 'INSTAGRAM')
          .map((field) {
        List<String> dropdownValues = [];

        if (field.key == 'WEIGHTS') {
          dropdownValues = ['Below 5 kg', '5-10 kg', '10-15 kg', 'Above 15 kg'];
        }

        if (dropdownValues.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: SizedBox(
              width: 150, // Adjusted width
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.transparent,
                      width: 0, // Adjust the underline width as needed
                    ),
                  ),
                ),
                child: DropdownButton<String>(
                  value: field.key == 'WEIGHTS' ? selectedWeight : null,
                  hint: Text(field.key),
                  items: dropdownValues.map<DropdownMenuItem<String>>((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      if (field.key == 'WEIGHTS') {
                        selectedWeight = newValue;
                      }
                      HomeFunctions.fetchVegetables(
                        this,
                        query: searchQuery,
                        weight: selectedWeight,
                        price: selectedPrice,
                        category: selectedCategoryId,
                      );
                    });
                  },
                  underline: SizedBox(), // Remove the default underline
                ),
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: SizedBox(
              width: 150, // Adjusted width
              child: TextField(
                decoration: InputDecoration(
                  hintText: field.key,
                ),
              ),
            ),
          );
        }
      }).toList();
    }).toList();
  }

  Widget _buildCategoryCircles() {
    Set<String> uniqueCategoryIds = {};
    List<Map<String, dynamic>> uniqueCategories = [];

    for (var category in categories) {
      String categoryId = category['category_id']['_id'];
      if (!uniqueCategoryIds.contains(categoryId)) {
        uniqueCategoryIds.add(categoryId);
        uniqueCategories.add({
          'id': categoryId,
          'name': category['category_id']['name'],
          'image':
              categoryImages[category['category_id']['name'].toLowerCase()] ??
                  categoryImages['see_all']!
        });
      }
    }

    uniqueCategories.insert(
        0, {'id': '', 'name': 'See All', 'image': categoryImages['see_all']!});

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: uniqueCategories.map((category) {
          final isSelected = selectedCategoryId == category['id'] ||
              (category['id'] == '' && selectedCategoryId == null);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (category['id'] == '') {
                  selectedCategoryId = null;
                } else {
                  selectedCategoryId = category['id'];
                }
                if (selectedCategoryId == null) {
                  HomeFunctions.fetchVegetables(this); // Fetch all vegetables
                } else {
                  HomeFunctions.fetchCategoryFields(this, selectedCategoryId!);
                  HomeFunctions.fetchVegetables(
                    this,
                    query: searchQuery,
                    weight: selectedWeight,
                    price: selectedPrice,
                    category: selectedCategoryId,
                  );
                }
              });
            },
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 70,
                  height: 70,
                  child: ClipOval(
                    child: Container(
                      color: isSelected ? Colors.orange : Colors.grey[300],
                      child: Image.asset(
                        category['image']!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 70, // Ensure text is centered under the image
                  child: Text(
                    category['name']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.orange : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFlexibleDropdownButton(String label, String? selectedValue,
      ValueChanged<String?> onChanged, List<String> options) {
    return SizedBox(
      width: 120, // Reduced width to fit within the screen
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.transparent,
            ),
          ),
        ),
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text(label),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: TextStyle(fontSize: 15), // Adjust text size if needed
              ),
            );
          }).toList(),
          onChanged: onChanged,
          underline: Container(), // Remove the default underline
        ),
      ),
    );
  }

  Widget _buildVegetablePosts(String? selectedCategoryId) {
    // Added parameter
    return ListView.builder(
      itemCount: vegetables.length,
      itemBuilder: (context, index) {
        final vegetable = vegetables[index];
        bool isLiked = _isFavorite(vegetable);
        HomeFunctions.printVegetablePincodeLocation(
            vegetable); // Print vegetable pincode location

        // Check if vegetable's category matches the selected category
        if (selectedCategoryId != null &&
            vegetable.categoryId != selectedCategoryId) {
          return Container(); // Return an empty container if the category doesn't match
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailsPage(
                        vegetable: vegetable,
                        onVegetableUpdated: (updatedVegetable) {},
                        animal: null,
                      )),
            );
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
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 100);
                      },
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
                      Row(
                        children: [
                          Text(
                            "₹${vegetable.price}",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                              width: 10), // Add some spacing between texts
                          Expanded(
                            child: Text(
                              HomeFunctions.getAdditionalFields(
                                  vegetable.additionalFields),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow
                                  .ellipsis, // Ensure text does not overflow
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailsPage(
                                      vegetable: vegetable,
                                      onVegetableUpdated: (updatedVegetable) {},
                                      animal: null,
                                    )),
                          );
                        },
                        child: Text(
                          HomeFunctions.getShortDescription(
                              vegetable.description),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.black,
                  ),
                  onPressed: () {
                    HomeFunctions.addOrRemoveFavorite(this, vegetable);
                    setState(() {
                      // Trigger a rebuild to update the UI
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isFavorite(Vegetable vegetable) {
    return favoriteVegetables.any((a) => a.id == vegetable.id);
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    final sideLength = width / 2;
    final centerHeight = height / 2;

    path.moveTo(width * 0.5, 0);
    path.lineTo(width, centerHeight * 0.5);
    path.lineTo(width, centerHeight * 1.5);
    path.lineTo(width * 0.5, height);
    path.lineTo(0, centerHeight * 1.5);
    path.lineTo(0, centerHeight * 0.5);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
