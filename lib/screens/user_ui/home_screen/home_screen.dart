import 'dart:async';
import 'dart:io';

import 'package:asthmaapp/api/user_api.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:asthmaapp/screens/user_ui/home_screen/asthma_action_plan.dart';
import 'package:asthmaapp/screens/user_ui/home_screen/steroid_card.dart';
import 'package:asthmaapp/screens/user_ui/home_screen/widgets/asthma_action_plan_bottom_sheet.dart';
import 'package:asthmaapp/screens/user_ui/home_screen/widgets/medicatiom_reminder_card.dart';
import 'package:asthmaapp/screens/user_ui/home_screen/widgets/narrow_info_card.dart';
import 'package:asthmaapp/screens/user_ui/home_screen/widgets/wide_info_card.dart';
import 'package:asthmaapp/screens/user_ui/widgets/custom_drawer.dart';
import 'package:asthmaapp/services/token_refresh_service.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:asthmaapp/widgets/custom_elevated_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realm/realm.dart';
import 'package:shimmer/shimmer.dart';

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
  Map<String, dynamic> homepageData = {};
  String? remoteAsthmaActionPlanPDFpath = '';
  String? remoteEducationPDFpath = '';
  String? _baselineScore = ' ';
  String? _steroidDosage = ' ';
  String? _salbutomalDosage = ' ';
  String? _nextTaskTime = ' ';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _handleRefresh();
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

  Future<void> _handleRefresh() async {
    try {
      final jsonResponse = await UserApi()
          .getHomepageData(userModel!.userId, userModel!.accessToken);
      final status = jsonResponse['status'];
      logger.d('Response status: $status');

      if (status == 200) {
        logger.e("Data success");
        final payload = jsonResponse['payload'];
        setState(() {
          homepageData = payload;
          _baselineScore = jsonResponse['payload']['baseLineScore'].toString();
          _steroidDosage = jsonResponse['payload']['steroidDosage'].toString();
          _salbutomalDosage =
              jsonResponse['payload']['salbutomalDosage'].toString();
          _nextTaskTime = jsonResponse['payload']['nextTaskTime'].toString();
        
        });

        widget.realm.write(() {
          userModel?.educationalPlan =
              homepageData['educationalPlan']; // Update educationalPlan
        });

        _createPdfAfterDelay();
      } else {
        logger.e('Unexpected status code: $status');
      }
    } on SocketException catch (e) {
      
      logger.e('NetworkException: $e');
        CustomSnackBarUtil.showCustomSnackBar('No Internet Connection,please try again',
          success: false);
    } on Exception catch (e) {
      logger.e('Failed to fetch data in home screen: $e');
    
    }
  }

  void _createPdfAfterDelay() {
    Future.delayed(const Duration(milliseconds: 750), () {
      if (homepageData['asthmaActionPlan'] != '' ||
          homepageData['educationalPlan'] != '') {
        downloadPdfFile(homepageData['asthmaActionPlan']).then((f) {
          setState(() {
            remoteAsthmaActionPlanPDFpath = f.path;
          });
        });
        downloadPdfFile(homepageData['educationalPlan']).then((f) {
          logger.e("Download education files: ${f.path}");
          setState(() {
            remoteEducationPDFpath = f.path;
          });
        });
      } else {
        _createPdfAfterDelay();
      }
    });
  }

  Future<File> downloadPdfFile(String url) async {
    Completer<File> completer = Completer();
    try {
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      
      logger.e("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      logger.e('Error parsing asset file: $e');
      throw Exception('Error parsing asset file!');
    }
    return completer.future;
  }

  void _openAsthmaActionPlanbottomSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => const AsthmaActionPlanBottomSheet(),
    );
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
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: SvgPicture.asset(
                'assets/svgs/user_assets/user_drawer_icon.svg', // Replace with your custom icon asset path
                width: screenRatio * 10,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Home',
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
          RefreshIndicator(
            color: AppColors.primaryBlue,
            onRefresh: _handleRefresh,
            child: Center(
              child: SizedBox(
                width: screenSize.width,
                height: screenSize.height,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(screenRatio * 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Top section
                        SizedBox(
                          child: screenSize.width <= 390
                              ? Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    NarrowInfoCard(
                                       isLoading:
                                          _baselineScore == ' ' ? true : false,
                                      title: 'Peakflow Baseline',
                                      value: '${homepageData['baseLineScore']}',
                                      backgroundColor: AppColors.primaryBlue,
                                      screenSize: screenSize,
                                      screenRatio: screenRatio,
                                    ),
                                   
                                    SizedBox(height: screenSize.height * 0.01),
                                    NarrowInfoCard(
                                      isLoading:
                                          _steroidDosage == ' ' ? true : false,
                                      title: 'Steroid Dosage',
                                      value: '${homepageData['steroidDosage']}',
                                      backgroundColor: const Color(0xFFFF8500),
                                      screenSize: screenSize,
                                      screenRatio: screenRatio,
                                    ),
                                    SizedBox(height: screenSize.height * 0.01),
                                    NarrowInfoCard(
                                      isLoading: _salbutomalDosage == ' '
                                          ? true
                                          : false,
                                      title: 'Salbutamol Dosage',
                                      value:
                                          '${homepageData['salbutomalDosage']}',
                                      backgroundColor: const Color(0xFF0D8EF8),
                                      screenSize: screenSize,
                                      screenRatio: screenRatio,
                                    ),
                                  ],
                                )
                              : 
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    WideInfoCard(
                                      isLoading:
                                          _baselineScore == ' ' ? true : false,
                                      title: 'Peakflow Baseline',
                                      value: '${homepageData['baseLineScore']}',
                                      backgroundColor: AppColors.primaryBlue,
                                      width: screenSize.width * 0.3,
                                      height: screenSize.height * 0.12,
                                      screenRatio: screenRatio,
                                    ),
                                    WideInfoCard(
                                      isLoading:
                                          _steroidDosage == ' ' ? true : false,
                                      title: 'Steroid Dosage',
                                      value: '${homepageData['steroidDosage']}',
                                      backgroundColor: const Color(0xFFFF8500),
                                      width: screenSize.width * 0.3,
                                      height: screenSize.height * 0.12,
                                      screenRatio: screenRatio,
                                    ),
                                    WideInfoCard(
                                      isLoading: _salbutomalDosage == ' '
                                          ? true
                                          : false,
                                      title: 'Salbutamol Dosage',
                                      value:
                                          '${homepageData['salbutomalDosage']}',
                                      backgroundColor: const Color(0xFF0D8EF8),
                                      width: screenSize.width * 0.3,
                                      height: screenSize.height * 0.12,
                                      screenRatio: screenRatio,
                                    ),
                                  ],
                                ),
                        ),
                        SizedBox(height: screenSize.height * 0.016),
                        // Medication reminder section
                        SizedBox(
                          width: screenSize.width * 0.968,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              MedicationReminderCard(
                                svgAsset:
                                    "assets/svgs/user_assets/peakflow.svg",
                                title: 'Your Peakflow Test',
                                // subtitle: '${homepageData['nextTaskTime']}',
                                subtitle: _nextTaskTime == ' '
                                    ? _buildShimmer()
                                    : Text(
                                        '${homepageData['nextTaskTime']}',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: AppColors.primaryLightBlueText,
                                          fontSize: screenRatio * 9,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                screenRatio: screenRatio,
                                onTap: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/peakflow_record_screen',
                                    (Route<dynamic> route) => false,
                                    arguments: {
                                      'realm': widget.realm,
                                      'deviceToken': widget.deviceToken,
                                      'deviceType': widget.deviceType,
                                    },
                                  );
                                },
                              ),
                              SizedBox(height: screenSize.height * 0.016),
                              MedicationReminderCard(
                                svgAsset: "assets/svgs/user_assets/act.svg",
                                title: 'Your ACT is due in next 2 days',
                                subtitle: Text(
                                  'Due on 20 Feb',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: AppColors.primaryLightBlueText,
                                    fontSize: screenRatio * 9,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                screenRatio: screenRatio,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.016),
                        // Message section
                        SizedBox(
                          width: screenSize.width * 0.968,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: homepageData.isEmpty
                                ? _buildShimmerParagraph()
                                : Text(
                                    '${homepageData['asthmaMessages']!['message']}',
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                      color: AppColors.primaryBlueText,
                                      fontSize: screenRatio * 8,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.016),
                        homepageData['steroidCard'] == null ||
                                homepageData['steroidCard'].isEmpty
                            ? const SizedBox.shrink()
                            : CustomElevatedButton(
                                label: 'View Steroid Card',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SteroidCard(
                                        url: homepageData['steroidCard'],
                                        path: remoteAsthmaActionPlanPDFpath,
                                        screenRatio: screenRatio,
                                      ),
                                    ),
                                  );
                                },
                                isViewSteroidCardButton: true,
                                screenRatio: screenRatio,
                                screenWidth: screenSize.width,
                                screenHeight: screenSize.height,
                              ),
                        SizedBox(height: screenSize.height * 0.016),
                        CustomElevatedButton(
                          label: (homepageData['asthmaActionPlan'] == null ||
                                  homepageData['asthmaActionPlan'].isEmpty)
                              ? 'Upload Personal Asthma Action Plan'
                              : 'View Personal Asthma Action Plan',
                          onPressed: () {
                            homepageData['asthmaActionPlan'].isNotEmpty
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AsthmaActionPlan(
                                        url: homepageData['asthmaActionPlan'],
                                        path: remoteAsthmaActionPlanPDFpath,
                                        screenRatio: screenRatio,
                                      ),
                                    ),
                                  )
                                : _openAsthmaActionPlanbottomSheet(context);
                          },
                          isViewSteroidCardButton: false,
                          screenRatio: screenRatio,
                          screenWidth: screenSize.width,
                          screenHeight: screenSize.height,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 20,
        width: 150,
        color: Colors.white,
      ),
    );
  }

  Widget _buildShimmerParagraph() {
    double width = MediaQuery.of(context).size.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 30,
            width: width,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 30,
            width: width - 100,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 30,
            width: width - 70,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 30,
            width: width,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}