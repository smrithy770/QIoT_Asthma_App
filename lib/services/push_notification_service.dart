import 'dart:convert';

import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/services/permission_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final PermissionService _permissionService = PermissionService();

  static Future<void> initialize() async {
    await _permissionService.notificationPermission();
  }

  static Future<String?> getDeviceToken({int retries = 3}) async {
    int attempt = 0;
    while (attempt < retries) {
      try {
        String? token = await _firebaseMessaging.getToken();
        return token;
      } catch (e) {
        attempt++;
        if (attempt >= retries) {
          throw Exception('Failed to get device token after $retries attempts: $e');
        }
        await Future.delayed(Duration(seconds: 2)); // Wait before retrying
      }
    }
    return null;
  }

  static Future localNotificationInit() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) {},
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // Check if _flutterLocalNotificationsPlugin is not null
    if (_flutterLocalNotificationsPlugin != null) {
      // request notification permissions for android 13 or above
      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: onNotificationTap,
      );
    } else {
      // Handle the case where _flutterLocalNotificationsPlugin is null
      print('Error: _flutterLocalNotificationsPlugin is null');
    }
  }

  // on tap local notification in foreground
  static void onNotificationTap(NotificationResponse notificationResponse) {
    Future.delayed(const Duration(seconds: 1), () {
      navigatorKey.currentState!.pushNamed(
        "/notification",
        arguments: notificationResponse,
      );
    });
  }

  static void onNotificationTapBackground() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('Message received in the background!');
        navigatorKey.currentState!.pushNamed(
          "/notification",
          arguments: message,
        );
      }
    });
  }

  static void onNotificationTapForeground() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String payloadData = jsonEncode(message.data);
      print('Message received in the foreground!');
      if (message.notification != null) {
        PushNotificationService.showSimpleNotification(
          title: message.notification!.title,
          body: message.notification!.body,
          payload: payloadData,
        );
      }
    });
  }

  static void onNotificationTerminatedState() async {
    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('Message received in terminated state!');
      Future.delayed(const Duration(seconds: 1), () {
        navigatorKey.currentState!.pushNamed(
          "/notification",
          arguments: initialMessage,
        );
      });
    }
  }

  // show a simple notification
  static Future showSimpleNotification({
    required String? title,
    required String? body,
    required String? payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
