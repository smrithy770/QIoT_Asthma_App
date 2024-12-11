import 'package:asthmaapp/screens/about_screen/about_screen.dart';
import 'package:asthmaapp/screens/authentication_screens/additional_setup_screen.dart';
import 'package:asthmaapp/screens/authentication_screens/basic_details_screen.dart';
import 'package:asthmaapp/screens/authentication_screens/ice_screen.dart';
import 'package:asthmaapp/screens/authentication_screens/location_access_screen.dart';
import 'package:asthmaapp/screens/authentication_screens/notification_access_screen.dart';
import 'package:asthmaapp/screens/authentication_screens/peakflow_notification_settings_screen.dart';
import 'package:asthmaapp/screens/authentication_screens/signin_screen/signin_screen.dart';
import 'package:asthmaapp/screens/authentication_screens/signup_screen/signup_screen.dart';
import 'package:asthmaapp/screens/authentication_screens/terms_conditions/terms_conditions_screen.dart';
import 'package:asthmaapp/screens/authentication_screens/thank_you_screen.dart';
import 'package:asthmaapp/screens/authentication_screens/verified_screen.dart';
import 'package:asthmaapp/screens/user_ui/inhaler_screen/inhaler_screen.dart';
import 'package:asthmaapp/screens/user_ui/asthma_control_test_screen/asthma_control_test_result_screen.dart';
import 'package:asthmaapp/screens/user_ui/asthma_control_test_screen/asthma_control_test_screen.dart';
import 'package:asthmaapp/screens/user_ui/device_screen/device_screen.dart';
import 'package:asthmaapp/screens/user_ui/device_screen/pages/inhaler_cap_screen.dart';
import 'package:asthmaapp/screens/user_ui/device_screen/pages/peakflow_device_screen.dart';
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
import 'package:asthmaapp/screens/user_ui/pollen_screen/pollen_screen.dart';
import 'package:asthmaapp/screens/user_ui/profile_screen/edit_profile_screen.dart';
import 'package:asthmaapp/screens/user_ui/profile_screen/profile_screen.dart';
import 'package:asthmaapp/screens/user_ui/report_screen/asthma_control_test_report_screen/asthma_control_test_report_screen.dart';
import 'package:asthmaapp/screens/user_ui/report_screen/fitness_and_stress_report_screen/fitness_and_stress_report_screen.dart';
import 'package:asthmaapp/screens/user_ui/report_screen/inhaler_report_screen/inhaler_report_screen.dart';
import 'package:asthmaapp/screens/user_ui/report_screen/peakflow_report_screen/peakflow_report_screen.dart';
import 'package:asthmaapp/screens/user_ui/report_screen/report_screen.dart';
import 'package:asthmaapp/screens/user_ui/report_screen/steroid_dose_report_screen/steroid_dose_report_screen.dart';
import 'package:asthmaapp/screens/user_ui/steroid_dose_screen/steroid_dose_screen.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:realm/realm.dart';

