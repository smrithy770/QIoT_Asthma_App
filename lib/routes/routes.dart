import 'package:asthmaapp/screens/authentication_screens/signin_screen/signin_screen.dart';
import 'package:asthmaapp/screens/authentication_screens/signup_screen/signup_screen.dart';
import 'package:asthmaapp/screens/home_screen/home_screen.dart';
import 'package:asthmaapp/screens/notification_screen/notification_screen.dart';
import 'package:asthmaapp/screens/splash_screen/splash_screen.dart';
import 'package:fluro/fluro.dart';
import 'package:realm/realm.dart';

void defineRoutes(FluroRouter router) {
  router.define(
    '/splash',
    handler: Handler(
      handlerFunc: (context, params) {
        return const SplashScreen();
      },
    ),
  );
  router.define(
    '/signin',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return SigninScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/signup',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return SignupScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/home',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return HomeScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/notification',
    handler: Handler(
      handlerFunc: (context, params) {
        return const NotificationScreen();
      },
    ),
  );
}
