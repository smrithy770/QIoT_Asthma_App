import 'package:asthmaapp/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';

class SteroidDoseReportsScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const SteroidDoseReportsScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<SteroidDoseReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<SteroidDoseReportsScreen> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.primaryWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Steroid Dose Reports',
            style: TextStyle(
              fontSize: screenRatio * 10,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
