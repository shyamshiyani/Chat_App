import 'dart:developer';
import 'package:chat_app_firebase/Utils/Helper/Database_helper.dart';
import 'package:chat_app_firebase/Utils/Helper/Show_notification_from_firebase_panel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Add the intl package

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final TextEditingController updatedMessageController =
      TextEditingController();
  String? msg;
  String? updatedMassage;

  // Function to format time difference
  String getTimeDifference(Timestamp timestamp) {
    DateTime messageTime = timestamp.toDate();
    Duration difference = DateTime.now().difference(messageTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return DateFormat.yMMMd()
          .format(messageTime); // Display date for older messages
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? receiver =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (receiver == null || receiver['email'] == null) {
      return const Center(child: Text("Receiver data is not available."));
    }

    // Define the colors for TalkNest's theme
    Color primaryColor = const Color(0xFF582C4D);
    Color accentColor = const Color(0xFFA26769);
    Color backgroundColor = const Color(0xFFBFB5AF);
    Color messageSentColor = const Color(0xFFD5B9B2);
    Color messageReceivedColor = const Color(0xFFECE2D0);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(receiver['email']),
        centerTitle: false,
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 12,
            child: FutureBuilder(
                future: DatabaseHelper.databaseHelper
                    .fetchAllChats(receiverEmail: receiver['email']),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text("No Data Found: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    Stream<QuerySnapshot<Map<String, dynamic>>>? data =
                        snapshot.data;

                    return StreamBuilder(
                        stream: data,
                        builder: (context, ss) {
                          if (ss.hasError) {
                            return Center(
                                child: Text("No data Found: ${ss.error}"));
                          } else if (ss.hasData) {
                            QuerySnapshot<Map<String, dynamic>>? data = ss.data;
                            List<QueryDocumentSnapshot<Map<String, dynamic>>>
                                allMessages = (data == null) ? [] : data.docs;

                            // Show "No chats found" if the list is empty
                            if (allMessages.isEmpty) {
                              return const Center(
                                child: Text(
                                  "No chats found",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500),
                                ),
                              );
                            }

                            return ListView.builder(
                              reverse: true,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              itemBuilder: (context, index) {
                                bool isSender = receiver['email'] !=
                                    allMessages[index].data()['receiverEmail'];

                                Timestamp timestamp =
                                    allMessages[index].data()['timestamp'];
                                String timeDifference =
                                    getTimeDifference(timestamp);

                                return Column(
                                  crossAxisAlignment: isSender
                                      ? CrossAxisAlignment.start
                                      : CrossAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 14),
                                        decoration: BoxDecoration(
                                          color: isSender
                                              ? messageSentColor
                                              : messageReceivedColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${allMessages[index].data()['msg']}",
                                              style: TextStyle(
                                                color: isSender
                                                    ? primaryColor
                                                    : accentColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8, bottom: 8),
                                      child: Text(
                                        timeDifference,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              itemCount: allMessages.length,
                            );
                          }
                          return const Center(
                              child: CircularProgressIndicator());
                        });
                  }
                  return const Center(child: CircularProgressIndicator());
                }),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () async {
                    String? senderEmail =
                        await DatabaseHelper.databaseHelper.senderEmail();
                    msg = messageController.text.trim();

                    if (msg != null && msg!.isNotEmpty) {
                      messageController.clear();
                      DatabaseHelper.databaseHelper.sendMassages(
                          msg: msg!, receiverEmail: receiver['email']);
                      await ShowNotificationFromFirebasePanelHelper
                          .showNotificationFromFirebasePanelHelper
                          .sendFCM(
                              title: msg!,
                              body: senderEmail!,
                              token: receiver['FCMtoken']);
                      DatabaseHelper.databaseHelper
                          .fetchAllChats(receiverEmail: senderEmail);
                    } else {
                      Get.snackbar(
                        "Error",
                        "Message cannot be empty",
                        duration: Duration(seconds: 1),
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                    setState(() {});
                  },
                  backgroundColor: (msg == null || msg!.isEmpty)
                      ? Colors.deepPurple[100]
                      : primaryColor,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
