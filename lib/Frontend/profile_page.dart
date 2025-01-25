// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:far/Backend/profile_functionality.dart';
import 'dart:io';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool isEditing = false;
  File? _profileImage;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    pincodeController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    ProfileFunctions.pickImage(setState, _setProfileImage);
  }

  void _setProfileImage(File? image) {
    setState(() {
      _profileImage = image;
    });
  }

  Future<String> _uploadProfileImage() async {
    return await ProfileFunctions.uploadProfileImage(
        _profileImage, currentUser);
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('far'),
        ),
        body: const Center(
          child: Text('No user is currently logged in.'),
        ),
      );
    }

    final String uid = currentUser!.uid;
    final DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(uid);

    return Scaffold(
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
      body: FutureBuilder<DocumentSnapshot>(
        future: userDoc.get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User data not found'));
          }

          Map<String, dynamic> data =
              snapshot.data!.data()! as Map<String, dynamic>;
          if (!isEditing) {
            usernameController.text = data['username'] ?? '';
            emailController.text = data['email'] ?? '';
            phoneController.text = data['phone'] ?? '';
            pincodeController.text = data['pincode'] ?? '';
            addressController.text = data['address'] ?? '';
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            'Profile',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: isEditing ? _pickImage : null,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : data['profileImageUrl'] != null
                                    ? NetworkImage(data['profileImageUrl'])
                                    : const AssetImage(
                                            'assets/default_profile.png')
                                        as ImageProvider,
                          ),
                        ),
                        Positioned(
                          right: -10,
                          bottom: -10,
                          child: IconButton(
                            icon: Icon(
                              isEditing ? Icons.check : Icons.edit,
                              color: const Color.fromARGB(255, 68, 69, 70),
                            ),
                            onPressed: () async {
                              if (isEditing) {
                                String profileImageUrl = _profileImage != null
                                    ? await _uploadProfileImage()
                                    : data['profileImageUrl'] ?? '';
                                await ProfileFunctions.updateUserProfile(
                                    userDoc,
                                    usernameController,
                                    emailController,
                                    phoneController,
                                    pincodeController,
                                    addressController,
                                    profileImageUrl);
                              }
                              setState(() {
                                isEditing = !isEditing;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: isEditing
                          ? const OutlineInputBorder()
                          : InputBorder.none,
                    ),
                    readOnly: !isEditing,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: isEditing
                          ? const OutlineInputBorder()
                          : InputBorder.none,
                    ),
                    readOnly: !isEditing,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      border: isEditing
                          ? const OutlineInputBorder()
                          : InputBorder.none,
                    ),
                    readOnly: !isEditing,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: pincodeController,
                    decoration: InputDecoration(
                      labelText: 'Pincode',
                      border: isEditing
                          ? const OutlineInputBorder()
                          : InputBorder.none,
                    ),
                    readOnly: !isEditing,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: isEditing
                          ? const OutlineInputBorder()
                          : InputBorder.none,
                    ),
                    readOnly: !isEditing,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
