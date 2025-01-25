// ignore_for_file: unused_local_variable, library_private_types_in_public_api, avoid_print, use_build_context_synchronously, prefer_const_constructors, unused_field, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:far/Backend/login_functionality.dart'; // Import the backend functions

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _appBarTitle = 'far';
  String _login = 'Login';
  String _emailOrPhone = 'Email or Phone';
  String _password = 'Password';
  String _forget = 'Forget password?';
  String _dontHaveAccount = "Don't have an account?";
  String _newUser = 'New user';
  String _or = "-or-";
  String _continueWith = 'continue with';
  String _welcomeBack = 'Welcome Back,';
  String _logInExclamation = 'Log In!';
  bool _isTamil = false;
  final TextEditingController emailOrPhoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isObscure = true;

  void togglePasswordVisibility() {
    setState(() {
      isObscure = !isObscure;
    });
  }

  void _changeLanguage() {
    setState(() {
      if (_isTamil) {
        _appBarTitle = 'far';
        _login = 'Login';
        _emailOrPhone = 'Email or Phone';
        _password = 'Password';
        _forget = 'Forget password?';
        _dontHaveAccount = "Don't have an account?";
        _newUser = 'New user';
        _or = "-or-";
        _continueWith = 'continue with';
        _welcomeBack = 'Welcome Back,';
        _logInExclamation = 'Log In!';
      } else {
        _appBarTitle = 'கூ';
        _login = 'உள்நுழை';
        _emailOrPhone = 'மின்னஞ்சல் அல்லது தொலைபேசி';
        _password = 'கடவுச்சொல்';
        _forget = 'கடவுச்சொல்லை மறந்துவிட்டீர்களா?';
        _dontHaveAccount = 'கணக்கு இல்லையா?';
        _newUser = 'புதிய பயனர்';
        _or = "-அல்லது-";
        _continueWith = 'தொடரவும்';
        _welcomeBack = 'வரவேற்கிறோம்,';
        _logInExclamation = 'உள்நுழைக!';
      }
      _isTamil = !_isTamil;
    });
  }

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
                      Text(
                        _welcomeBack,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        _logInExclamation,
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
          Positioned(
            top: 40,
            left: 20,
            child: Text(
              _appBarTitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: _changeLanguage,
              child: Text(
                _isTamil ? 'Eng' : 'தமிழ்',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 300,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailOrPhoneController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: _emailOrPhone,
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon:
                          Icon(Icons.email_outlined, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20.0),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: isObscure,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: _password,
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 20.0),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      suffixIcon: IconButton(
                        onPressed: togglePasswordVisibility,
                        icon: Icon(
                          isObscure ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/forgot_password');
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _forget,
                        style: TextStyle(color: Colors.blue),
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
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
                        LoginPageFunctions.login(
                          context,
                          emailOrPhoneController.text.trim(),
                          passwordController.text.trim(),
                        );
                      },
                      child: Text(
                        _login,
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 160.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20),
                  Text(_continueWith),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          LoginPageFunctions.handleGoogleSignIn(context);
                        },
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white,
                          child: Image.asset(
                            'images/google_logo.png',
                            width: 45,
                            height: 45,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          LoginPageFunctions.handleTwitterSignIn(context);
                        },
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Image.asset(
                            'images/twitter.png',
                            width: 70,
                            height: 70,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_dontHaveAccount),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text(
                          _newUser,
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
