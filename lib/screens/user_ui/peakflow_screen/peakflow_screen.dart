import 'dart:io';

import 'package:asthmaapp/api/peakflow_api.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model.dart';
import 'package:asthmaapp/screens/user_ui/peakflow_screen/widgets/notification_bottom_sheet_info.dart';
import 'package:asthmaapp/screens/user_ui/peakflow_screen/widgets/peakflow_bottom_sheet_info.dart';
import 'package:asthmaapp/screens/user_ui/peakflow_screen/widgets/peakflow_measure.dart';
import 'package:asthmaapp/screens/user_ui/widgets/custom_drawer.dart';
import 'package:asthmaapp/services/permission_service.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:url_launcher/url_launcher.dart';

class PeakflowScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const PeakflowScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<PeakflowScreen> createState() => _PeakflowScreenState();
}

class _PeakflowScreenState extends State<PeakflowScreen> {
  UserModel? userModel;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _peakflowvalueController =
      TextEditingController();
  final PermissionService _permissionService =
      PermissionService(); // Create an instance of PermissionService

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  void _openpeakflowbottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => const PeakflowBottomSheetInfo(),
    );
  }

  void _opennotificationbottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => const NotificationBottomSheet(),
    );
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

  void _submitPeakflow() async {
    if (userModel == null) return;

    await _permissionService.locationPermission();
    if (_formKey.currentState!.validate()) {
      int peakflowValue = int.parse(_peakflowvalueController.text.trim());
      try {
        final response = await PeakflowApi().addPeakflow(
          userModel!.userId,
          peakflowValue,
          DateTime.now().month,
          DateTime.now().year,
          userModel!.accessToken,
        );
        final jsonResponse = response;
        final status = jsonResponse['status'];
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
      if (_peakflowvalueController.text.isEmpty) {
        CustomSnackBarUtil.showCustomSnackBar('Peakflow Value can not be empty',
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF004283),
        foregroundColor: const Color(0xFFFFFFFF),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Peakflow',
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
              color: AppColors.primaryWhite,
              width: screenSize.width,
              padding: EdgeInsets.all(screenSize.width * 0.016),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _openpeakflowbottomSheet(context);
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(
                        screenSize.width * 1.0,
                        screenSize.height * 0.08,
                      ),
                      foregroundColor: AppColors.primaryWhite,
                      backgroundColor: AppColors.errorRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: Text(
                      'Too Breathless to Perform?',
                      style: TextStyle(
                        color: AppColors.primaryWhiteText,
                        fontSize: screenRatio * 8,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.016),
                  SizedBox(
                    width: screenSize.width,
                    child: Text(
                      'To measure your Peakflow',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.primaryBlueText,
                        fontSize: screenRatio * 8,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.016),
                  SizedBox(
                    width: screenSize.width,
                    child: PeakflowMeasure(
                      screenSize: screenSize,
                      screenRatio: screenRatio,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.016),
                  SizedBox(
                    width: screenSize.width * 0.9,
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'To refresh how to perform Peakflow accurately visit ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenRatio * 8,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: 'asthmaandlung.org.uk',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: screenRatio * 8,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                openLink('asthmaandlung.org.uk');
                                logger.d('Open asthmaandlung.org.uk');
                              },
                          ),
                          TextSpan(
                            text: ' or ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenRatio * 8,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: 'nhs.uk ',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: screenRatio * 8,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                openLink('nhs.uk');
                                logger.d('nhs.uk');
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  SizedBox(
                    width: screenSize.width,
                    child: Text(
                      'Enter Peakflow Value',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryBlueText,
                        fontSize: screenRatio * 9,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          TextFormField(
                            controller: _peakflowvalueController,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenRatio * 8,
                                vertical: screenRatio * 4,
                              ),
                              border: OutlineInputBorder(),
                              hintText: 'Peakflow Value',
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
                                return 'Peakflow value is required';
                              }

                              // Check if the input is a number
                              final num? peakflow = num.tryParse(value);
                              if (peakflow == null) {
                                return 'Please enter a valid number';
                              }

                              // Ensure the value is greater than 0
                              if (peakflow <= 0) {
                                return 'Peakflow value must be greater than 0';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: screenSize.height * 0.01),
                          ElevatedButton(
                            onPressed: () {
                              _submitPeakflow();
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(screenSize.width * 0.24,
                                  screenSize.height * 0.06),
                              foregroundColor: const Color(0xFFFFFFFF),
                              backgroundColor: const Color(0xFF004283),
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
                                fontSize: 18,
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
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Set your notification timings',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _opennotificationbottomSheet(context);
                            },
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
