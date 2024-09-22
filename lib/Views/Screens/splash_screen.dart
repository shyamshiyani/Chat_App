import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Utils/Helper/Auth_Helper.dart';
import 'Home_Screen.dart';
import 'Login_Screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? firstTime = prefs.getBool('isFirstTime');

    if (firstTime == null || firstTime) {
      setState(() {
        isFirstTime = true;
      });
    } else {
      setState(() {
        isFirstTime = false;
      });
    }

    // Always navigate after 4 seconds
    Future.delayed(const Duration(seconds: 4), _navigateToNextScreen);
  }

  Future<void> _navigateToNextScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isUserLoggedIn = prefs.getBool('isUserLogin');

    if (isUserLoggedIn == true) {
      User? user = AuthHelper.firebaseAuth.currentUser; // Fetch current user
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
          settings: RouteSettings(arguments: user),
        ),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _getStarted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    _navigateToNextScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBFB5AF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/Preview__2_-removebg-preview.png',
              width: 300,
              height: 300,
            ),
            if (isFirstTime)
              ElevatedButton(
                onPressed: _getStarted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA26769),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(color: Colors.white),
                ),
              )
            else
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA26769)),
              ),
          ],
        ),
      ),
    );
  }
}
