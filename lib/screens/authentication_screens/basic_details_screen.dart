import 'dart:io';

import 'package:asthmaapp/api/user_api.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';

class BasicDetailsScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const BasicDetailsScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<BasicDetailsScreen> createState() => _BasicDetailsScreenState();
}

class _BasicDetailsScreenState extends State<BasicDetailsScreen> {
  UserModel? userModel;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _peakflowBaselineController =
      TextEditingController();
  final TextEditingController _steroidDosageController =
      TextEditingController();
  final TextEditingController _salbutamolDosageController =
      TextEditingController();
  final TextEditingController _inhalerDeviceController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = getUserData(widget.realm);
    setState(() {
      userModel = user;
    });
  }

  UserModel? getUserData(Realm realm) {
    final results = realm.all<UserModel>();
    return results.isNotEmpty ? results[0] : null;
  }

  void _submitDetails() async {
    if (userModel == null) return;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });
      try {
        final response = await UserApi().updateUserDataById(
          userModel!.userId,
          {
            'signupStep': 'completed',
            'baseLineScore': _peakflowBaselineController.text.trim(),
            'steroidDosage': _steroidDosageController.text.trim(),
            'salbutomalDosage': _salbutamolDosageController.text.trim(),
            'inhaler': _inhalerDeviceController.text.trim(),
          },
          userModel!.accessToken,
        );
        final jsonResponse = response;
        final status = jsonResponse['status'];
        if (status == 201) {
          CustomSnackBarUtil.showCustomSnackBar(
              'User data updated successfully',
              success: true);
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/location_access_screen', // Named route
            (Route<dynamic> route) => false, // This removes all previous routes
            arguments: {
              'realm': widget.realm,
              'deviceToken': widget.deviceToken,
              'deviceType': widget.deviceType,
            },
          );
        } else {
          CustomSnackBarUtil.showCustomSnackBar(
              'An error occurred while adding the basic details',
              success: false);
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
            'An error occurred while adding the basic details',
            success: false);
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    } else {
      if (_peakflowBaselineController.text.isEmpty) {
        CustomSnackBarUtil.showCustomSnackBar(
            'Peakflow baseline score can not be empty',
            success: false);
        return;
      }
      if (_steroidDosageController.text.isEmpty) {
        CustomSnackBarUtil.showCustomSnackBar('Steroid dosage can not be empty',
            success: false);
        return;
      }
      if (_salbutamolDosageController.text.isEmpty) {
        CustomSnackBarUtil.showCustomSnackBar(
            'Salbutamol dosage can not be empty',
            success: false);
        return;
      }
      if (_inhalerDeviceController.text.isEmpty) {
        CustomSnackBarUtil.showCustomSnackBar(
            'Inhaler device ID can not be empty',
            success: false);
        return;
      }
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
                        'assets/svgs/user_assets/logo.svg',
                        width: screenRatio * 52,
                      ),
                      SizedBox(height: screenSize.height * 0.08),
                      SizedBox(
                        width: screenSize.width,
                        child: Text(
                          'Patient Data',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.primaryBlueText,
                            fontSize: screenRatio * 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.04),
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Peakflow Baseline Score
                            TextFormField(
                              controller: _peakflowBaselineController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: screenRatio * 8,
                                  vertical: screenRatio * 4,
                                ),
                                labelText: 'Peakflow Baseline Score',
                                labelStyle: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: screenRatio * 6,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a value';
                                }

                                // Check if the input is a number
                                final num? peakflowValue = num.tryParse(value);
                                if (peakflowValue == null) {
                                  return 'Please enter a valid number';
                                }

                                // Ensure the value is greater than 0
                                if (peakflowValue <= 0) {
                                  return 'Peakflow score must be greater than 0';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: screenSize.height * 0.02),
                            // Steroid Dosage
                            TextFormField(
                              controller: _steroidDosageController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: screenRatio * 8,
                                  vertical: screenRatio * 4,
                                ),
                                labelText: 'Existing Steroid Dosage',
                                labelStyle: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: screenRatio * 6,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a value';
                                }

                                // Check if the input is a number
                                final num? steroidValue = num.tryParse(value);
                                if (steroidValue == null) {
                                  return 'Please enter a valid number';
                                }

                                // Ensure the value is greater than 0
                                if (steroidValue <= 0) {
                                  return 'Steroid doseage must be greater than 0';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: screenSize.height * 0.02),
                            // Salbutamol Dosage
                            TextFormField(
                              controller: _salbutamolDosageController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: screenRatio * 8,
                                  vertical: screenRatio * 4,
                                ),
                                labelText: 'Salbutamol Dosage',
                                labelStyle: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: screenRatio * 6,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a value';
                                }

                                // Check if the input is a number
                                final num? salbutamolValue =
                                    num.tryParse(value);
                                if (salbutamolValue == null) {
                                  return 'Please enter a valid number';
                                }

                                // Ensure the value is greater than 0
                                if (salbutamolValue <= 0) {
                                  return 'Salbutamol doseage must be greater than 0';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: screenSize.height * 0.02),
                            // Inhaler Device ID
                            TextFormField(
                              controller: _inhalerDeviceController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: screenRatio * 8,
                                  vertical: screenRatio * 4,
                                ),
                                labelText: 'Inhaler Device ID',
                                labelStyle: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: screenRatio * 6,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a value';
                                }

                                // Check if the input is a number
                                final num? inhalerDeviceValue =
                                    num.tryParse(value);
                                if (inhalerDeviceValue == null) {
                                  return 'Please enter a valid number';
                                }

                                // Ensure the value is greater than 0
                                if (inhalerDeviceValue <= 0) {
                                  return 'Inhaler device ID must be greater than 0';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.04),
                      SizedBox(
                        width: screenSize.width,
                        child: ElevatedButton(
                          onPressed: () {
                            _submitDetails();
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
                            'Submit',
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
