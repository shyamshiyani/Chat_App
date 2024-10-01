import 'dart:developer';

import 'package:chat_app_firebase/Utils/Helper/Auth_Helper.dart';
import 'package:chat_app_firebase/Utils/Helper/Database_helper.dart';
import 'package:chat_app_firebase/Utils/Helper/Show_notification_from_firebase_panel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<void> requestPermission() async {
    PermissionStatus permissionStatus = await Permission.notification.request();
    log(permissionStatus.name);
  }

  @override
  void initState() {
    super.initState();
    ShowNotificationFromFirebasePanelHelper
        .showNotificationFromFirebasePanelHelper
        .getUserFCMToken();

    requestPermission();
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> login() async {
    if (formKey.currentState!.validate()) {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      Map<String, dynamic> res = await AuthHelper.authHelper.signInUser(
        email: email,
        password: password,
      );

      if (res['user'] != null) {
        Get.offAllNamed('/', arguments: res['user']);
        Get.snackbar(
          "Login Successful",
          "Welcome back!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFFA26769), // Primary color
          colorText: Colors.white,
        );
        User user = res['user'];
        await DatabaseHelper.databaseHelper
            .addAuthenticatedUser(email: user.email!);
      } else {
        Get.snackbar(
          "Login Failed",
          res['error'] ?? "An unknown error occurred",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFF582C4D), // Accent color
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> guestLogin() async {
    setState(() {});

    Map<String, dynamic> res = await AuthHelper.authHelper.guestUserLogin();

    if (res['user'] != null) {
      Get.offAllNamed('/', arguments: res['user']);
      Get.snackbar(
        "Guest Login",
        "Logged in as Guest",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFFD5B9B2), // Secondary color
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        "Login Error",
        res['error'] ?? "An unknown error occurred",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF582C4D), // Accent color
        colorText: Colors.white,
      );
    }
  }

  Future<void> googleLogin() async {
    setState(() {});

    Map<String, dynamic> res = await AuthHelper.authHelper.googleUserLogin();

    if (res['user'] != null) {
      Get.offAllNamed('/', arguments: res['user']);
      Get.snackbar(
        "Google Login",
        "Logged in with Google",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFFD5B9B2), // Secondary color
        colorText: Colors.white,
      );

      User user = res['user'];
      await DatabaseHelper.databaseHelper
          .addAuthenticatedUser(email: user.email!);
    } else {
      Get.snackbar(
        "Login Failed",
        res['error'] ?? "An unknown error occurred",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF582C4D), // Accent color
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECE2D0), // Background color
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Color(0xFFA26769), // Primary color
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA26769), // Primary color
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Sign in to your account",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: const TextStyle(
                          color: Color(0xFFA26769)), // Primary color
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: Color(0xFFA26769)), // Primary color
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFFA26769)), // Primary color
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFFA26769)), // Primary color
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter your email";
                      } else if (!value.contains('@') || !value.contains('.')) {
                        return "Please enter a valid email address";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(
                          color: Color(0xFFA26769)), // Primary color
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: Color(0xFFA26769)), // Primary color
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFFA26769)), // Primary color
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFFA26769)), // Primary color
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter your password";
                      } else if (value.length < 6) {
                        return "Password must be at least 6 characters long";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: login,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFA26769),
                            Color(0xFF582C4D)
                          ], // Gradient from Primary to Accent
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF582C4D)
                                .withOpacity(0.4), // Accent shadow
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () => Get.offNamed('/SignUpScreen'),
                      child: const Text(
                        "Don't have an account? Sign up",
                        style: TextStyle(
                          color: Color(0xFFA26769), // Primary color
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Or login with:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA26769), // Primary color
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: googleLogin,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.g_mobiledata_outlined, size: 28),
                                SizedBox(width: 8),
                                Text(
                                  "Google",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: guestLogin,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFD5B9B2),
                                  Color(0xFFA26769)
                                ], // Secondary to Primary gradient
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFA26769)
                                      .withOpacity(0.4), // Primary shadow
                                  offset: const Offset(0, 4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Text(
                              "Guest",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
