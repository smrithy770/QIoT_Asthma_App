import 'package:asthmaapp/screens/authentication_screens/signin_screen/signin_screen.dart';
import 'package:asthmaapp/screens/authentication_screens/signup_screen/signup_screen.dart';
import 'package:asthmaapp/screens/authentication_screens/terms_conditions/terms_conditions_screen.dart';
import 'package:asthmaapp/screens/user_ui/asthma_control_test_screen/asthma_control_test_result_screen.dart';
import 'package:asthmaapp/screens/user_ui/asthma_control_test_screen/asthma_control_test_screen.dart';
import 'package:asthmaapp/screens/user_ui/device_screen/device_screen.dart';
import 'package:asthmaapp/screens/user_ui/education_screen/education_screen.dart';
import 'package:asthmaapp/screens/user_ui/fitness_and_stress_screen/fitness_stress.dart';
import 'package:asthmaapp/screens/user_ui/home_screen/home_screen.dart';
import 'package:asthmaapp/screens/user_ui/notes_screen/add_notes_screen.dart';
import 'package:asthmaapp/screens/user_ui/notes_screen/edit_notes_screen.dart';
import 'package:asthmaapp/screens/user_ui/notes_screen/notes_screen.dart';
import 'package:asthmaapp/screens/user_ui/notification_screen/notification_screen.dart';
import 'package:asthmaapp/screens/splash_screen/splash_screen.dart';
import 'package:asthmaapp/screens/user_ui/peakflow_screen/peakflow_baseline_screen.dart';
import 'package:asthmaapp/screens/user_ui/peakflow_screen/peakflow_screen.dart';
import 'package:asthmaapp/screens/user_ui/profile_screen/profile_screen.dart';
import 'package:asthmaapp/screens/user_ui/report_screen/peakflow_report_screen/peakflow_report_screen.dart';
import 'package:asthmaapp/screens/user_ui/report_screen/report_screen.dart';
import 'package:asthmaapp/screens/user_ui/report_screen/steroid_dose_report_screen/steroid_dose_report_screen.dart';
import 'package:asthmaapp/screens/user_ui/steroid_dose_screen/steroid_dose_screen.dart';
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
    '/terms_conditions',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        String pathPDF = args['pathPDF'];
        return TermsConditionsScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
          pathPDF: pathPDF,
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
    '/peakflow_record_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return PeakflowScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/peakflow_record_result_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return PeakflowBaselineScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/steroid_dose_record',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return SteroidDoseScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/asthma_control_test_record_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return AsthmaControlTestScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/asthma_control_test_result_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return AsthmaControlTestResultScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/fitness_stress_record_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return FitnessStressScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/device_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return DeviceScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/notes_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return NotesScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/add_notes_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return AddNotesScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/edit_note_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String noteId = args['noteId'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return EditNotesScreen(
          realm: realm,
          noteId: noteId,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/reports_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return ReportsScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/peakflow_reports_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return PeakflowReportsScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/steroid_dose_report_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return SteroidDoseReportsScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/education_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        String path = args['path'];
        return EducationScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
          path: path,
        );
      },
    ),
  );
  router.define(
    '/profile',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return ProfileScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
}
