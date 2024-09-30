import 'package:asthmaapp/models/user_model.dart';
import 'package:asthmaapp/screens/user_ui/asthma_control_test_screen/asthma_control_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AsthmaControlTestResultScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  final int totalScore;
  const AsthmaControlTestResultScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
    required this.totalScore,
  });

  @override
  State<AsthmaControlTestResultScreen> createState() =>
      _AsthmaControlTestResultScreenState();
}

class _AsthmaControlTestResultScreenState
    extends State<AsthmaControlTestResultScreen> {
  UserModel? userModel;
  late List<ACTData> _chartData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _chartData = getChartData();
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

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF004283),
        foregroundColor: const Color(0xFFFFFFFF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
              context,
              MaterialPageRoute(
                builder: (context) => AsthmaControlTestScreen(
                  realm: widget.realm,
                  deviceToken: widget.deviceToken,
                  deviceType: widget.deviceType,
                ),
              ),
            );
          },
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'ACT Result',
            style: TextStyle(
              fontSize: 22,
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
                    child: const Text(
                      'Your Asthma Score',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF004283),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  SizedBox(
                    width: screenSize.width * 0.5,
                    height: screenSize.width * 0.5,
                    child: SfCircularChart(
                      palette: <Color>[
                        widget.totalScore <= 20
                            ? const Color(0xFFFD4646)
                            : widget.totalScore < 25 && widget.totalScore > 20
                                ? const Color(0xFFFF8500)
                                : const Color(0xFF27AE60),
                      ],
                      annotations: <CircularChartAnnotation>[
                        CircularChartAnnotation(
                          widget: SizedBox(
                            child: Text(
                              widget.totalScore.toString(),
                              style: TextStyle(
                                color: widget.totalScore <= 20
                                    ? const Color(0xFFFD4646)
                                    : widget.totalScore < 25 &&
                                            widget.totalScore > 20
                                        ? const Color(0xFFFF8500)
                                        : const Color(0xFF27AE60),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ),
                      ],
                      series: <CircularSeries>[
                        RadialBarSeries<ACTData, String>(
                          dataSource: _chartData,
                          xValueMapper: (ACTData data, _) => data.actScore,
                          yValueMapper: (ACTData data, _) => data.score,
                          dataLabelSettings:
                              const DataLabelSettings(isVisible: false),
                          enableTooltip: true,
                          maximumValue: 25,
                          cornerStyle: CornerStyle.bothCurve,
                          innerRadius: '80%',
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  SizedBox(
                    width: screenSize.width,
                    height: screenSize.height * 0.024,
                    child: const Text(
                      'What does your score mean?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF004283),
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  // Advice
                  Container(
                    width: screenSize.width,
                    height: screenRatio * 32,
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
                              'ACT test results are for statistical analysis only and also not to be used as an emergency alerts system. They are not a substitute for professional medical advice.',
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                color: const Color(0xFF004283),
                                fontSize: 5 * screenRatio,
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
                  Container(
                    width: screenSize.width,
                    height: screenSize.height * 0.20,
                    padding: EdgeInsets.all(screenSize.height * 0.01),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/svgs/user_assets/thumbs_up.svg',
                              width: 32,
                            ),
                            SizedBox(width: screenSize.width * 0.04),
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Score:25',
                                  style: TextStyle(
                                    color: Color(0xFF27AE60),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                Text(
                                  'Well Done',
                                  style: TextStyle(
                                    color: Color(0xFF27AE60),
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: screenSize.height * 0.01),
                        RichText(
                            text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Your asthma appears to have been ',
                              style: TextStyle(
                                color: Color(0xFF6C6C6C),
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            TextSpan(
                              text: 'UNDER CONTROL ',
                              style: TextStyle(
                                color: Color(0xFF27AE60),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            TextSpan(
                              text:
                                  'over the last 4 weeks. However if you are experiencing any problems with your asthma, you should see your doctor or nurse.',
                              style: TextStyle(
                                color: Color(0xFF6C6C6C),
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Container(
                    width: screenSize.width,
                    height: screenSize.height * 0.20,
                    padding: EdgeInsets.all(screenSize.height * 0.01),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8500).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/svgs/user_assets/target.svg',
                              width: 32,
                            ),
                            SizedBox(width: screenSize.width * 0.04),
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Score:20-24',
                                  style: TextStyle(
                                    color: Color(0xFFFF8500),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                Text(
                                  'On Target',
                                  style: TextStyle(
                                    color: Color(0xFFFF8500),
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: screenSize.height * 0.01),
                        RichText(
                            text: const TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'Your asthma appears to have been reasonably ',
                              style: TextStyle(
                                color: Color(0xFF6C6C6C),
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            TextSpan(
                              text: 'WELL CONTROLLED ',
                              style: TextStyle(
                                color: Color(0xFFFF8500),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            TextSpan(
                              text:
                                  'during the past 4 weeks. However if you are experiencing any problems with your asthma, you should see your doctor.',
                              style: TextStyle(
                                color: Color(0xFF6C6C6C),
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Container(
                    width: screenSize.width,
                    height: screenSize.height * 0.20,
                    padding: EdgeInsets.all(screenSize.height * 0.01),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFD4646).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/svgs/user_assets/alert.svg',
                              width: 32,
                            ),
                            SizedBox(width: screenSize.width * 0.04),
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Score:20',
                                  style: TextStyle(
                                    color: Color(0xFFFD4646),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                Text(
                                  'Off Target',
                                  style: TextStyle(
                                    color: Color(0xFFFD4646),
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: screenSize.height * 0.01),
                        RichText(
                            text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Your asthma may have been ',
                              style: TextStyle(
                                color: Color(0xFF6C6C6C),
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            TextSpan(
                              text: 'UNCONTROLLED ',
                              style: TextStyle(
                                color: Color(0xFFFD4646),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            TextSpan(
                              text:
                                  'during the past 4 weeks. Your doctor or nurse can recommended an asthma action plan to help improve your asthma control.',
                              style: TextStyle(
                                color: Color(0xFF6C6C6C),
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        )),
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

  List<ACTData> getChartData() {
    final List<ACTData> chartData = [
      ACTData('Score', widget.totalScore),
    ];
    return chartData;
  }
}

class ACTData {
  ACTData(this.actScore, this.score);
  final String actScore;
  final int score;
}
