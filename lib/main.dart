// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:far/Frontend/Explore_buy_page.dart';
import 'package:far/Frontend/Buyer_page.dart';
import 'package:far/Frontend/forgot_password_page.dart';
import 'package:far/Frontend/register_page.dart';
import 'firebase_options.dart';
import 'sell.dart';
import 'package:far/Frontend/login_page.dart';
import 'package:far/Frontend/my_favorites_page.dart'; 
import 'package:far/Frontend/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:far/Frontend/landing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> _getInitialRoute() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return '/LandingPage';
    } else {
      return '/login';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getInitialRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        final initialRoute = snapshot.data ?? '/login';
        return MaterialApp(
          title: 'far',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          initialRoute: initialRoute,
          routes: {
            '/home': (context) => const Home(),
            '/LandingPage': (context) => const LandingPage(),
            '/explore_buy': (context) => const ExploreBuy(),
            '/forgot_password': (context) => const ForgotPasswordScreen(),
            '/register': (context) => const NewUserPage(),
            '/sell': (context) => const Sell(),
            '/login': (context) => const LoginPage(),
            '/my_favorites': (context) => const MyFavorites(favoriteVegetables: [],), 
            '/profile': (context) => const Profile(),
          },
        );
      },
    );
  }
}
