import 'dart:io';

import 'package:asthmaapp/api/user_api.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:asthmaapp/screens/user_ui/profile_screen/widgets/notification_bottom_sheet_info.dart';
import 'package:asthmaapp/screens/user_ui/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

class ProfileScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const ProfileScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? userModel;
  Map<String, dynamic>? userData;
  String? _firstName = '-';
  String? _lastName = '-';
  String? _email = '-';
  String? _practionerContact = '-';

  @override
  void initState() {
    super.initState();
    setState(() {
      userModel = getUserData(widget.realm);
    });
    _handleRefresh();
  }

  UserModel? getUserData(Realm realm) {
    final results = realm.all<UserModel>();
    if (results.isNotEmpty) {
      return results[0];
    }
    return null;
  }

  void _opennotificationbottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => NotificationBottomSheet(
        realm: widget.realm,
        deviceToken: widget.deviceToken,
        deviceType: widget.deviceType,
      ),
    );
  }

  Future<void> _handleRefresh() async {
    try {
      final response = await UserApi()
          .getUserById(userModel!.userId, userModel!.accessToken);
      final jsonResponse = response;
      logger.d(jsonResponse);
      final status = jsonResponse['status'];
      if (status == 200) {
        setState(() {
          _firstName = jsonResponse['payload']['firstName'].toString();
          _lastName = jsonResponse['payload']['lastName'].toString();
          _email = jsonResponse['payload']['email'].toString();
          _practionerContact =
              jsonResponse['payload']['practionerContact'].toString();
        });
      }
    } on SocketException catch (e) {
      logger.d('NetworkException: $e');
    } on Exception catch (e) {
      logger.d('Failed to fetch data: $e');
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
            'Profile',
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
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Container(
              color: AppColors.primaryWhite,
              width: screenSize.width,
              height: screenSize.height,
              padding: EdgeInsets.all(screenSize.width * 0.016),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenSize.width,
                    height: screenSize.height * 0.06,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                            'Edit',
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
                  SizedBox(height: screenSize.height * 0.016),
                  // First Name
                  Container(
                    width: screenSize.width,
                    height: screenRatio * 32,
                    padding: EdgeInsets.all(screenRatio * 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryWhite,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'First Name',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: AppColors.primaryGreyText,
                              fontSize: screenRatio * 8,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _firstName ?? '-',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: screenRatio * 7,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Roboto'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.016),
                  // Last Name
                  Container(
                    width: screenSize.width,
                    height: screenRatio * 32,
                    padding: EdgeInsets.all(screenRatio * 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryWhite,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Last Name',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: AppColors.primaryGreyText,
                              fontSize: screenRatio * 8,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _lastName ?? '-',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: screenRatio * 7,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Roboto'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.016),
                  // Email Address
                  Container(
                    width: screenSize.width,
                    height: screenRatio * 32,
                    padding: EdgeInsets.all(screenRatio * 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryWhite,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Email Address',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: AppColors.primaryGreyText,
                              fontSize: screenRatio * 8,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _email ?? '-',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: screenRatio * 7,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Roboto'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.016),
                  // General Practitioner Number
                  Container(
                    width: screenSize.width,
                    height: screenRatio * 32,
                    padding: EdgeInsets.all(screenRatio * 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryWhite,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'General Practitioner Number',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: AppColors.primaryGreyText,
                              fontSize: screenRatio * 8,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '+${_practionerContact ?? '-'}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: screenRatio * 7,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Roboto'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.016),
                  // Edit and Change Password
                  SizedBox(
                    width: screenSize.width,
                    height: screenRatio * 46,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            logger.d('Change Password');
                          },
                          child: Text(
                            'Change Password',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: AppColors.primaryLightBlueText,
                              fontSize: screenRatio * 8,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _opennotificationbottomSheet(context);
                          },
                          child: Text(
                            'Notification Settings',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
