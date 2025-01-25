// ignore_for_file: unused_local_variable, use_build_context_synchronously, prefer_const_constructors, library_private_types_in_public_api, deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:far/Backend/seller_functionality.dart';
import 'package:far/Frontend/Explore_buy_page.dart';
import 'package:far/Frontend/details_page.dart';
import 'package:far/Frontend/login_page.dart';
import 'package:far/Frontend/profile_page.dart';
import 'package:far/sell.dart';
import 'package:far/utils/api.dart';
import 'dart:convert';

class SellerDetails extends StatefulWidget {
  const SellerDetails({super.key});

  @override
  _SellerDetailsState createState() => _SellerDetailsState();
}

class _SellerDetailsState extends State<SellerDetails> {
  List<dynamic> _vegetables = [];
  String? _userId;
  bool _isLoading = true;
  int _selectedIndex = 0;
  bool _isTamil = false; // Flag to track current language

  final Map<String, String> _englishTexts = {
    'appBarTitle': 'far',
    'searchHint': 'Search...',
    'welcomeText': 'Welcome!',
    'homeLabel': 'Home',
    'locationLabel': 'Location',
    'filterLabel': 'Filter',
    'profileLabel': 'Profile',
    'sell': 'Sell',
    'selledVegetablesTitle': 'Sell vegetable list:', // Updated title for vegetables
  };

  final Map<String, String> _tamilTexts = {
    'appBarTitle': 'கூ',
    'searchHint': 'தேடு...',
    'welcomeText': 'வரவேற்கிறோம்!',
    'homeLabel': 'முகப்பு',
    'locationLabel': 'இடம்',
    'filterLabel': 'வடிகட்டு',
    'profileLabel': 'சுயவிவரம்',
    'sell': 'விற்க',
    'selledVegetablesTitle': 'விற்கவுள்ள:', // Updated title for vegetables
  };

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    await fetchUserId(context, setState, setUserId, fetchVegetables);
  }

  Future<void> fetchVegetables() async {
    await fetchVegetablesData(context, _userId, setState, setVegetablesLoading);
  }

  void setUserId(String? userId) {
    _userId = userId;
  }

  void setVegetablesLoading(List<dynamic> vegetables, bool isLoading) {
    setState(() {
      _vegetables = vegetables;
      _isLoading = isLoading;
    });
  }

  Future<void> _refresh() async {
    await fetchVegetables();
  }

  @override
  Widget build(BuildContext context) {
    final texts = _isTamil ? _tamilTexts : _englishTexts;

    return Scaffold(
      appBar: _buildAppBar(texts),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            _buildGradientContainer(texts),
            const SizedBox(height: 20),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  texts['selledVegetablesTitle']!, // Updated title for vegetables
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildVegetablePosts(),
            ),
          ],
        ),
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
                  _isTamil = !_isTamil;
                });
              },
              child: Text(
                _isTamil ? 'Eng' : 'தமிழ்',
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
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 20, 0),
                child: SellButton(isTamil: _isTamil),
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
        } else {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 1) {
            // Navigate to Explore widget
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ExploreBuy()),
            );
          }
        }
      },
      child: Column(
        children: [
          Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: Icon(
              icon,
              color: _selectedIndex == index ? Colors.orange : Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? Colors.orange : Colors.white,
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

  Widget _buildVegetablePosts() {
    return ListView.builder(
      itemCount: _vegetables.length,
      itemBuilder: (context, index) {
        final vegetable = _vegetables[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsPage(
                  vegetable: Vegetable.fromJson(vegetable),
                  isEditMode: false,
                  onVegetableUpdated: (updatedVegetable) {}, animal: null,
                ),
              ),
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
            child: Stack(
              children: [
                Row(
                  children: [
                    if (vegetable['fields']['IMAGE'].isNotEmpty)
                      Container(
                        height: 100,
                        width: 100,
                        margin: const EdgeInsets.only(right: 10),
                        child: Image.network(
                          vegetable['fields']['IMAGE'][0],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, size: 100);
                          },
                          loadingBuilder:
                              (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
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
                                "₹${vegetable['fields']['PRICE']}",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _getAdditionalFields(
                                      vegetable['fields']['additionalFields']),
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
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
                                    vegetable: Vegetable.fromJson(vegetable),
                                    isEditMode: false,
                                    onVegetableUpdated: (updatedVegetable) {}, animal: null,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              _getShortDescription(
                                  vegetable['fields']['DESCRIPTION']),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _editVegetable(Vegetable.fromJson(vegetable));
                        },
                        icon: Icon(Icons.edit),
                        color: Colors.grey,
                      ),
                      IconButton(
                        onPressed: () {
                          _showDeleteConfirmationDialog(vegetable['_id']);
                        },
                        icon: Icon(Icons.delete),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editVegetable(Vegetable vegetable) {
    editVegetable(context, vegetable, _vegetables, setState);
  }

  void _showDeleteConfirmationDialog(String categoryFieldsId) {
    showDeleteConfirmationDialog(context, categoryFieldsId, _vegetables, setState);
  }

  String _getShortDescription(String description) {
    final lines = description.split('\n');
    final firstLine = lines.first;
    return firstLine.length > 30
        ? '${firstLine.substring(0, 30)}...more'
        : '$firstLine...more';
  }

  String _getAdditionalFields(Map<String, dynamic> additionalFields) {
    return additionalFields.entries
        .where(
            (entry) => entry.key != 'PHONE_NUMBER' && entry.key != 'INSTAGRAM')
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(',');
  }
}

class SellButton extends StatelessWidget {
  final bool isTamil;

  const SellButton({super.key, required this.isTamil});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 124, 170, 119),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Sell()),
          );
        },
        style: ElevatedButton.styleFrom(
          shadowColor: Colors.transparent,
        ).merge(
          ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors.transparent;
                }
                return Colors.transparent;
              },
            ),
          ),
        ),
        child: Text(
          isTamil ? 'விற்க' : 'Sell',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
