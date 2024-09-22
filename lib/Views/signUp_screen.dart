import 'package:chat_app_firebase/Utils/Helper/Database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_app_firebase/Utils/Helper/Auth_Helper.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> signUp() async {
    if (formKey.currentState!.validate()) {
      String email = emailController.text;
      String password = passwordController.text;

      Map<String, dynamic> res = await AuthHelper.authHelper.signUpWithEmail(
        email: email,
        password: password,
      );

      if (res['user'] != null) {
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        Get.snackbar(
          "Sign Up Successful",
          "Go and Sign in!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFA26769),
          colorText: Colors.white,
        );
        User user = res['user'];
        await DatabaseHelper.databaseHelper
            .addAuthenticatedUser(email: user.email!);
      } else if (res['error'] != null) {
        Get.snackbar(
          "Sign Up Failed",
          res['error'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> signUpWithGoogle() async {
    Map<String, dynamic> res = await AuthHelper.authHelper.googleUserLogin();

    if (res['user'] != null) {
      Get.offAllNamed('/');
      Get.snackbar(
        "Google Sign Up",
        "Signed up with Google",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFD5B9B2),
        colorText: Colors.white,
      );

      User user = res['user'];
      await DatabaseHelper.databaseHelper
          .addAuthenticatedUser(email: user.email!);
    } else if (res['error'] != null) {
      Get.snackbar(
        "Sign Up Failed",
        res['error'],
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBFB5AF),
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: const Color(0xFFA26769),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    "Create an Account",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF582C4D),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: const TextStyle(color: Color(0xFF582C4D)),
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: Color(0xFF582C4D)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF582C4D)),
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
                      labelStyle: const TextStyle(color: Color(0xFF582C4D)),
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: Color(0xFF582C4D)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF582C4D)),
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
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      labelStyle: const TextStyle(color: Color(0xFF582C4D)),
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: Color(0xFF582C4D)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF582C4D)),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please confirm your password";
                      } else if (value != passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: signUp,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD5B9B2), Color(0xFFA26769)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA26769).withOpacity(0.4),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Text(
                        "Sign Up",
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
                      onTap: () {
                        Get.offNamed('/LoginScreen');
                      },
                      child: const Text(
                        "Already have an account? Log in",
                        style: TextStyle(
                          color: Color(0xFF582C4D),
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Or sign up with:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF582C4D),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: signUpWithGoogle,
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
                          Icon(Icons.email_outlined, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            "Google",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
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
