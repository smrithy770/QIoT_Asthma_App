import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:asthmaapp/services/permission_service.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';

class NotificationAccessScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const NotificationAccessScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<NotificationAccessScreen> createState() =>
      _NotificationAccessScreenState();
}

class _NotificationAccessScreenState extends State<NotificationAccessScreen> {
  UserModel? userModel;
  final PermissionService _permissionService =
      PermissionService(); // Create an instance of PermissionService
  bool _isLoading = false;

  void _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
    });

    bool permissionGranted = await _permissionService.notificationPermission();

    setState(() {
      _isLoading = false;
    });

    // Handle different permission statuses
    if (permissionGranted) {
      // Permission granted
      // Navigate or proceed to the next step
      logger.d('Notification permission granted.');
      CustomSnackBarUtil.showCustomSnackBar('Notification permission granted.',
          success: true);
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/peakflow_notification_settings_screen', // Named route
        (Route<dynamic> route) => false, // This removes all previous routes
        arguments: {
          'realm': widget.realm,
          'deviceToken': widget.deviceToken,
          'deviceType': widget.deviceType,
        },
      );
      // Proceed with navigation or any other action
    } else {
      // Permission denied forever, user has to manually enable it
      logger.d('Notification permission denied.');
      CustomSnackBarUtil.showCustomSnackBar('Notification permission denied.',
          success: true);
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
        child: Stack(
          children: [
            Center(
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
                      SizedBox(height: screenRatio * 20),
                      SvgPicture.asset(
                        'assets/svgs/user_assets/notifications.svg',
                        width: screenRatio * 52,
                      ),
                      SizedBox(height: screenSize.height * 0.08),
                      SizedBox(
                        width: screenSize.width,
                        height: screenRatio * 32,
                        child: Text(
                          'Turn on Notifications?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryBlueText,
                            fontSize: screenRatio * 9,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      SizedBox(
                        width: screenSize.width,
                        height: screenRatio * 32,
                        child: Text(
                          'In order to remind you to complete peakflow \n tests we need you to turn on your notifications.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryGreyText,
                            fontSize: screenRatio * 7,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      SizedBox(
                        width: screenSize.width,
                        child: ElevatedButton(
                          onPressed: () async {
                            _requestLocationPermission();
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(
                              screenRatio * 16,
                              screenRatio * 24,
                            ),
                            foregroundColor: AppColors.primaryWhite,
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenRatio * 8,
                              vertical: screenRatio * 4,
                            ),
                          ),
                          child: Text(
                            'Yes, turn on notifications',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 8 * screenRatio,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.16),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/edit_profile_screen', // Named route
                            (Route<dynamic> route) =>
                                true, // This removes all previous routes
                            arguments: {
                              'realm': widget.realm,
                              'deviceToken': widget.deviceToken,
                              'deviceType': widget.deviceType,
                            },
                          );
                        },
                        child: Text(
                          'Not at the moment',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.primaryLightBlueText,
                            fontSize: screenRatio * 8,
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
            if (_isLoading)
              Center(
                child: Container(
                  width: screenRatio * 32,
                  height: screenRatio * 32,
                  padding: EdgeInsets.all(screenRatio * 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryWhite.withOpacity(1.0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const CircularProgressIndicator(
                    backgroundColor: AppColors.primaryWhite,
                    color: AppColors.primaryBlue,
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
