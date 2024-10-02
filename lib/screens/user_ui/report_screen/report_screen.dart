import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:asthmaapp/screens/user_ui/report_screen/widgets/report_items_widget.dart';
import 'package:asthmaapp/screens/user_ui/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';

class ReportsScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const ReportsScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
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
            'Reports',
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
              height: screenSize.height,
              padding: EdgeInsets.all(screenSize.width * 0.016),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Advice
                  Container(
                    width: screenSize.width,
                    height: screenSize.height * 0.08,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D8EF8).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/svgs/user_assets/about.svg',
                            width: 16 * screenRatio,
                            height: 16 * screenRatio,
                          ),
                          SizedBox(
                            width: screenSize.width * 0.8,
                            height: screenSize.height * 0.08,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Reports are for statistical analysis only and not to be used as a substitute for medical advice.',
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                  color: Color(0xFF004283),
                                  fontSize: 6 * screenRatio,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Expanded(
                    child: GridView(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 128 * screenRatio,
                        mainAxisSpacing: 8 * screenRatio,
                        mainAxisExtent: 80 *
                            screenRatio, // 90 is the height of the grid item
                        crossAxisSpacing: 8 * screenRatio,
                      ),
                      children: [
                        // Peakflow Report
                        ReportItem(
                          assetPath:
                              'assets/svgs/user_assets/peakflow_report.svg',
                          reportTitle: 'Peakflow',
                          backgroundColor: const Color(0xFF004283),
                          textColor: const Color(0xFF004283),
                          screenRatio: screenRatio,
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/peakflow_reports_screen',
                              (Route<dynamic> route) => true,
                              arguments: {
                                'realm': widget.realm,
                                'deviceToken': widget.deviceToken,
                                'deviceType': widget.deviceType,
                              },
                            );
                          },
                        ),
                        // Inhaler Cap Report
                        ReportItem(
                          assetPath:
                              'assets/svgs/user_assets/peakflow_report.svg',
                          reportTitle: 'Inhaler Cap',
                          backgroundColor: const Color(0xFF004283),
                          textColor: const Color(0xFF004283),
                          screenRatio: screenRatio,
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/inhaler_reports_screen',
                              (Route<dynamic> route) => true,
                              arguments: {
                                'realm': widget.realm,
                                'deviceToken': widget.deviceToken,
                                'deviceType': widget.deviceType,
                              },
                            );
                          },
                        ),
                        // Steroid Dosage Report
                        ReportItem(
                          assetPath:
                              'assets/svgs/user_assets/steroid_report.svg',
                          reportTitle: 'Steroid Dosage',
                          backgroundColor: const Color(0xFFFF8500),
                          textColor: const Color(0xFFFF8500),
                          screenRatio: screenRatio,
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/steroid_dose_report_screen',
                              (Route<dynamic> route) => true,
                              arguments: {
                                'realm': widget.realm,
                                'deviceToken': widget.deviceToken,
                                'deviceType': widget.deviceType,
                              },
                            );
                          },
                        ),
                        // ACT Report
                        ReportItem(
                          assetPath: 'assets/svgs/user_assets/act_report.svg',
                          reportTitle: 'ACT',
                          backgroundColor: const Color(0xFF27AE60),
                          textColor: const Color(0xFF27AE60),
                          screenRatio: screenRatio,
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/asthma_control_test_report_screen',
                              (Route<dynamic> route) => true,
                              arguments: {
                                'realm': widget.realm,
                                'deviceToken': widget.deviceToken,
                                'deviceType': widget.deviceType,
                              },
                            );
                          },
                        ),
                        // Fitness and Stress Report
                        ReportItem(
                          assetPath:
                              'assets/svgs/user_assets/fitness_stress_report.svg',
                          reportTitle: 'Fitness and Stress',
                          backgroundColor: const Color(0xFF004283),
                          textColor: AppColors.primaryBlue,
                          screenRatio: screenRatio,
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/fitness_and_stress_report_screen',
                              (Route<dynamic> route) => true,
                              arguments: {
                                'realm': widget.realm,
                                'deviceToken': widget.deviceToken,
                                'deviceType': widget.deviceType,
                              },
                            );
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
