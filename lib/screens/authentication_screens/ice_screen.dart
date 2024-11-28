import 'dart:io';

import 'package:asthmaapp/api/user_api.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:realm/realm.dart';

class ICEScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const ICEScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<ICEScreen> createState() => _ICEScreenState();
}

class _ICEScreenState extends State<ICEScreen> {
  UserModel? userModel;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _practitionerContactController =
      TextEditingController();

  final FlutterNativeContactPicker _contactPicker =
      FlutterNativeContactPicker();
  List<Contact>? _contacts;
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

  void _submitICE() async {
    if (userModel == null) return;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final response = await UserApi().updateUserDataById(
          userModel!.userId,
          {
            // Pass the morning and evening times inside a map
            'practionerContact': _practitionerContactController.text.trim(),
          },
          userModel!.accessToken,
        );
        final jsonResponse = response;
        final status = jsonResponse['status'];
        if (status == 201) {
          logger.d('ICE number  added successfully');

          CustomSnackBarUtil.showCustomSnackBar('ICE number added successfully',
              success: true);
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (Route<dynamic> route) => false,
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
            'An error occurred while updating ICE contact',
            success: false);
      }
    } else {
      if (_practitionerContactController.text.isEmpty) {
        CustomSnackBarUtil.showCustomSnackBar(
            'Please enter your ICE contact number',
            success: false);
        return;
      }
    }
  }

  @override
  void dispose() {
    _practitionerContactController.dispose();
    super.dispose();
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
                      SizedBox(
                        width: screenSize.width,
                        height: screenRatio * 42,
                        child: Text(
                          'We need to know your In Case of\n Emergency (ICE) contact\'s phone number',
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
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _practitionerContactController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: screenRatio * 8,
                                  vertical: screenRatio * 4,
                                ),
                                hintText: '+44 777 777 7777',
                                hintStyle: TextStyle(
                                  color: AppColors.primaryGreyText,
                                  fontSize: screenRatio * 7,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Roboto',
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your ICE contact number';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      SizedBox(
                        width: screenSize.width,
                        height: screenRatio * 38,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Or',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: AppColors.primaryLightBlueText,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                Contact? contact =
                                    await _contactPicker.selectContact();
                                setState(() {
                                  _contacts =
                                      contact == null ? null : [contact];
                                  if (_contacts != null &&
                                      _contacts!.isNotEmpty &&
                                      _contacts![0].phoneNumbers != null &&
                                      _contacts![0].phoneNumbers!.isNotEmpty) {
                                    _practitionerContactController.text =
                                        _contacts![0].phoneNumbers![0];
                                  }
                                });
                              },
                              child: const Text(
                                'Select from contacts',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: AppColors.primaryLightBlueText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      SizedBox(
                        width: screenSize.width,
                        height: screenRatio * 24,
                        child: Text(
                          'Your ICE contact\'s phone number will be\n available as a speed dial for emergencies.',
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
                            _submitICE();
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
                            'Done',
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