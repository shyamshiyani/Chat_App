import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ShowNotificationHelper {
  ShowNotificationHelper._();
  static final ShowNotificationHelper showNotificationHelper =
      ShowNotificationHelper._();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  //initialization notification
  initNotifications() async {
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('mipmap/ic_launcher');

    DarwinInitializationSettings iOSInitializationSettings =
        const DarwinInitializationSettings();
    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  //show simple notification
  showSimpleNotification({required String title, required String body}) async {
    await initNotifications();
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      title,
      body,
      priority: Priority.max,
      importance: Importance.max,
    );
    DarwinNotificationDetails iOSNotificationDetails =
        const DarwinNotificationDetails();
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: "Redirect on massages",
    );
  }

  //show Scheduled notification
  showScheduledNotification() async {
    await initNotifications();
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      "Show Simple Notification",
      "SSN",
      priority: Priority.max,
      importance: Importance.max,
    );
    DarwinNotificationDetails iOSNotificationDetails =
        const DarwinNotificationDetails();
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
        0, "Chat App", "You have a new Massage", notificationDetails,
        payload: "Redirect on massages");
  }

  //show Media Style notification
  showMediaStyleNotification() async {
    await initNotifications();
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      "Show Simple Notification",
      "SSN",
      priority: Priority.max,
      importance: Importance.max,
      largeIcon: DrawableResourceAndroidBitmap("mipmap/ic_launcher"),
      styleInformation: MediaStyleInformation(),
    );
    DarwinNotificationDetails iOSNotificationDetails =
        const DarwinNotificationDetails();
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
        0, "Chat App", "You have a new Massage", notificationDetails,
        payload: "Redirect on massages");
  }

  //show big Picture notification
  showBigPictureNotification() async {
    await initNotifications();
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      "Show Simple Notification",
      "SSN",
      priority: Priority.max,
      importance: Importance.max,
      styleInformation: BigPictureStyleInformation(
          DrawableResourceAndroidBitmap("mipmap/ic_launcher")),
    );
    DarwinNotificationDetails iOSNotificationDetails =
        const DarwinNotificationDetails();
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
        0, "Chat App", "You have a new Massage", notificationDetails,
        payload: "Redirect on massages");
  }
}
