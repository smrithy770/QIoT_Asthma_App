import 'dart:io';

import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:asthmaapp/routes/router_provider.dart';
import 'package:asthmaapp/routes/routes.dart';
import 'package:asthmaapp/screens/authentication_screens/signin_screen/signin_screen.dart';
import 'package:asthmaapp/screens/user_ui/home_screen/home_screen.dart';
import 'package:asthmaapp/screens/splash_screen/splash_screen.dart';
import 'package:asthmaapp/services/analytics_service.dart';
import 'package:asthmaapp/services/push_notification_service.dart';
import 'package:asthmaapp/services/token_refresh_service.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
import 'package:realm/realm.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final Logger logger = Logger();

Future _firebaseBackgroundMessageHandler(RemoteMessage message) async {
  if (message.notification != null) {
    logger.d('Message received in the background!');
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

  // Fetch stored user data from Realm
  UserModel? userModel;
  final results = realm.all<UserModel>();
  if (results.isNotEmpty) {
    userModel = results[0];
  }

  // Initialize various services
  await PushNotificationService.initialize();
  await AnalyticsService.initialize();
  await PushNotificationService.localNotificationInit();

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);
  PushNotificationService.onNotificationTapBackground();
  PushNotificationService.onNotificationTapForeground();
  PushNotificationService.onNotificationTerminatedState();

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

class _MainState extends State<Main> with WidgetsBindingObserver{
  bool _isDeviceTokenInitialized = false;
  bool _isRefreshTokenRefreshed = false;
  String? _deviceToken = '';
  String? _deviceType = '';
  bool _isLoading = true; // Added loading state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(const Duration(seconds: 2)).then((value) {
      _getDeviceToken();
    });
  }

  Future<void> _getDeviceToken() async {
    // Fetch the device token
    String? deviceToken = await PushNotificationService.getDeviceToken();
    logger.d('Device Token: $deviceToken');
    if (Platform.isAndroid) {
      setState(() {
        _deviceToken = deviceToken;
        _isDeviceTokenInitialized = true;
        _deviceType = 'android';
      });
    } else if (Platform.isIOS) {
      setState(() {
        _deviceToken = deviceToken;
        _isDeviceTokenInitialized = true;
        _deviceType = 'ios';
      });
    }

    // Pass the token and other details to PushNotificationService
    if (_isDeviceTokenInitialized) {
      PushNotificationService.setDeviceDetails(
        realm: widget.realm,
        deviceToken: _deviceToken!,
        deviceType: _deviceType!,
      );
    }

    // Start TokenRefreshService once device token is available
    if (widget.userModel != null && _isDeviceTokenInitialized) {
      _startTokenRefreshService();
    } else {
      setState(() {
        _isLoading = false; // Set loading to false once done
      });
    }
  }

  Future<void> _startTokenRefreshService() async {
    // Initialize TokenRefreshService
    TokenRefreshService().initialize(
        widget.realm, widget.userModel!, _deviceToken!, _deviceType!);

    // Refresh the token and update the state
    bool isRefreshed = await TokenRefreshService().refreshToken();
    setState(() {
      _isRefreshTokenRefreshed = isRefreshed;
      _isLoading = false; // Set loading to false once done
    });
  }

  

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      logger.d("App moved to forefround.");
      if (_isDeviceTokenInitialized && widget.userModel != null) {
        TokenRefreshService().refreshToken();
      }
    } else if (state == AppLifecycleState.paused) {
      logger.d("App moved to background.");
    }
  }

  @override
  void dispose() {
    TokenRefreshService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    logger.d('Screen Height: ${screenSize.height}');
    logger.d('Screen Width: ${screenSize.width}');
    logger.d('Screen Ratio: $screenRatio');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: CustomSnackBarUtil.rootScaffoldMessengerKey,
      navigatorKey: navigatorKey,
      title: 'QIoT',
      onGenerateRoute: widget.router.generator,
      home: _isLoading
          ? const SplashScreen() // Show SplashScreen while loading
          : initialNavigation(), // Navigate based on token status
    );
  }

  // Initial navigation logic based on user login and token status
  Widget initialNavigation() {
    UserModel? userModel = getUserData(widget.realm);
    if (_isDeviceTokenInitialized) {
      return userModel?.userId != null && _isRefreshTokenRefreshed
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

  // Helper to get user data from Realm
  UserModel? getUserData(Realm realm) {
    final results = realm.all<UserModel>();
    return results.isNotEmpty ? results[0] : null;
  }
}
