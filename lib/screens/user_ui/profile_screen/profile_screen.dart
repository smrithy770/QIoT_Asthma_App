import 'dart:io';

import 'package:asthmaapp/api/user_api.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/models/user_model.dart';
import 'package:asthmaapp/widgets/custom_drawer.dart';
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

  Future<void> _handleRefresh() async {
    try {
      final response =
          await UserApi().getUserById(userModel!.id, userModel!.accessToken);
      final jsonResponse = response;
      print(jsonResponse);
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
      print('NetworkException: $e');
    } on Exception catch (e) {
      print('Failed to fetch data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: const Color(0xFF004283),
        foregroundColor: const Color(0xFFFFFFFF),
        title: const Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            'Profile',
            style: TextStyle(
              fontSize: 24,
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
        onItemSelected: (int index) {
          print(index);
        },
      ),
      body: SingleChildScrollView(
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
                // First Name
                Container(
                  width: screenSize.width,
                  height: screenSize.height * 0.08,
                  padding: EdgeInsets.all(screenSize.height * 0.01),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'First Name',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.primaryGreyText,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _firstName ?? '-',
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              color: Color(0xFF004283),
                              fontSize: 18,
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
                  height: screenSize.height * 0.08,
                  padding: EdgeInsets.all(screenSize.height * 0.01),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Last Name',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.primaryGreyText,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _lastName ?? '-',
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              color: Color(0xFF004283),
                              fontSize: 18,
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
                  height: screenSize.height * 0.08,
                  padding: EdgeInsets.all(screenSize.height * 0.01),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Email Address',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.primaryGreyText,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _email ?? '-',
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              color: Color(0xFF004283),
                              fontSize: 18,
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
                  height: screenSize.height * 0.08,
                  padding: EdgeInsets.all(screenSize.height * 0.01),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'General Practitioner Number',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.primaryGreyText,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '+${_practionerContact ?? '-'}',
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              color: Color(0xFF004283),
                              fontSize: 18,
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
                  height: screenSize.height * 0.06,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          print('Edit');
                        },
                        child: const Text(
                          'Edit',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.primaryLightBlueText,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          print('Change Password');
                        },
                        child: const Text(
                          'Change Password',
                          textAlign: TextAlign.right,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
