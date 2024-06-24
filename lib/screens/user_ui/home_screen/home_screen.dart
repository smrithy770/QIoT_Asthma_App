import 'dart:io';
import 'dart:math';

import 'package:asthmaapp/api/user_api.dart';
import 'package:asthmaapp/models/user_model.dart';
import 'package:asthmaapp/widgets/custom_actions.dart';
import 'package:asthmaapp/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';

class HomeScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const HomeScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? userModel;
  Map<String, dynamic>? userData;
  String? _baseLineScore = '-';
  String? _steroidDosage = '-';
  String? _salbutomalDosage = '-';
  String? _asthmamessages = '-';
  String? _nextTaskTime = '-';

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
      final response = await UserApi()
          .getHomepageData(userModel!.id, userModel!.accessToken);
      final jsonResponse = response;
      final status = jsonResponse['status'];
      if (status == 200) {
        int randomNumber =
            Random().nextInt(jsonResponse['payload']['asthmaMessages'].length);
        setState(() {
          _baseLineScore = jsonResponse['payload']['baseLineScore'].toString();
          _steroidDosage = jsonResponse['payload']['steroidDosage'].toString();
          _salbutomalDosage =
              jsonResponse['payload']['salbutomalDosage'].toString();
          _asthmamessages = jsonResponse['payload']['asthmaMessages']
                  [randomNumber]['message']
              .toString();
          _nextTaskTime = jsonResponse['payload']['nextTaskTime'];
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
            'Home',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/notification');
            },
            child: SvgPicture.asset(
              'assets/svgs/notification.svg',
              color: AppColors.primaryWhite,
              width: 32,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CustomActions(),
          )
        ],
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
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: _handleRefresh,
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
                  // Top section
                  SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: screenSize.width * 0.968,
                              height: screenSize.height * 0.16,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Center(
                                    child: Text(
                                      'Peakflow Baseline',
                                      style: TextStyle(
                                        color: AppColors.primaryWhite,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      _baseLineScore!,
                                      style: const TextStyle(
                                        color: AppColors.primaryWhite,
                                        fontSize: 48,
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
                        SizedBox(height: screenSize.height * 0.016),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: screenSize.width * 0.476,
                              height: screenSize.height * 0.16,
                              decoration: BoxDecoration(
                                color: AppColors.primaryOrange,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Center(
                                    child: Text(
                                      'Steroid Dosage',
                                      style: TextStyle(
                                        color: AppColors.primaryWhite,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      _steroidDosage!,
                                      style: const TextStyle(
                                        color: AppColors.primaryWhite,
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: screenSize.width * 0.016),
                            Container(
                              width: screenSize.width * 0.476,
                              height: screenSize.height * 0.16,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLightBlue,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Center(
                                    child: Text(
                                      'Salbutamol Dosage',
                                      style: TextStyle(
                                        color: AppColors.primaryWhite,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      _salbutomalDosage!,
                                      style: const TextStyle(
                                        color: AppColors.primaryWhite,
                                        fontSize: 48,
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
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.016),
                  // Middle section
                  SizedBox(
                      width: screenSize.width * 0.968,
                      height: screenSize.height * 0.26,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: screenSize.height * 0.12,
                            padding: EdgeInsets.all(screenSize.width * 0.016),
                            decoration: BoxDecoration(
                              color: AppColors.primaryWhite,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primaryBlue.withOpacity(0.08),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/svgs/peakflow.svg",
                                        width: 64,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Your Peakflow test is due in next 1 hour',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: AppColors.primaryBlue,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Roboto',
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          _nextTaskTime!,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            color:
                                                AppColors.primaryLightBlueText,
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
                          SizedBox(height: screenSize.height * 0.016),
                          Container(
                            height: screenSize.height * 0.12,
                            padding: EdgeInsets.all(screenSize.width * 0.016),
                            decoration: BoxDecoration(
                              color: AppColors.primaryWhite,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primaryBlue.withOpacity(0.08),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/svgs/act.svg",
                                        width: 64,
                                      ),
                                    ],
                                  ),
                                ),
                                const Expanded(
                                  flex: 9,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Your ACT is due in next 2 days',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: AppColors.primaryBlue,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Roboto',
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Due on 20 Feb',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color:
                                                AppColors.primaryLightBlueText,
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
                        ],
                      )),
                  SizedBox(height: screenSize.height * 0.016),
                  // Bottom section
                  SizedBox(
                    width: screenSize.width * 0.968,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        _asthmamessages!,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          color: AppColors.primaryBlueText,
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.016),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
