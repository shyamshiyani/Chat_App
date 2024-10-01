import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chat_app_firebase/Utils/Helper/Database_helper.dart';
import 'package:chat_app_firebase/Utils/Helper/Auth_Helper.dart';
import 'package:chat_app_firebase/Views/components/drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void signOut() async {
    await AuthHelper.authHelper.signOutUser();
    Navigator.of(context).pushReplacementNamed('/LoginScreen');
  }

  void showEditProfileDialog(User user) {
    final emailController = TextEditingController(text: user.email);
    final nameController = TextEditingController(text: user.displayName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await DatabaseHelper.databaseHelper.updateUserProfile(
                  userId: user.uid,
                  email: emailController.text,
                  displayName: nameController.text,
                );
                Navigator.of(context).pop();
                setState(() {});
              },
              child: Text("Save"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = ModalRoute.of(context)!.settings.arguments as User?;

    if (user == null) {
      return Center(child: Text("User not found!"));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "TalkNest",
          style: GoogleFonts.pacifico(fontSize: 24),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () => showEditProfileDialog(user),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: (user.photoURL == null)
                  ? CircleAvatar(
                      radius: 35,
                      child: Icon(Icons.person),
                    )
                  : CircleAvatar(
                      backgroundImage: NetworkImage("${user.photoURL}"),
                    ),
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF582C4D), Color(0xFFA26769)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: Drawer_Widget(user: user),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFECE2D0), Color(0xFFBFB5AF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF582C4D)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
                onChanged: (value) {
                  // Implement search logic here
                },
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: DatabaseHelper.databaseHelper.fetchAllUsers(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "ERROR: ${snapshot.error}",
                        style: TextStyle(color: Color(0xFF582C4D)),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    QuerySnapshot<Map<String, dynamic>>? data = snapshot.data;
                    List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
                        (data == null) ? [] : data.docs;

                    return ListView.builder(
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).pushNamed('/ChatScreen',
                                  arguments: allDocs[index].data());
                            },
                            leading: CircleAvatar(
                              backgroundColor: Color(0xFFA26769),
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              (allDocs[index].data()['email'] ==
                                      AuthHelper
                                          .firebaseAuth.currentUser!.email)
                                  ? "You"
                                  : "User ${index + 1}",
                              style: GoogleFonts.openSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              (allDocs[index].data()['email'] ==
                                      AuthHelper
                                          .firebaseAuth.currentUser!.email)
                                  ? "You (${allDocs[index].data()['email']})"
                                  : allDocs[index].data()['email'],
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        );
                      },
                      itemCount: allDocs.length,
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
