import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class ShowNotificationFromFirebasePanelHelper {
  ShowNotificationFromFirebasePanelHelper._();
  static final ShowNotificationFromFirebasePanelHelper
      showNotificationFromFirebasePanelHelper =
      ShowNotificationFromFirebasePanelHelper._();

  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  // Fetch FCM registration token
  Future<String?> getUserFCMToken() async {
    String? getToken = await firebaseMessaging.getToken();

    log("==========");
    log("FCM Token:- $getToken");
    log("==========");

    return getToken;
  }

  // Get access token for sending notifications via Firebase
  Future<String> getAccessToken() async {
    final accountCredentials = ServiceAccountCredentials.fromJson(
      await rootBundle.loadString(
          'assets/chat-app-firebase-44f57-firebase-adminsdk-2p75g-b2df19a24a.json'),
    );
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final authClient =
        await clientViaServiceAccount(accountCredentials, scopes);
    return authClient.credentials.accessToken.data;
  }

  // Send FCM notification
  Future<void> sendFCM(
      {required String title,
      required String body,
      required String token}) async {
    // String? token = await getUserFCMToken();
    final String accessToken = await getAccessToken();
    const String fcmUrl =
        'https://fcm.googleapis.com/v1/projects/chat-app-firebase-44f57/messages:send';

    final Map<String, dynamic> myBody = {
      'message': {
        'token': token,
        'notification': {
          'title': title,
          'body': body,
        },
      },
    };

    final response = await http.post(
      Uri.parse(fcmUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode(myBody),
    );

    if (response.statusCode == 200) {
      print('-------------------');
      print('Notification sent successfully');
      print('-------------------');
    } else {
      print('-------------------');
      print('Failed to send notification: ${response.body}');
      print('-------------------');
    }
  }
}
