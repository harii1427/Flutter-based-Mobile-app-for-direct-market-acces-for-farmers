// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:far/Frontend/seller_page.dart';
import 'package:far/Frontend/Buyer_page.dart';

class LandingPageFunctions {
  static void navigateToHome(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );
  }

  static void navigateToSellerDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SellerDetails()),
    );
  }
}
