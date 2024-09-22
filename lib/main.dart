import 'dart:developer';

import 'package:chat_app_firebase/Utils/Helper/show_notification_helper.dart';
import 'package:chat_app_firebase/Views/Screens/splash_screen.dart';
import 'package:chat_app_firebase/Views/signUp_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'Views/Screens/Home_Screen.dart';
import 'Views/Screens/Login_Screen.dart';
import 'Views/Screens/chat_detail_Screen.dart';

@pragma('vm:entry-point')
Future<void> backgroundFCMMassage(RemoteMessage remoteMassage) async {
  log("============");
  log("Massage Title:- ${remoteMassage.notification!.title} ");
  log("Massage body:- ${remoteMassage.notification!.body} ");
  log("============");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  //foreground app state
  FirebaseMessaging.onMessage.listen((RemoteMessage remoteMassage) async {
    log("==========ForGroundNotification============");
    log("Massage Title:- ${remoteMassage.notification!.title} ");
    log("Massage body:- ${remoteMassage.notification!.body} ");
    log("============");

    await ShowNotificationHelper.showNotificationHelper.showSimpleNotification(
        title: remoteMassage.notification!.title! ?? "chatApp",
        body: remoteMassage.notification!.body!);
  }); //Background & Terminated app state
  FirebaseMessaging.onBackgroundMessage(backgroundFCMMassage);

  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      textTheme: GoogleFonts.poppinsTextTheme(),
    ),
    initialRoute: '/SplashScreen',
    getPages: [
      GetPage(
        name: '/',
        page: () => const HomeScreen(),
      ),
      GetPage(
        name: '/SplashScreen',
        page: () => SplashScreen(),
      ),
      GetPage(
        name: '/LoginScreen',
        page: () => const LoginScreen(),
      ),
      GetPage(
        name: '/SignUpScreen',
        page: () => const SignUpScreen(),
      ),
      GetPage(
        name: '/ChatScreen',
        page: () => const ChatScreen(),
      ),
    ],
  ));
}