import '../screens/authentication_screens/otp_screen/OTPScreen.dart';
import '../screens/authentication_screens/forgot_password/forgot_password.dart';
import '../screens/authentication_screens/reset_password/reset_password.dart';
import '../screens/authentication_screens/signup_otp_verify/signup_otp_verify.dart';
import '../screens/user_ui/change_password/change_password.dart';

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
    '/forgot_password',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        // Always navigate to ForgotPasswordMailScreen without checking for arguments
        return ForgotPasswordScreen(email: '', accessToken: '',
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );

      },
    ),
  );

  router.define(
    '/reset_password',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String email = args['email'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return ResetPasswordScreen(email: email, accessToken: '',
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,); // Navigate to reset password screen
      },
    ),
  );

  router.define(
    '/otp_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>?;

        if (args == null) {
          return Scaffold(
            body: Center(child: Text('Invalid arguments passed to OTP screen')),
          );
        }

        String email = args['email'] ?? ''; // Provide default values
        Realm realm = args['realm'] as Realm;
        String deviceToken = args['deviceToken'] ?? '';
        String deviceType = args['deviceType'] ?? '';

        return OTPScreen(
          email: email,
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
    '/thank_you_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String email = args['email'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return ThankYouScreen(
          realm: realm,
          email: email,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/verified_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return VerifiedScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/additional_setup_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return AdditionalSetupScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/basic_details_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return BasicDetailsScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/location_access_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return LocationAccessScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/notification_access_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return NotificationAccessScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/peakflow_notification_settings_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return PeakflowNotificationSettingsScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/ice_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return ICEScreen(
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
  // Home Screen
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
  // Peakflow Record Screen
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
  // Peakflow Record Result Screen
  router.define(
    '/peakflow_record_result_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        int peakflowValue = args['peakflowValue'];
        int baseLineScore = args['baseLineScore'];
        String practionerContact = args['practionerContact'];
        return PeakflowBaselineScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
          peakflowValue: peakflowValue,
          baseLineScore: baseLineScore,
          practionerContact: practionerContact,
        );
      },
    ),
  );
  // Inhaler Record Screen
  router.define(
    '/inhaler_record_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return InhalerScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  // Steroid Dose Record Screen
  router.define(
    '/steroid_dose_record',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        bool fromPeakflow = args['fromPeakflow'] ?? false;
        return SteroidDoseScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
          fromPeakflow: fromPeakflow,
        );
      },
    ),
  );
  // Asthma Control Test Record Screen
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
  // Asthma Control Test Record Result Screen
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
  // Fitness and Stress Record Screen
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
  // Device Screen
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
  // Inhaler Cap Screen
  router.define(
    '/inhaler_cap_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        BluetoothDevice inhalerDevice = args['inhalerDevice'];
        return InhalerCapScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
          inhalerDevice: inhalerDevice,
        );
      },
    ),
  );
  // Peakflow Device Screen
  router.define(
    '/peakflow_device_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        BluetoothDevice pefDevice = args['pefDevice'];
        return PeakflowDeviceScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
          pefDevice: pefDevice,
        );
      },
    ),
  );
  // Notes Screen
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
  // Add Notes Screen
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
  // Edit Notes Screen
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
  // Reports Screen
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
  // Peakflow Reports Screen
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
  // Inhaler Reports Screen
  router.define(
    '/inhaler_reports_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return InhalerReportScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  // Steroid Dose Reports Screen
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
  // Asthma Control Test Reports Screen
  router.define(
    '/asthma_control_test_report_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return AsthmaControlTestReportScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  // Fitness and Stress Reports Screen
  router.define(
    '/fitness_and_stress_report_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return FitnessAndStressReportScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  // Pollen Screen
  router.define(
    '/pollen_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return PollenScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  // Education Screen
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
  // About Screen
  router.define(
    '/about_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return AboutScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  // Profile Screen
  router.define(
    '/profile_screen',
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
  // Edit Profile Screen
  router.define(
    '/edit_profile_screen',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>;
        Realm realm = args['realm'];
        String deviceToken = args['deviceToken'];
        String deviceType = args['deviceType'];
        return EditProfileScreen(
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );
  router.define(
    '/change_password',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>?;
        Realm realm = args?['realm'];
        return ChangePasswordScreen(realm: realm, deviceToken: '', deviceType: '',
        );
      },
    ),
  );

  router.define(
    '/signup_otp_verify',
    handler: Handler(
      handlerFunc: (context, params) {
        final args = context?.settings?.arguments as Map<String, dynamic>?;

        if (args == null) {
          return Scaffold(
            body: Center(child: Text('Invalid arguments passed to OTP screen')),
          );
        }

        String email = args['email'] ?? ''; // Provide default values
        Realm realm = args['realm'] as Realm;
        String deviceToken = args['deviceToken'] ?? '';
        String deviceType = args['deviceType'] ?? '';

        return SignupOtpVerify(
          email: email,
          realm: realm,
          deviceToken: deviceToken,
          deviceType: deviceType,
        );
      },
    ),
  );

}
