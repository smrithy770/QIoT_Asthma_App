import 'dart:async';
import 'dart:io';

import 'package:asthmaapp/api/auth_api.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';

class ThankYouScreen extends StatefulWidget {
  final Realm realm;
  final String email;
  final String? deviceToken, deviceType;
  const ThankYouScreen({
    super.key,
    required this.realm,
    required this.email,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<ThankYouScreen> createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends State<ThankYouScreen> {
  UserModel? userModel;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _startTimerLoop();
  }

  Future<void> _loadUserData() async {
    final user = getUserData(widget.realm);
    if (user != null) {
      setState(() {
        userModel = user;
      });
    }
  }

  UserModel? getUserData(Realm realm) {
    final results = realm.all<UserModel>();
    if (results.isNotEmpty) {
      return results[0];
    }
    return null;
  }

  /// Function to check the user's verification status
  Future<void> _checkVerification() async {
    try {
      final response = await AuthApi().checkVerification(widget.email);
      final jsonResponse = response;
      final isVerified = jsonResponse['verified'];

      if (isVerified == true) {
        // Stop the loop if the user is verified
        _timer?.cancel();
        CustomSnackBarUtil.showCustomSnackBar(
          'Your email has been verified successfully!',
          success: true,
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/verified_screen', // Named route
          (Route<dynamic> route) => false, // This removes all previous routes
          arguments: {
            'realm': widget.realm,
            'deviceToken': widget.deviceToken,
            'deviceType': widget.deviceType,
          },
        );
      }
    } on SocketException catch (e) {
      logger.d('NetworkException: $e');
      CustomSnackBarUtil.showCustomSnackBar(
        'Network error: Please check your internet connection',
        success: false,
      );
    } on Exception catch (e) {
      logger.d('Exception: $e');
      CustomSnackBarUtil.showCustomSnackBar(
        'Failed to check verification status!',
        success: false,
      );
    }
  }

  /// Starts a timer that checks the verification status every 10 seconds
  void _startTimerLoop() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _checkVerification();
    });
  }

  void _resendVerificationEmail() async {
    // if (userModel == null) return;
    logger.d('Resend verification email');
    try {
      final response = await AuthApi().resendVerificationEmail(
        widget.email,
      );
      final jsonResponse = response;
      final status = jsonResponse['status'];

      if (status == 200) {
        CustomSnackBarUtil.showCustomSnackBar(
          'Verification email sent successfully!',
          success: true,
        );
      } else {
        // Handle different statuses
        String errorMessage;
        switch (status) {
          case 400:
            errorMessage = 'Bad request: Please check your input';
            break;
          case 500:
            errorMessage = 'Server error: Please try again later';
            break;
          default:
            errorMessage = 'Unexpected error: Please try again';
        }

        // Show error message
        CustomSnackBarUtil.showCustomSnackBar(errorMessage, success: false);
      }
    } on SocketException catch (e) {
      // Handle network-specific exceptions
      logger.d('NetworkException: $e');
      CustomSnackBarUtil.showCustomSnackBar(
          'Network error: Please check your internet connection',
          success: false);
    } on Exception catch (e) {
      // Handle generic exceptions
      logger.d('Exception: $e');
      CustomSnackBarUtil.showCustomSnackBar(
        'Failed to send verification email!',
        success: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Center(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              color: AppColors.primaryWhite,
              width: screenSize.width,
              height: screenSize.height,
              padding: EdgeInsets.all(screenRatio * 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/svgs/user_assets/verification-shield.svg',
                    width: screenRatio * 64, // Adjust width as needed
                    height: screenRatio * 64, // Adjust height as needed
                  ),
                  SizedBox(height: screenSize.height * 0.08),
                  SizedBox(
                    width: screenSize.width,
                    height: screenRatio * 16,
                    child: Text(
                      'Thank You for signing up!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryBlueText,
                        fontSize: screenRatio * 9,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  SizedBox(
                    width: screenSize.width * 0.8,
                    height: screenRatio * 24,
                    child: Text(
                      'We are almost there. We have sent a Verification link to your registered email address. Please verify it by clicking on the link.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryGreyText,
                        fontSize: screenRatio * 6,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.08),
                  TextButton(
                    onPressed: () {
                      _resendVerificationEmail();
                    },
                    child: Text(
                      'Didn\'t receive the email? Resend',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.primaryLightBlueText,
                        fontSize: screenRatio * 6,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
