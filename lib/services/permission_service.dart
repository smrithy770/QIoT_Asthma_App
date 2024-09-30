import 'package:asthmaapp/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PermissionService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> notificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      logger.d('User granted provisional permission');
    } else {
      logger.d('User declined or has not accepted permission');
    }
  }
}
