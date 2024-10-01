import 'dart:io';

import 'package:asthmaapp/api/fitness_and_stress_api.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model.dart';
import 'package:asthmaapp/screens/user_ui/fitness_and_stress_screen/widget/level_widget.dart';
import 'package:asthmaapp/screens/user_ui/widgets/custom_drawer.dart';
import 'package:asthmaapp/services/permission_service.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:realm/realm.dart';
import 'package:url_launcher/url_launcher.dart';

class FitnessStressScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const FitnessStressScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<FitnessStressScreen> createState() => _FitnessStressScreenState();
}

class _FitnessStressScreenState extends State<FitnessStressScreen> {
  UserModel? userModel;
  final PermissionService _permissionService =
      PermissionService(); // Create an instance of PermissionService
  Position? _currentPosition;
  String? _fitnessLevel;
  String? _stressLevel;
  DateTime? _lastSubmissionTime;
  bool _canSubmit = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _requestPermissions();
    _loadLastSubmissionTime();
  }

  Future<void> _requestPermissions() async {
    await _permissionService.locationPermission();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );
      // Store the location data
      setState(() {
        _currentPosition = position;
      });
      // Use the location data (latitude, longitude)
      logger.d('Current Location: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      // Handle location retrieval error
      CustomSnackBarUtil.showCustomSnackBar('Error retrieving location: $e',
          success: false);
    }
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
    return results.isNotEmpty ? results[0] : null;
  }

  Future<void> _loadLastSubmissionTime() async {
    // await storage.delete(key: 'last_submission_time');
    final timestampStr = await storage.read(key: 'last_submission_time');
    if (timestampStr != null) {
      logger.d('Timestamp: $timestampStr');
      final timestamp = int.tryParse(timestampStr);
      if (timestamp != null) {
        _lastSubmissionTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        logger.d('Last Submission Time: $_lastSubmissionTime');
        _checkSubmissionAvailability();
      }
    }
    logger.d('Timestamp: $timestampStr');
  }

  void _checkSubmissionAvailability() {
    if (_lastSubmissionTime != null) {
      final now = DateTime.now();
      final difference = now.difference(_lastSubmissionTime!);
      logger.d('Difference: ${difference.inHours}');
      if (difference.inHours < 24) {
        setState(() {
          _canSubmit = false;
        });
      }
    }
  }

  Future<void> _submitFitnessStress(String fitness, String stress) async {
    if (userModel == null) return;

    if (_canSubmit && _fitnessLevel != null && _stressLevel != null) {
      // Ensure location data is available
      if (_currentPosition == null) {
        CustomSnackBarUtil.showCustomSnackBar(
          'Unable to get location. Please enable location services.',
          success: false,
        );
        return;
      }

      try {
        final response = await FitnessAndStressApi().addFitnessAndStress(
          userModel!.userId,
          fitness,
          stress,
          {
            'type': 'Point',
            'coordinates': [
              _currentPosition!.longitude,
              _currentPosition!.latitude
            ],
          },
          DateTime.now().month,
          DateTime.now().year,
          userModel!.accessToken,
        );
        final jsonResponse = response;
        final status = jsonResponse['status'];
        if (status == 201) {
          CustomSnackBarUtil.showCustomSnackBar(
              "Fitness and Stress added successfully",
              success: true);
          final now = DateTime.now();
          await storage.write(
              key: 'last_submission_time',
              value: now.millisecondsSinceEpoch.toString());
          setState(() {
            _lastSubmissionTime = now;
            _canSubmit = false;
          });
          _reset();
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => const FitnessStressReportScreen(),
          //   ),
          // );
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
            'An error occurred while adding the note',
            success: false);
      }
    } else {
      // Show an error message
      CustomSnackBarUtil.showCustomSnackBar(
          'You can only submit once every 24 hours.',
          success: false);
    }
  }

  void _reset() {
    setState(() {
      _fitnessLevel = null;
      _stressLevel = null;
    });
  }

  void _onFitnessLevelChanged(String? value) {
    setState(() {
      _fitnessLevel = value;
    });
    logger.d('Fitness Level: $_fitnessLevel');
  }

  void _onStressLevelChanged(String? value) {
    setState(() {
      _stressLevel = value;
    });
    logger.d('Stress Level: $_stressLevel');
  }

  Future<void> openLink(String url) async {
    final Uri launchUri = Uri(
      scheme: 'https',
      host: url,
      path: '/',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.primaryWhite,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Fitness & Stress',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10 * screenRatio,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
      drawer: CustomDrawer(
        realm: widget.realm,
        deviceToken: widget.deviceToken,
        deviceType: widget.deviceType,
        onClose: () {
          Navigator.of(context).pop();
        },
        itemName: (String name) {
          logger.d(name);
        },
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Container(
              width: screenSize.width,
              padding: EdgeInsets.all(screenSize.height * 0.016),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: screenSize.width,
                    height: screenRatio * 40,
                    child: Text(
                      'Your fitness and stress levels can have an impact on your general and asthma health. Use this session to record your daily fitness and stress levels.',
                      textAlign: TextAlign.left,
                      softWrap: true,
                      style: TextStyle(
                        color: Color(0xFF707070),
                        fontSize: 7 * screenRatio,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.width * 0.01),
                  // Fitness
                  Container(
                    width: screenSize.width,
                    height: screenRatio * 78,
                    padding: EdgeInsets.all(screenSize.height * 0.01),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: screenSize.width * 0.16,
                              child: SvgPicture.asset(
                                'assets/svgs/user_assets/fitness.svg',
                                width: 48,
                              ),
                            ),
                            SizedBox(width: screenSize.width * 0.04),
                            SizedBox(
                              width: screenSize.width * 0.64,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fitness',
                                    style: TextStyle(
                                      color: Color(0xFF27AE60),
                                      fontSize: 9 * screenRatio,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  Text(
                                    'How active were you today?',
                                    style: TextStyle(
                                      color: Color(0xFF707070),
                                      fontSize: 7 * screenRatio,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenSize.height * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            LevelWidget(
                              widgetName: 'Fitness',
                              screenSize: screenSize,
                              level: 'Low',
                              groupValue: _fitnessLevel,
                              onChanged: _onFitnessLevelChanged,
                            ),
                            LevelWidget(
                              widgetName: 'Fitness',
                              screenSize: screenSize,
                              level: 'Medium',
                              groupValue: _fitnessLevel,
                              onChanged: _onFitnessLevelChanged,
                            ),
                            LevelWidget(
                              widgetName: 'Fitness',
                              screenSize: screenSize,
                              level: 'High',
                              groupValue: _fitnessLevel,
                              onChanged: _onFitnessLevelChanged,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.width * 0.01), // Stress
                  Container(
                    width: screenSize.width,
                    height: screenRatio * 88,
                    padding: EdgeInsets.all(screenSize.height * 0.01),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFD4646).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: screenSize.width * 0.16,
                              child: SvgPicture.asset(
                                'assets/svgs/user_assets/stress.svg',
                                width: 48,
                              ),
                            ),
                            SizedBox(width: screenSize.width * 0.04),
                            SizedBox(
                              width: screenSize.width * 0.64,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Stress',
                                    style: TextStyle(
                                      color: Color(0xFFFD4646),
                                      fontSize: 9 * screenRatio,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  Text(
                                    'How would you rate your stress level today?',
                                    softWrap: true,
                                    style: TextStyle(
                                      color: Color(0xFF707070),
                                      fontSize: 7 * screenRatio,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenSize.height * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            LevelWidget(
                              widgetName: 'Stress',
                              screenSize: screenSize,
                              level: 'Low',
                              groupValue: _stressLevel,
                              onChanged: _onStressLevelChanged,
                            ),
                            LevelWidget(
                              widgetName: 'Stress',
                              screenSize: screenSize,
                              level: 'Medium',
                              groupValue: _stressLevel,
                              onChanged: _onStressLevelChanged,
                            ),
                            LevelWidget(
                              widgetName: 'Stress',
                              screenSize: screenSize,
                              level: 'High',
                              groupValue: _stressLevel,
                              onChanged: _onStressLevelChanged,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  SizedBox(
                    width: screenSize.width,
                    height: screenSize.height * 0.08,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _canSubmit
                              ? () {
                                  logger.d(_canSubmit);
                                  _submitFitnessStress(
                                      _fitnessLevel!, _stressLevel!);
                                }
                              : null,
                          // onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(screenSize.width * 0.32,
                                screenSize.height * 0.08),
                            foregroundColor: AppColors.primaryWhite,
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                          ),
                          child: Text(
                            'Submit',
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 7 * screenRatio,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                        SizedBox(width: screenSize.width * 0.02),
                        _fitnessLevel == null && _stressLevel == null
                            ? const SizedBox.shrink()
                            : ElevatedButton(
                                onPressed: _reset,
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(screenSize.width * 0.32,
                                      screenSize.height * 0.08),
                                  foregroundColor: AppColors.primaryBlue,
                                  backgroundColor: AppColors.primaryWhite,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFF004283),
                                    width: 1,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                ),
                                child: Text(
                                  'Reset',
                                  style: TextStyle(
                                    color: Color(0xFF004283),
                                    fontSize: 7 * screenRatio,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  SizedBox(
                    width: screenSize.width,
                    height: screenRatio * 46,
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'You can update your fitness and stress status once everyday.\nIf you have high stress or low fitness, we encourage you to visit ',
                            style: TextStyle(
                              color: Color(0xFF707070),
                              fontSize: 7 * screenRatio,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: 'asthmaandlung.org.uk',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 7 * screenRatio,
                              fontWeight: FontWeight.normal,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                openLink('www.asthmaandlung.org.uk');
                                logger.d('Open asthmaandlung.org.uk');
                              },
                          ),
                          TextSpan(
                            text: ' to see how you could change the situation.',
                            style: TextStyle(
                              color: Color(0xFF707070),
                              fontSize: 7 * screenRatio,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  SizedBox(
                    width: screenSize.width,
                    height: screenRatio * 16,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'View your fitness and stress report',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 7 * screenRatio,
                              fontWeight: FontWeight.normal,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) =>
                                //         const FitnessStressReportScreen(),
                                //   ),
                                // );
                                logger.d('View your fitness and stress report');
                              },
                          ),
                        ],
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
