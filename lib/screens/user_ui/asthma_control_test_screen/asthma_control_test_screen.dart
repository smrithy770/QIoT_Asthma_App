import 'dart:io';

import 'package:asthmaapp/api/asthmacontroltest_api.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model.dart';
import 'package:asthmaapp/screens/user_ui/asthma_control_test_screen/asthma_control_test_result_screen.dart';
import 'package:asthmaapp/screens/user_ui/widgets/custom_drawer.dart';
import 'package:asthmaapp/screens/user_ui/asthma_control_test_screen/widget/questionnaire_widget.dart';
import 'package:asthmaapp/screens/user_ui/asthma_control_test_screen/widget/step_progress_indicator.dart';
import 'package:asthmaapp/services/permission_service.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:realm/realm.dart';
import '../../../act_questions.dart';

class AsthmaControlTestScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const AsthmaControlTestScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<AsthmaControlTestScreen> createState() =>
      _AsthmaControlTestScreenState();
}

class _AsthmaControlTestScreenState extends State<AsthmaControlTestScreen> {
  UserModel? userModel;
  final PageController _pageController = PageController(initialPage: 0);
  final PermissionService _permissionService =
      PermissionService(); // Create an instance of PermissionService
  Position? _currentPosition;

  int currentStep = 0;
  int totalSteps = act_questions.length;

  int totalScore = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _requestPermissions();
    _pageController.addListener(_pageListener);
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

  @override
  void dispose() {
    _pageController.removeListener(_pageListener);
    _pageController.dispose();
    super.dispose();
  }

  void _pageListener() {
    setState(() {
      currentStep = _pageController.page?.round() ?? 0;
      if (currentStep == totalSteps - 1) {
        logger.d('Total Score: ${calculateTotalScore()} && step: $currentStep');
      }
    });
  }

  void moveToNextPage() {
    if (_pageController.page!.round() < totalSteps - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      setState(() {
        currentStep = totalSteps;
      });
      logger.d('Total Score: ${calculateTotalScore()} && step: $currentStep');
    }
  }

  int calculateTotalScore() {
    totalScore = 0;
    for (Map<String, dynamic> questionData in act_questions) {
      int selectedAnswerIndex = questionData['selectedAnswerIndex'];
      if (selectedAnswerIndex != -1) {
        // Increment total score by the score of the selected answer
        totalScore += selectedAnswerIndex + 1;
      }
    }
    return totalScore;
  }

  Future<void> _submitACT() async {
    logger.d('Total Score: $totalScore');

    if (userModel == null) return; // Ensure location data is available
    if (_currentPosition == null) {
      CustomSnackBarUtil.showCustomSnackBar(
        'Unable to get location. Please enable location services.',
        success: false,
      );
      return;
    }
    try {
      final response = await AsthmacontroltestApi().addAsthamControlTest(
        userModel!.userId,
        totalScore,
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
      logger.d('ACT Response: $jsonResponse');
      final status = jsonResponse['status'];
      if (status == 201) {
        CustomSnackBarUtil.showCustomSnackBar(
            "Asthma Control Test score added successfully",
            success: true);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AsthmaControlTestResultScreen(
                totalScore: totalScore,
                realm: widget.realm,
                deviceToken: widget.deviceToken,
                deviceType: widget.deviceType,
              ),
            ),
          );
        }
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
  }

  void _clearAllSelections() {
    setState(() {
      for (var question in act_questions) {
        question['selectedAnswerIndex'] = -1;
        question['score'] = 0;
      }
      currentStep = 0;
      _pageController.jumpToPage(
          0); // Optionally reset the page view to the first question
    });
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
            'Asthma Control Test',
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
          scrollDirection: Axis.vertical,
          physics: const ClampingScrollPhysics(),
          child: Center(
            child: Container(
              width: screenSize.width,
              height: screenSize.height,
              padding: EdgeInsets.all(screenSize.height * 0.01),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenSize.width,
                    height: screenRatio * 12,
                    child: Text(
                      'Asthma Control Test (ACT)',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Color(0xFF004283),
                        fontSize: 8 * screenRatio,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  SizedBox(
                    width: screenSize.width,
                    height: screenRatio * 96,
                    child: Center(
                      child: Text(
                        'Your Asthma Score will assist your Health Care Professional in helping you reach the best asthma control possible. Asthma Score is a way of working out your level of asthma control. Even if you think your asthma is under control, knowing your Asthma Score is still important. To work out your Asthma Score answer the question below:',
                        textAlign: TextAlign.left,
                        softWrap: true,
                        style: TextStyle(
                          color: Color(0xFF004283),
                          fontSize: 8 * screenRatio,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  SizedBox(
                    width: screenSize.width,
                    height: screenSize.height * 0.08,
                    child: StepProgressIndicator(
                        totalSteps: totalSteps, currentStep: currentStep),
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  SizedBox(
                    width: screenSize.width,
                    height: 128 * screenRatio,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: act_questions.length,
                      itemBuilder: (context, index) {
                        // Retrieve question data for the current index
                        Map<String, dynamic> questionData =
                            act_questions[index];
                        return QuestionnaireWidget(
                          question: questionData['question'],
                          options: questionData['options'],
                          selectedAnswerIndex:
                              questionData['selectedAnswerIndex'],
                          onTap: (answerIndex, selectedScore) {
                            setState(() {
                              // Update the selected answer index for the current question
                              act_questions[index]['selectedAnswerIndex'] =
                                  answerIndex;
                              // Calculate score for the current question
                              act_questions[index]['score'] = selectedScore;
                              moveToNextPage();
                            });
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: screenSize.width,
                    height: screenSize.height * 0.08,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: currentStep != 5
                              ? null
                              : () {
                                  _submitACT();
                                },
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(screenSize.width * 0.24,
                                screenSize.height * 0.06),
                            foregroundColor: AppColors.primaryWhite,
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _clearAllSelections();
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(screenSize.width * 0.24,
                                screenSize.height * 0.06),
                            foregroundColor: const Color(0xFF707070),
                            backgroundColor: AppColors.primaryWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                color: Color(
                                    0xFF707070), // Specify the border color here
                                width: 1, // Specify the border width here
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF707070),
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ],
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
