import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<bool> notificationPermission() async {
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
      print('User granted full permission');
      return true;
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
      return false;
    } else {
      print('User declined or has not accepted permission');
      return false;
    }
  }

  Future<bool> locationPermission() async {
    PermissionStatus status = await Permission.location.status;

    if (status.isDenied) {
      // Request permission
      status = await Permission.location.request();
    }
    if (status.isGranted) {
      print('User granted location permission');
      return true;
    } else if (status.isDenied) {
      print('User denied location permission');
      return false;
    } else if (status.isPermanentlyDenied) {
      print('User permanently denied location permission');
      // You can open app settings to let the user manually enable the permission
      openAppSettings();
      return false; // Add a return statement here
    } else if (status.isRestricted) {
      print('User restricted from granting location permission');
      return false;
    } else if (status.isLimited) {
      print('User granted limited location permission');
    }
    return false; // Add a return statement here
  }
}
