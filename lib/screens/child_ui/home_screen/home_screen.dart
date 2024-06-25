import 'dart:io';

import 'package:asthmaapp/api/user_api.dart';
import 'package:asthmaapp/models/user_model.dart';
import 'package:asthmaapp/screens/child_ui/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';

class HomeScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  final String childId;
  const HomeScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
    required this.childId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? userModel;
  Map<String, dynamic>? userData;
  String? _firstName = '-';
  String? _baseLineScore = '-';
  String? _steroidDosage = '-';
  String? _salbutomalDosage = '-';

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
          .getHomepageData(widget.childId, userModel!.accessToken);
      final jsonResponse = response;
      // print(jsonResponse);
      final status = jsonResponse['status'];
      if (status == 200) {
        setState(() {
          _firstName = jsonResponse['payload']['firstName'].toString();
          _baseLineScore = jsonResponse['payload']['baseLineScore'].toString();
          _steroidDosage = jsonResponse['payload']['steroidDosage'].toString();
          _salbutomalDosage =
              jsonResponse['payload']['salbutomalDosage'].toString();
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
        backgroundColor: AppColors.childPrimaryLightBlue,
        foregroundColor: AppColors.primaryWhite,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: SvgPicture.asset(
                'assets/svgs/child_assets/child_drawer_icon.svg', // Replace with your custom icon asset path
                width: 24,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: CustomDrawer(
        firstName:_firstName,
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
        color: AppColors.childPrimaryLightBlue,
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Container(
              width: screenSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: screenSize.width,
                    height: 128,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: const BoxDecoration(
                      color: AppColors.childPrimaryLightBlue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/svgs/child_assets/child.svg",
                                width: 96,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Good morning',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: AppColors.primaryWhiteText,
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Comic Neue',
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _firstName!,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    color: AppColors.primaryWhiteText,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Comic Neue',
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/svgs/child_assets/badge.svg",
                                      width: 32,
                                    ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    const Text(
                                      '3.9',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: AppColors.primaryWhiteText,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Comic Neue',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: screenSize.width * 0.968,
                                    height: screenSize.height * 0.16,
                                    decoration: BoxDecoration(
                                      color: AppColors.childPrimaryPink,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: screenSize.width * 0.476,
                                    height: screenSize.height * 0.16,
                                    decoration: BoxDecoration(
                                      color: AppColors.childPrimaryPurple,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                      color: AppColors.primaryOrange,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
