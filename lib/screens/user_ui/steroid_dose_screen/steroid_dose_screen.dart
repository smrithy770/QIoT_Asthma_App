import 'dart:io';

import 'package:asthmaapp/api/steroid_dose_api.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model.dart';
import 'package:asthmaapp/screens/user_ui/widgets/custom_drawer.dart';
import 'package:asthmaapp/services/permission_service.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:realm/realm.dart';

class SteroidDoseScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const SteroidDoseScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<SteroidDoseScreen> createState() => _SteroidDoseScreenState();
}

class _SteroidDoseScreenState extends State<SteroidDoseScreen> {
  UserModel? userModel;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _steroiddosevalueController =
      TextEditingController();
  final PermissionService _permissionService =
      PermissionService(); // Create an instance of PermissionService
  Position? _currentPosition;
  FilePickerResult? result;
  String? _result;
  final int maxSizeInBytes = 5 * 1024 * 1024; // 5 MB in bytes
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _requestPermissions();
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

    setState(() {
      userModel = user;
    });
  }

  UserModel? getUserData(Realm realm) {
    final results = realm.all<UserModel>();
    return results.isNotEmpty ? results[0] : null;
  }

  Future<void> _submitSteroidDose() async {
    if (userModel == null) return;
    if (_formKey.currentState!.validate()) {
      int steroidDoseValue = int.parse(_steroiddosevalueController.text.trim());

      // Ensure location data is available
      if (_currentPosition == null) {
        CustomSnackBarUtil.showCustomSnackBar(
          'Unable to get location. Please enable location services.',
          success: false,
        );
        return;
      }

      try {
        final response = await SteroidDoseApi().addSteroidDose(
          userModel!.userId,
          steroidDoseValue,
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
          // setState(() {
          //   baseLineScore = jsonResponse['payload']['baseLineScore'];
          //   practionerContact = jsonResponse['payload']['practionerContact'];
          // });
          CustomSnackBarUtil.showCustomSnackBar(
              "Steroid Dose added successfully",
              success: true);
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home', // Named route
              (Route<dynamic> route) =>
                  false, // This removes all previous routes
              arguments: {
                'realm': widget.realm,
                'deviceToken': widget.deviceToken,
                'deviceType': widget.deviceType,
              },
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
    } else {
      if (_steroiddosevalueController.text.isEmpty) {
        CustomSnackBarUtil.showCustomSnackBar(
            'Steroid Dose Value  can not be empty',
            success: false);
        return;
      }
    }
  }

  Future<void> selectFile() async {
    result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'pdf',
      ], // Add the extensions of allowed file types
    );

    if (result != null) {
      logger.d('File Path: ${result!.files.single.path}');
      setState(() {
        _result = result!.files.single.path!;
      });
    } else {
      setState(() {
        _result = '';
      });
    }
  }

  Future<void> _submitSteroidCard() async {
    logger.d('File size: ${result!.files.single.size}');
    logger.d('File size: $maxSizeInBytes');
    if (userModel == null) return;
    if (result == null ||
        result!.files.isEmpty ||
        result!.files.first.path == null) {
      CustomSnackBarUtil.showCustomSnackBar('No file selected', success: false);
      return;
    }
    if (result != null && result!.files.single.size > maxSizeInBytes) {
      CustomSnackBarUtil.showCustomSnackBar('File size exceeds the 5MB limit',
          success: false);
      return;
    }
    PlatformFile file = result!.files.first;
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await SteroidDoseApi().uploadSteroidCard(
        userModel!.userId,
        // file.path.toString(),
        file.path,
        userModel!.accessToken,
      );
      final jsonResponse = response;
      final status = jsonResponse['status'];
      logger.d('Response: $jsonResponse');
      logger.d('Status: $status');
      if (status == 200) {
        logger.d('Image uploaded successfully');
        CustomSnackBarUtil.showCustomSnackBar("File uploaded successfully",
            success: true);
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

        logger.d('Error: $errorMessage');
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.primaryWhite,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Steroid Dose',
            style: TextStyle(
              fontSize: screenRatio * 10,
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
      body: Stack(
        children: [
          GestureDetector(
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
                  color: AppColors.primaryWhite,
                  width: screenSize.width,
                  padding: EdgeInsets.all(screenSize.width * 0.016),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenSize.width,
                        height: screenRatio * 12,
                        child: Text(
                          'Steroid Dose Entry',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: screenRatio * 8,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      SizedBox(
                        width: screenSize.width,
                        height: screenSize.height * 0.16,
                        child: SvgPicture.asset(
                          'assets/svgs/user_assets/steroid.svg',
                          width: 64,
                          height: 64,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      SizedBox(
                        width: screenSize.width,
                        height: screenRatio * 12,
                        child: Text(
                          'Please enter your steroid dosage and hit submit.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: screenRatio * 7,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 92, vertical: 8),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              TextFormField(
                                controller: _steroiddosevalueController,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: screenRatio * 8,
                                    vertical: screenRatio * 4,
                                  ),
                                  border: OutlineInputBorder(),
                                  hintText: 'Steroid Dose Value',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF6C6C6C),
                                    fontSize: screenRatio * 7,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {});
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Steroid Dose Value is required';
                                  }

                                  // Check if the input is a number
                                  final num? peakflow = num.tryParse(value);
                                  if (peakflow == null) {
                                    return 'Please enter a valid number';
                                  }

                                  // Ensure the value is greater than 0
                                  if (peakflow <= 0) {
                                    return 'Steroid Dose value must be greater than 0';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: screenSize.height * 0.01),
                              ElevatedButton(
                                onPressed: () {
                                  _submitSteroidDose();
                                },
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(screenSize.width * 0.24,
                                      screenSize.height * 0.08),
                                  foregroundColor: AppColors.primaryWhite,
                                  backgroundColor: AppColors.primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                ),
                                child: Text(
                                  'Submit',
                                  style: TextStyle(
                                    color: AppColors.primaryWhite,
                                    fontSize: 8 * screenRatio,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      SizedBox(
                        width: screenSize.width,
                        height: screenRatio * 12,
                        child: Text(
                          'Upload your steroid card',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 7 * screenRatio,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 92, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              onTap: selectFile,
                              child: Container(
                                width: screenSize.width * 0.32,
                                height: screenSize.height * 0.12,
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF00A2FF).withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFF00A2FF)
                                        .withOpacity(0.4),
                                    style: BorderStyle.solid,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/svgs/user_assets/upload.svg',
                                    width: 64,
                                    height: 64,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: screenSize.height * 0.02),
                            ElevatedButton(
                              onPressed: () {
                                _result != null ? _submitSteroidCard() : null;
                              },
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size(screenSize.width * 0.24,
                                    screenSize.height * 0.08),
                                foregroundColor: _result != null
                                    ? AppColors.primaryWhite
                                    : const Color(0xFFA6A6A6),
                                backgroundColor: _result != null
                                    ? AppColors.primaryBlue
                                    : const Color(0xFFEDEDED),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                              ),
                              child: Text(
                                'Upload',
                                style: TextStyle(
                                  fontSize: 8 * screenRatio,
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
          if (_isLoading)
            Center(
              child: Container(
                width: screenRatio * 32,
                height: screenRatio * 32,
                padding: EdgeInsets.all(screenRatio * 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryWhite.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
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
    );
  }
}
