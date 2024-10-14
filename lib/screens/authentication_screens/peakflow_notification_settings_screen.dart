import 'dart:io';

import 'package:asthmaapp/api/user_api.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:asthmaapp/widgets/custom_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

class PeakflowNotificationSettingsScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const PeakflowNotificationSettingsScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<PeakflowNotificationSettingsScreen> createState() =>
      _PeakflowNotificationSettingsScreenState();
}

class _PeakflowNotificationSettingsScreenState
    extends State<PeakflowNotificationSettingsScreen> {
  UserModel? userModel;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _morningController = TextEditingController();

  final TextEditingController _eveningController = TextEditingController();

  TimeOfDay timeOfDay = TimeOfDay.now();
  late String morningTime, eveningTime;
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

  void _submitNotificationTimes() async {
    if (userModel == null) return;
    if (_formKey.currentState!.validate()) {
      try {
        final response = await UserApi().updateUserDataById(
          userModel!.userId,
          {
            // Pass the morning and evening times inside a map
            'startTime': morningTime,
            'endTime': eveningTime,
          },
          userModel!.accessToken,
        );
        final jsonResponse = response;
        final status = jsonResponse['status'];
        if (status == 201) {
          logger.d('Peakflow reminder timings added successfully');
          _morningController.clear();
          _eveningController.clear();

          CustomSnackBarUtil.showCustomSnackBar(
              'Peakflow reminder timings added successfully',
              success: true);
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/ice_screen',
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
            'An error occurred while adding the note',
            success: false);
      }
    } else {
      if (_morningController.text.isEmpty) {
        CustomSnackBarUtil.showCustomSnackBar('Please select morning time',
            success: false);
        return;
      }
      if (_eveningController.text.isEmpty) {
        CustomSnackBarUtil.showCustomSnackBar('Please select evening time',
            success: false);
        return;
      }
    }
  }

  Future<void> _selectMorningTime(BuildContext context) async {
    var initialTime =
        const TimeOfDay(hour: 6, minute: 0); // Morning time (6:00 AM)

    var time = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.dialOnly,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            materialTapTargetSize: MaterialTapTargetSize.padded,
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: false,
              ),
              child: child!,
            ),
          ),
        );
      },
    );

    if (time != null) {
      if (time.period == DayPeriod.pm) {
        // If selected time is in the PM period, show a confirmation dialog
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              type: 'alert',
              title: 'Time Picker Error',
              content: 'Please select a morning timing',
              optionOne: () {
                Navigator.of(context).pop();
              },
            );
          },
        );
      } else {
        setState(() {
          timeOfDay = time;
          _morningController.text =
              "${time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.period.name}";
          morningTime =
              "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
          logger.d(morningTime);
        });
      }
    }
  }

  Future _selectEveningTime(BuildContext context) async {
    var initialTime =
        const TimeOfDay(hour: 6, minute: 0); // Morning time (6:00 AM)

    var time = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.dialOnly,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            materialTapTargetSize: MaterialTapTargetSize.padded,
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                alwaysUse24HourFormat: false,
              ),
              child: child!,
            ),
          ),
        );
      },
    );

    if (time != null) {
      if (time.period == DayPeriod.am) {
        // If selected time is in the PM period, show a confirmation dialog
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              type: 'alert',
              title: 'Time Picker Error',
              content: 'Please select an evening timing',
              optionOne: () {
                Navigator.of(context).pop();
              },
            );
          },
        );
      } else {
        setState(() {
          timeOfDay = time;
          _eveningController.text =
              "${time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.period.name}";
          eveningTime =
              "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
          logger.d(eveningTime);
        });
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
                      SizedBox(
                        width: screenSize.width,
                        child: Text(
                          'Peakflow Notification Settings',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryBlueText,
                            fontSize: screenRatio * 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.04),
                      SizedBox(
                        width: screenSize.width,
                        child: Text(
                          'We will send two notifications each day to\n remind you to record your peakflow. You can set\n your time preference here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryGreyText,
                            fontSize: screenRatio * 7,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.04),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: screenSize.width,
                              child: Text(
                                'Morning:',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Color(0xFF6C6C6C),
                                  fontSize: screenRatio * 8,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: _morningController,
                              onTap: () => _selectMorningTime(context),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: screenRatio * 8,
                                  vertical: screenRatio * 4,
                                ),
                                hintText: 'Select Morning Time',
                                hintStyle: TextStyle(
                                  color: Color(0xFF6C6C6C),
                                  fontSize: screenRatio * 7,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Roboto',
                                ),
                                border: OutlineInputBorder(),
                              ),
                              readOnly: true,
                            ),
                            SizedBox(height: screenSize.height * 0.01),
                            SizedBox(
                              width: screenSize.width,
                              child: Text(
                                'Evening:',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Color(0xFF6C6C6C),
                                  fontSize: screenRatio * 8,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: _eveningController,
                              onTap: () => _selectEveningTime(context),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: screenRatio * 8,
                                  vertical: screenRatio * 4,
                                ),
                                hintText: 'Select Evening Time',
                                hintStyle: TextStyle(
                                  color: Color(0xFF6C6C6C),
                                  fontSize: screenRatio * 7,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Roboto',
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              readOnly: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.04),
                      SizedBox(
                        width: screenSize.width,
                        child: ElevatedButton(
                          onPressed: () {
                            _submitNotificationTimes();
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
                            'Save',
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
