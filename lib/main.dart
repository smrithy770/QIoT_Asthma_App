import 'dart:io';

import 'package:asthmaapp/models/user_model.dart';
import 'package:asthmaapp/routes/router_provider.dart';
import 'package:asthmaapp/routes/routes.dart';
import 'package:asthmaapp/screens/authentication_screens/signin_screen/signin_screen.dart';
import 'package:asthmaapp/screens/home_screen/home_screen.dart';
import 'package:asthmaapp/screens/splash_screen/splash_screen.dart';
import 'package:asthmaapp/services/analytics_service.dart';
import 'package:asthmaapp/services/push_notification_service.dart';
import 'package:asthmaapp/services/token_refresh_service.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:realm/realm.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future _firebaseBackgroundMessageHandler(RemoteMessage message) async {
  if (message.notification != null) {
    print('Message received in the background!');
  }
}

void main() async {
  final router = FluroRouter();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Initialize Realm configuration
  final config = Configuration.local([
    UserModel.schema,
  ]);
  final realm = Realm(config);
  UserModel? userModel;
  final results = realm.all<UserModel>();
  if (results.isNotEmpty) {
    userModel = results[0];
  }
  await PushNotificationService.initialize();
  await AnalyticsService.initialize();
  await PushNotificationService.localNotificationInit();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);
  PushNotificationService.onNotificationTapBackground();
  PushNotificationService.onNotificationTapForeground();
  PushNotificationService.onNotificationTerminatedState();

  if (userModel != null) {
    // Replace with your actual device token and device type fetching logic
    String deviceToken = "your_device_token";
    String deviceType = "your_device_type";

    TokenRefreshService().initialize(realm, userModel, deviceToken, deviceType);
  }

  defineRoutes(router);
  runApp(
    RouterProvider(
      router: router,
      child: Main(
        realm: realm,
        userModel: userModel,
        router: router,
      ),
    ),
  );
}

class Main extends StatefulWidget {
  final Realm realm;
  final UserModel? userModel;
  final FluroRouter router;
  const Main({
    super.key,
    required this.realm,
    required this.userModel,
    required this.router,
  });

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  bool _initialized = false;
  String? _deviceToken = '';
  String? _deviceType = '';
  UserModel? getUserData(Realm realm) {
    final results = realm.all<UserModel>();
    if (results.isNotEmpty) {
      return results[0];
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2)).then((value) {
      _getDeviceToken();
    });
  }

  Future<void> _getDeviceToken() async {
    String? deviceToken = await PushNotificationService.getDeviceToken();
    if (Platform.isAndroid) {
      setState(() {
        _deviceToken = deviceToken;
        _initialized = true;
        _deviceType = 'android';
      });
    } else if (Platform.isIOS) {
      setState(() {
        _deviceToken = deviceToken;
        _initialized = true;
        _deviceType = 'ios';
      });
    }

    if (widget.userModel != null && _initialized) {
      _startTokenRefreshService();
    }
  }

  void _startTokenRefreshService() {
    // Initialize the TokenRefreshService
    TokenRefreshService().initialize(
        widget.realm, widget.userModel!, _deviceToken!, _deviceType!);
  }

  @override
  void dispose() {
    TokenRefreshService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: CustomSnackBarUtil.rootScaffoldMessengerKey,
      navigatorKey: navigatorKey,
      title: 'QIoT',
      onGenerateRoute: widget.router.generator,
      home: initialNavigation(),
    );
  }

  Widget initialNavigation() {
    UserModel? userModel = getUserData(widget.realm);
    if (_initialized) {
      return userModel?.id != null
          ? RouterProvider(
              router: widget.router,
              child: HomeScreen(
                realm: widget.realm,
                deviceToken: _deviceToken,
                deviceType: _deviceType,
              ),
            )
          : RouterProvider(
              router: widget.router,
              child: SigninScreen(
                realm: widget.realm,
                deviceToken: _deviceToken,
                deviceType: _deviceType,
              ),
            );
    } else {
      return const SplashScreen();
    }
  }
}
