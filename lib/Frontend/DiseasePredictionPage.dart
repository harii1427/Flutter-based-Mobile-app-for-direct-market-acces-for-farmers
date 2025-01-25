// ignore_for_file: file_names, use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, prefer_const_constructors, sort_child_properties_last

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

class DiseasePredictionPage extends StatefulWidget {
  @override
  _DiseasePredictionPageState createState() => _DiseasePredictionPageState();
}

class _DiseasePredictionPageState extends State<DiseasePredictionPage> {
  File? _image;
  final picker = ImagePicker();
  bool isLoading = false;
  String? imageUrl;
  String? predictionResult;
  String? diseaseDetails;

  // Function to pick an image from the gallery
  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  // Function to upload image to Firebase Storage and store image URL in Firestore
  Future uploadImageToFirebase() async {
    setState(() {
      isLoading = true;
    });

    if (_image == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      // Create a reference to Firebase Storage
      final storageReference = FirebaseStorage.instance
          .ref()
          .child('plantDisease/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload the file to Firebase Storage
      UploadTask uploadTask = storageReference.putFile(_image!);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      // Get the download URL of the uploaded file
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Save the image URL to Firestore `plantDisease` collection
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('plantDisease').add({
        'image_url': downloadUrl,
        'status':
            'pending', // Set status to pending until prediction is processed
      });

      // Wait a bit to ensure the Python backend processes the image and generates the prediction
      await Future.delayed(Duration(seconds: 5));

      // Fetch the results from plantDiseaseResults using doc_id
      await getPredictionResult(docRef.id);
    } catch (e) {
      print('Error uploading image: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  // Function to fetch prediction results from plantDiseaseResults collection using doc_id
  Future getPredictionResult(String docId) async {
    int maxRetries = 5;
    int attempts = 0;
    bool resultFound = false;

    while (attempts < maxRetries && !resultFound) {
      try {
        // Fetch the corresponding result from plantDiseaseResults collection
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('plantDiseaseResults')
            .where('doc_id', isEqualTo: docId)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          DocumentSnapshot doc = snapshot.docs.first;
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          setState(() {
            predictionResult = data['prediction_result'] ?? 'Unknown';
            diseaseDetails = data['disease_details'] ?? 'Details not available';
            imageUrl = data['image_url'];
          });

          resultFound = true;
        } else {
          print('No matching document found in plantDiseaseResults.');
        }
      } catch (e) {
        print('Error fetching prediction result: $e');
      }

      if (!resultFound) {
        print('Retrying to fetch prediction results... (${attempts + 1})');
        await Future.delayed(Duration(seconds: 5)); // Wait before retrying
      }

      attempts++;
    }

    if (!resultFound) {
      print('No result found after max retries.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Disease Prediction',
          style:
              TextStyle(color: Colors.white), // Set app bar text color to white
        ),
        backgroundColor: Color.fromARGB(255, 83, 134, 72),
        iconTheme: IconThemeData(
            color: Colors.white), // Set back button color to white
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Box to select an image with attractive design
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey, width: 2),
                        ),
                        child: _image == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.photo,
                                      size: 50, color: Colors.grey[700]),
                                  SizedBox(height: 10),
                                  Text(
                                    'Tap to select an image',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(
                                  _image!,
                                  width: double.infinity,
                                  height: 250,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Button to upload the image and get prediction result
                    ElevatedButton(
                      onPressed: () {
                        if (_image != null) {
                          uploadImageToFirebase();
                        } else {
                          print('Please select an image first.');
                        }
                      },
                      child: const Text('Upload Image and Predict',style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 83, 134, 72),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Display the prediction result
                    if (predictionResult != null)
                      Column(
                        children: [
                          const Text(
                            'Prediction Result:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 83, 134, 72),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            predictionResult!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),

                    // Display the disease details
                    if (diseaseDetails != null)
                      Column(
                        children: [
                          const Text(
                            'Disease Details:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 83, 134, 72),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            stripHtmlTags(diseaseDetails!),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  // Function to remove HTML tags from a string
  String stripHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '');
  }
}
