import 'dart:async';

import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';

class AdditionalSetupScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const AdditionalSetupScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<AdditionalSetupScreen> createState() => _AdditionalSetupScreenState();
}

class _AdditionalSetupScreenState extends State<AdditionalSetupScreen> {
  UserModel? userModel;

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
    if (results.isNotEmpty) {
      return results[0];
    }
    return null;
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
        child: Center(
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
                  SvgPicture.asset(
                    'assets/svgs/user_assets/info.svg',
                    width: screenRatio * 64, // Adjust width as needed
                    height: screenRatio * 64, // Adjust height as needed
                  ),
                  SizedBox(height: screenSize.height * 0.08),
                  SizedBox(
                    width: screenSize.width,
                    height: screenRatio * 32,
                    child: Text(
                      'We need more additional information to setup',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryBlueText,
                        fontSize: screenRatio * 9,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.04),
                  SizedBox(
                    width: screenSize.width * 0.4,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/basic_details_screen', // Named route
                          (Route<dynamic> route) =>
                              false, // This removes all previous routes
                          arguments: {
                            'realm': widget.realm,
                            'deviceToken': widget.deviceToken,
                            'deviceType': widget.deviceType,
                          },
                        );
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
                        'Sure',
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
      ),
    );
  }
}
