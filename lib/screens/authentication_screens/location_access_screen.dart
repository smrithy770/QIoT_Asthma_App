import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:asthmaapp/services/permission_service.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:realm/realm.dart';

class LocationAccessScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const LocationAccessScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<LocationAccessScreen> createState() => _LocationAccessScreenState();
}

class _LocationAccessScreenState extends State<LocationAccessScreen> {
  UserModel? userModel;
  final PermissionService _permissionService =
      PermissionService(); // Create an instance of PermissionService
  bool _isLoading = false;

  void _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
    });

    LocationPermission permission =
        await _permissionService.locationPermission();
    logger.d('Location Permission: $permission');

    setState(() {
      _isLoading = false;
    });

    // Handle different permission statuses
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      // Permission granted
      // Navigate or proceed to the next step
      logger.d('Location permission granted.');
      CustomSnackBarUtil.showCustomSnackBar('Location permission granted.',
          success: true);
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/notification_access_screen', // Named route
        (Route<dynamic> route) => false, // This removes all previous routes
        arguments: {
          'realm': widget.realm,
          'deviceToken': widget.deviceToken,
          'deviceType': widget.deviceType,
        },
      );
      // Proceed with navigation or any other action
    } else if (permission == LocationPermission.denied) {
      // Permission denied, show a message
      logger.d('Location permission denied.');
      CustomSnackBarUtil.showCustomSnackBar('Location permission denied.',
          success: true);
    } else if (permission == LocationPermission.deniedForever) {
      // Permission denied forever, user has to manually enable it
      logger.d('Location permission permanently denied.');
      CustomSnackBarUtil.showCustomSnackBar(
          'Location permission permanently denied. Please enable it in settings.',
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
                        'assets/svgs/user_assets/location.svg',
                        width: screenRatio * 52,
                      ),
                      SizedBox(height: screenSize.height * 0.08),
                      SizedBox(
                        width: screenSize.width,
                        height: screenRatio * 32,
                        child: Text(
                          'We would like to access your location',
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
                          'QIoT App requiress your location access in order to upload Pollen forecasts to your exact location(s).',
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
                            'Allow Location Access',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 8 * screenRatio,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Roboto',
                            ),
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
