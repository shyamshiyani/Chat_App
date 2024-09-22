import 'package:chat_app_firebase/Utils/Helper/Auth_Helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path/path.dart';

class Drawer_Widget extends StatefulWidget {
  final User? user;

  Drawer_Widget({required this.user});

  @override
  State<Drawer_Widget> createState() => Drawer_WidgetState();
}

class Drawer_WidgetState extends State<Drawer_Widget> {
  File? image;

  // Color theme
  final Color primaryColor = const Color(0xFF582C4D);
  final Color accentColor = const Color(0xFFA26769);
  final Color backgroundColor = const Color(0xFFD5B9B2);

  @override
  void initState() {
    super.initState();
    loadStoredImage();
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = basename(pickedFile.path);
      final savedImage =
          await File(pickedFile.path).copy('${directory.path}/$fileName');

      setState(() {
        image = savedImage;
      });

      storeImagePath(savedImage.path);
    }
  }

  Future<void> storeImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
  }

  Future<void> loadStoredImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path');

    if (imagePath != null) {
      setState(() {
        image = File(imagePath);
      });
    }
  }

  Future<void> clearStoredImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_image_path'); // Clear stored image path
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return const Drawer(
        child: Center(
          child: Text("User not logged in"),
        ),
      );
    }

    String? img = widget.user!.photoURL;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
            child: Center(
              child: GestureDetector(
                onTap: pickImage,
                child: Stack(
                  children: [
                    (img == null)
                        ? CircleAvatar(
                            child: Icon(
                              Icons.person,
                              size: 70,
                            ),
                            radius: 70,
                          )
                        : CircleAvatar(
                            backgroundImage: image != null
                                ? FileImage(image!)
                                : (img != null ? NetworkImage(img) : null),
                            radius: 70,
                          ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text("Email: "),
              widget.user!.isAnonymous
                  ? const Text("No User Found")
                  : Text(widget.user!.email ?? "No Email Found"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text("User Name: "),
              widget.user!.isAnonymous
                  ? const Text("No User Found")
                  : Text(widget.user!.displayName ?? "No User Found"),
            ],
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                await AuthHelper.authHelper.signOutUser();
                await clearStoredImage();
                Navigator.of(context).pushReplacementNamed('/LoginScreen');
              },
              icon: const Icon(Icons.logout),
              label: const Text("Sign Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
