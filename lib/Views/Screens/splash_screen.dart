import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      _navigateToHomeScreen();
    }
  }

  void _navigateToLoginScreen() async {
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  void _navigateToHomeScreen() async {
    // Assuming the user is logged in, fetch the current user
    User? user = FirebaseAuth.instance.currentUser;

    await Future.delayed(const Duration(seconds: 3), () {
      if (user != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
            settings: RouteSettings(arguments: user),
          ),
          (route) => false,
        );
      } else {
        _navigateToLoginScreen();
      }
    });
  }

  Future<void> _getStarted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    _navigateToLoginScreen();
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
