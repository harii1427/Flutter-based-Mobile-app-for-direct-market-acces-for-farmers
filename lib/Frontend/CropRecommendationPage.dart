// ignore_for_file: file_names, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_final_fields, prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CropRecommendationPage extends StatefulWidget {
  @override
  _CropRecommendationPageState createState() => _CropRecommendationPageState();
}

class _CropRecommendationPageState extends State<CropRecommendationPage> {
  final TextEditingController _nitrogenController = TextEditingController();
  final TextEditingController _phosphorousController = TextEditingController();
  final TextEditingController _potassiumController = TextEditingController();
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _rainfallController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  String _result = 'Waiting for result...';
  String _apiKey = '9d7cde1f6d07ec55650544be1631307e'; // Your provided API key
  double _temperature = 0.0;
  double _humidity = 0.0;
  bool _isLoading = false; // To show the loading indicator

  // Function to fetch weather data based on city
  Future<void> _fetchWeatherData(String city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$_apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final weatherData = json.decode(response.body);
      setState(() {
        _temperature = weatherData['main']['temp'];
        _humidity = weatherData['main']['humidity'].toDouble();
      });
    } else {
      setState(() {
        _result = 'Failed to fetch weather data';
      });
    }
  }

  // Function to submit data to Firebase
  Future<void> _submitData() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    // Fetch temperature and humidity based on city
    await _fetchWeatherData(_cityController.text);

    var data = {
      'nitrogen': int.parse(_nitrogenController.text),
      'phosphorous': int.parse(_phosphorousController.text),
      'potassium': int.parse(_potassiumController.text),
      'ph': double.parse(_phController.text),
      'rainfall': double.parse(_rainfallController.text),
      'temperature': _temperature, // Fetched from API
      'humidity': _humidity, // Fetched from API
    };

    // Save data to crop_predictions collection
    var docRef = await FirebaseFirestore.instance
        .collection('crop_predictions')
        .add(data);

    // Delay to simulate waiting for backend result (optional)
    await Future.delayed(Duration(seconds: 5));

    // Fetch the result from crop_results based on the document ID saved in crop_predictions
    var resultQuery = await FirebaseFirestore.instance
        .collection('crop_results')
        .where('doc_id',
            isEqualTo: docRef.id) // Fetch based on the saved doc ID
        .get();

    if (resultQuery.docs.isNotEmpty) {
      var resultDoc = resultQuery.docs.first; // Get the first matching document
      setState(() {
        _result = resultDoc['prediction_result'] ?? 'No result found';
        _isLoading = false; // Stop loading
      });

      // Delete the fetched result document from Firestore
      await FirebaseFirestore.instance
          .collection('crop_results')
          .doc(resultDoc.id)
          .delete();
      print('Result document deleted from Firestore');
    } else {
      setState(() {
        _result = 'No result found';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crop Recommendation',
          style:
              TextStyle(color: Colors.white), // Set app bar text color to white
        ),
        backgroundColor: Color.fromARGB(255, 83, 134, 72),
        iconTheme: IconThemeData(
            color: Colors.white), // Set back button color to white
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField(_nitrogenController, 'Nitrogen', Icons.grass,
                  TextInputType.number),
              _buildTextField(_phosphorousController, 'Phosphorous', Icons.eco,
                  TextInputType.number),
              _buildTextField(_potassiumController, 'Potassium', Icons.nature,
                  TextInputType.number),
              _buildTextField(
                  _phController, 'pH', Icons.science, TextInputType.number),
              _buildTextField(_rainfallController, 'Rainfall', Icons.water,
                  TextInputType.number),
              _buildTextField(_cityController, 'City', Icons.location_city,
                  TextInputType.text), // Changed keyboard to text for city
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _submitData, // Disable button when loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 83, 134, 72),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Submit',style:TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20),
              Text('Prediction Result: $_result'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, TextInputType keyboardType) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType, // Setting keyboard type dynamically
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
