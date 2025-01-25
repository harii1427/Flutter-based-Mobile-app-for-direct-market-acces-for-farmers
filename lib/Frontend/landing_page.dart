// ignore_for_file: prefer_const_constructors, unused_import, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:far/Frontend/Buyer_page.dart';
import 'package:far/Backend/landing_functionality.dart';
import 'package:far/Frontend/PredictionPage.dart'; // Import the prediction page

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 83, 134, 72),
                    Color.fromARGB(255, 142, 174, 139)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                  bottomRight: Radius.circular(100),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'WELCOME..!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        'far',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Container(
                width: 300,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                margin: EdgeInsets.only(top: 150),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 50),
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 83, 134, 72),
                            Color.fromARGB(255, 174, 212, 170)
                          ],
                        ),
                      ),
                      child: MaterialButton(
                        onPressed: () {
                          LandingPageFunctions.navigateToHome(context);
                        },
                        child: Text(
                          'Buy',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // Space between buttons
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Color.fromARGB(255, 174, 212, 170),
                          width: 2,
                        ),
                      ),
                      child: MaterialButton(
                        onPressed: () {
                          LandingPageFunctions.navigateToSellerDetails(context);
                        },
                        child: Text(
                          'Sell',
                          style: TextStyle(
                            color: Color.fromARGB(255, 83, 134, 72),
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20), // Space between buttons
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 83, 134, 72),
                            Color.fromARGB(255, 174, 212, 170)
                          ],
                        ),
                      ),
                      child: MaterialButton(
                        onPressed: () {
                          // Navigate to the Prediction Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PredictionPage()),
                          );
                        },
                        child: Text(
                          'Recommendation',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
