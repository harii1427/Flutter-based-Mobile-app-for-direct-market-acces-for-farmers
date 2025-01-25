// ignore_for_file: file_names, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FertilizerRecommendationPage extends StatefulWidget {
  @override
  _FertilizerRecommendationPageState createState() => _FertilizerRecommendationPageState();
}

class _FertilizerRecommendationPageState extends State<FertilizerRecommendationPage> {
  final TextEditingController _cropController = TextEditingController();
  final TextEditingController _nitrogenController = TextEditingController();
  final TextEditingController _phosphorousController = TextEditingController();
  final TextEditingController _potassiumController = TextEditingController();

  String _result = 'Waiting for result...';
  bool _isLoading = false;  // For showing loading state

  // Function to submit data to Firebase
  void _submitData() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    var data = {
      'cropname': _cropController.text,
      'nitrogen': int.parse(_nitrogenController.text),
      'phosphorous': int.parse(_phosphorousController.text),
      'potassium': int.parse(_potassiumController.text),
    };

    // Save data to fertilizer_recommendations collection
    var docRef = await FirebaseFirestore.instance.collection('fertilizer_recommendations').add(data);

    // Listen for the result in fertilizer_results collection
    FirebaseFirestore.instance
        .collection('fertilizer_results')
        .where('doc_id', isEqualTo: docRef.id) // Match doc_id with the fertilizer_recommendations ID
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          // Remove <br>, <br/>, and <i> tags and stop loading
          _result = (snapshot.docs.first.data()['prediction_result'] ?? 'Waiting for result...')
              .replaceAll('<br>', '')
              .replaceAll('<br/>', '')  // Also remove <br/>
              .replaceAll('<i>', '')
              .replaceAll('</i>', '');  // Clean up the tags
          _isLoading = false;
        });

        // Delete the result document after fetching the result
        FirebaseFirestore.instance.collection('fertilizer_results').doc(snapshot.docs.first.id).delete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fertilizer Recommendation',
          style:
              TextStyle(color: Colors.white), // Set app bar text color to white
        ),
        backgroundColor: Color.fromARGB(255, 83, 134, 72),
        iconTheme: IconThemeData(
            color: Colors.white), // Set back button color to white
      ),
      body: SingleChildScrollView(  // Added SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField(_cropController, 'Crop Name', Icons.agriculture, TextInputType.text),  // Correct keyboard type for Crop Name
              _buildTextField(_nitrogenController, 'Nitrogen', Icons.grass, TextInputType.number),
              _buildTextField(_phosphorousController, 'Phosphorous', Icons.eco, TextInputType.number),
              _buildTextField(_potassiumController, 'Potassium', Icons.nature, TextInputType.number),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitData,  // Disable button when loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 83, 134, 72),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)  // Show spinner when loading
                    : Text('Submit',style:TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20),
              Text('Recommendation Result: $_result'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, TextInputType keyboardType) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,  // Set keyboard type dynamically
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color.fromARGB(255, 83, 134, 72)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
