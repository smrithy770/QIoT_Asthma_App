import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:asthmaapp/screens/user_ui/peakflow_screen/peakflow_screen.dart';
import 'package:asthmaapp/screens/user_ui/peakflow_screen/widgets/peakflow_baseline_report_chart.dart';
import 'package:asthmaapp/screens/user_ui/peakflow_screen/widgets/peakflow_percentage.dart';
import 'package:asthmaapp/screens/user_ui/peakflow_screen/widgets/peakflow_zone.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';
import 'package:url_launcher/url_launcher.dart';

class PeakflowBaselineScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  final int? peakflowValue, baseLineScore;
  final String? practionerContact;
  const PeakflowBaselineScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
    this.peakflowValue,
    this.baseLineScore,
    this.practionerContact,
  });

  @override
  State<PeakflowBaselineScreen> createState() => _PeakflowBaselineScreenState();
}

class _PeakflowBaselineScreenState extends State<PeakflowBaselineScreen> {
  UserModel? userModel;
  double peakFlowPercentage = 0.0;
  int integerPeakflowPercentage = 0;
  String stringPeakflowPercentage = '';

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

  Future<void> _makePhoneCall(String? phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber!,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
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

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;

    peakFlowPercentage = ((widget.peakflowValue! / widget.baseLineScore!) * 100);
    stringPeakflowPercentage = peakFlowPercentage.toStringAsFixed(0);
    integerPeakflowPercentage = int.parse(stringPeakflowPercentage);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.primaryWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
              context,
              MaterialPageRoute(
                builder: (context) => PeakflowScreen(
                  realm: widget.realm,
                  deviceToken: widget.deviceToken,
                  deviceType: widget.deviceType,
                ),
              ),
            );
          },
        ),
        title: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            'Peakflow',
            style: TextStyle(
              fontSize: 10 * screenRatio,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const ClampingScrollPhysics(),
        child: Center(
          child: Container(
            width: screenSize.width,
            // height: screenSize.height,
            padding: EdgeInsets.all(screenSize.height * 0.01),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: screenSize.width,
                  height: screenSize.height * 0.024,
                  child: Text(
                    'Result:',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 7 * screenRatio,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                SizedBox(
                  width: screenSize.width,
                  height: screenSize.height * 0.26,
                  child: PeakflowBaselineChart(
                      peakFlow: widget.peakflowValue!,
                      baseLineScore: widget.baseLineScore!,
                      integerPeakflowPercentage: integerPeakflowPercentage),
                ),
                SizedBox(height: screenSize.height * 0.02),
                SizedBox(
                  width: screenSize.width,
                  height: screenSize.height * 0.024,
                  child: Text(
                    'Peakflow Record:',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 7 * screenRatio,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                SizedBox(
                  width: screenSize.width,
                  height: screenSize.height * 0.12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: PeakflowPercentage(
                          integerPeakflowPercentage: integerPeakflowPercentage,
                        ),
                      ),
                      Expanded(
                        child: PeakflowZone(
                          integerPeakflowPercentage: integerPeakflowPercentage,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                SizedBox(
                  width: screenSize.width,
                  height: screenSize.height * 0.024,
                  child: Text(
                    'Instruction:',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 7 * screenRatio,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                SizedBox(
                  width: screenSize.width,
                  height: integerPeakflowPercentage >= 80
                      ? 29 * screenRatio
                      : integerPeakflowPercentage < 80 &&
                              integerPeakflowPercentage >= 50
                          ? 48 * screenRatio
                          : 60 * screenRatio,
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: integerPeakflowPercentage >= 80
                                ? 'Continue to take your preventer inhaler as prescribed, even when you are feeling well. For more information please visit '
                                : integerPeakflowPercentage < 80 &&
                                        integerPeakflowPercentage >= 60
                                    ? 'Increase use of both your preventer and blue inhalers as agreed with your doctor or asthma nurse. If you are repeatedly in Zone 2 ask for an asthma review at your GP practice For more information please visit '
                                    : integerPeakflowPercentage < 60 &&
                                            integerPeakflowPercentage >= 50
                                        ? 'Continue use of both your preventer and blue inhalers and start taking your rescue steroids. Please contact your doctor or asthma nurse within 24 hours for a review. For more information please visit '
                                        : 'You are in the Emergency care Red zone-if you cannot speak in a sentence dial 999 or call your GP urgently. Take up to 10 puffs of reliever inhaler every 5 mins till you improve, or help arrives. For more information please visit ',
                            style: TextStyle(
                              color: const Color(0xFF707070),
                              fontSize: 7 * screenRatio,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: 'asthmaandlung.org.uk',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 7 * screenRatio,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                openLink('www.asthmaandlung.org.uk');
                              },
                          ),
                          const TextSpan(
                            text: ' or ',
                            style: TextStyle(
                              color: Color(0xFF707070),
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: 'nhs.uk',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 7 * screenRatio,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                openLink('www.nhs.uk');
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                integerPeakflowPercentage >= 50
                    ? const SizedBox.shrink()
                    : SizedBox(
                        width: screenSize.width,
                        height: screenSize.height * 0.08,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                _makePhoneCall(widget.practionerContact);
                              },
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size(screenSize.width * 0.32,
                                    screenSize.height * 0.08),
                                foregroundColor: AppColors.primaryWhite,
                                backgroundColor: AppColors.primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                              ),
                              child: Text(
                                'Call ICE',
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 7 * screenRatio,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                            SizedBox(width: screenSize.width * 0.04),
                            ElevatedButton(
                              onPressed: () {
                                _makePhoneCall('999');
                              },
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size(screenSize.width * 0.32,
                                    screenSize.height * 0.08),
                                foregroundColor: AppColors.primaryWhite,
                                backgroundColor: const Color(0xFFFD4646),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                              ),
                              child: Text(
                                'Call 999',
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 7 * screenRatio,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                SizedBox(height: screenSize.height * 0.02),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/steroid_dose_record', // Named route
                      (Route<dynamic> route) => true,
                      arguments: {
                        'realm': widget.realm,
                        'deviceToken': widget.deviceToken,
                        'deviceType': widget.deviceType,
                        'fromPeakflow': true,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(
                      screenSize.width,
                      screenSize.height * 0.064,
                    ),
                    foregroundColor: AppColors.primaryWhite,
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  child: Text(
                    'Did you administer a Steroid dose?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primaryWhite,
                      fontSize: 7 * screenRatio,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Roboto',
                      decorationColor: Color(0xFF0D8EF8),
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                // Advice
                Container(
                  width: screenSize.width,
                  height: 96,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D8EF8).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/svgs/user_assets/about.svg',
                        width: 32,
                        height: 32,
                      ),
                      SizedBox(
                        width: screenSize.width * 0.8,
                        height: 46 * screenRatio,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Peakflow results are for statistical purposes only and also not to be used as an emergency alerts system. They are not a substitute for professional medical advice.',
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              color: AppColors.primaryBlue,
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
                SizedBox(height: screenSize.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
