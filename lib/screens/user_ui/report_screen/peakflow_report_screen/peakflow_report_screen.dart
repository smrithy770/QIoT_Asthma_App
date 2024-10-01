import 'dart:io';

import 'package:asthmaapp/api/peakflow_api.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/constants/month_abbreviations.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/peakflow_report_model/peakflow_report_chart_model.dart';
import 'package:asthmaapp/models/peakflow_report_model/peakflow_report_table_model.dart';
import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:asthmaapp/screens/user_ui/report_screen/peakflow_report_screen/widgets/peakflow_legends_zone.dart';
import 'package:asthmaapp/screens/user_ui/report_screen/peakflow_report_screen/widgets/peakflow_report_table.dart';
import 'package:asthmaapp/screens/user_ui/report_screen/peakflow_report_screen/widgets/reloadable_chart.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

class PeakflowReportsScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const PeakflowReportsScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<PeakflowReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<PeakflowReportsScreen> {
  UserModel? userModel;
  Map<String, dynamic> peakflowReportData = {};

  List<PeakflowReportChartModel> peakflowReportChartData = [];
  List<PeakflowReportTableModel> peakflowReportTableData = [];

  DateTime currentDate = DateTime.now();
  int currentMonth = 1;
  int currentYear = 1;

  @override
  void initState() {
    super.initState();
    setState(() {
      currentMonth = currentDate.month;
      currentYear = currentDate.year;
    });
    _loadUserData();
    _handleRefresh(currentMonth, currentYear);
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

  Future<void> _handleRefresh(int currentMonth, int currentYear) async {
    try {
      final jsonResponse = await PeakflowApi().getPeakflowHistory(
        userModel!.userId,
        currentMonth,
        currentYear,
        userModel!.accessToken,
      );
      final status = jsonResponse['status'];
      if (status == 200) {
        final payload = jsonResponse['payload'];
        setState(() {
          peakflowReportData = payload;
        });
        for (var i in peakflowReportData['peakflow']) {
          peakflowReportChartData.add(
            PeakflowReportChartModel(
              i['createdAt'],
              i['peakflowValue'],
            ),
          );
          peakflowReportTableData.add(
            PeakflowReportTableModel(
              i['createdAt'],
              i['peakflowValue'],
              i['highValue'],
              i['lowValue'],
              double.tryParse(i['averageValue'].toString()) ?? 0.0, 
              i['dailyVariation'],
            ),
          );
        }
      }
    } on SocketException catch (e) {
      logger.e('NetworkException: $e');
    } on Exception catch (e) {
      logger.e('Failed to fetch data: $e');
    }
  }

  void getPrevMonth() {
    setState(() {
      peakflowReportChartData.clear();
      // peakflowTableData.clear();
      currentMonth -= 1;
      if (currentMonth == 0) {
        currentMonth = 12;
        currentYear -= 1;
      }
    });
    _handleRefresh(currentMonth, currentYear);
  }

  void getNextMonth() {
    setState(() {
      peakflowReportChartData.clear();
      // peakflowTableData.clear();
      currentMonth += 1;
      if (currentMonth == 13) {
        currentMonth = 1;
        currentYear += 1;
      }
    });
    _handleRefresh(currentMonth, currentYear);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Peakflow Reports',
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
                  // Peakflow Recorded On
                  Container(
                    width: screenSize.width,
                    height: screenSize.height * 0.06,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D8EF8).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: screenSize.width * 0.4,
                          height: 46,
                          padding: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.02),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Peakflow recorded on:',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 6 * screenRatio,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: screenSize.width * 0.52,
                          height: 46,
                          padding: EdgeInsets.symmetric(
                              horizontal: screenSize.width * 0.02),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              peakflowReportData['peakflowRecordedOn']
                                  .toString(),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 6 * screenRatio,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  // Month Selector
                  SizedBox(
                    width: screenSize.width,
                    height: screenSize.height * 0.06,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Peakflow Record
                        Align(
                          alignment: Alignment.centerLeft,
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
                        // Month Selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left Arrow
                            GestureDetector(
                              onTap: () {
                                getPrevMonth();
                              },
                              child: Container(
                                width: 36,
                                height: 52,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: AppColors.primaryBlue
                                          .withOpacity(0.4),
                                      width: 2,
                                    ),
                                    left: BorderSide(
                                      color: AppColors.primaryBlue
                                          .withOpacity(0.4),
                                      width: 2,
                                    ),
                                    right: BorderSide(
                                      color: AppColors.primaryBlue
                                          .withOpacity(0.4),
                                      width: 2,
                                    ),
                                    bottom: BorderSide(
                                      color: AppColors.primaryBlue
                                          .withOpacity(0.4),
                                      width: 2,
                                    ),
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                  ),
                                  shape: BoxShape.rectangle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    size: 40,
                                    Icons.arrow_left_rounded,
                                    color: Color(0xFF004283),
                                  ),
                                ),
                              ),
                            ),
                            // Container for the month
                            Container(
                              width: 80,
                              height: 52,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: const Color(0xFF004283)
                                        .withOpacity(0.4),
                                    width: 2,
                                  ),
                                  bottom: BorderSide(
                                    color: const Color(0xFF004283)
                                        .withOpacity(0.4),
                                    width: 2,
                                  ),
                                ),
                                shape: BoxShape.rectangle,
                              ),
                              child: Center(
                                child: Text(
                                  '${monthAbbreviations[currentMonth - 1]} - $currentYear',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 6 * screenRatio,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ),
                            ),
                            // Right Arrow
                            GestureDetector(
                              onTap: () {
                                getNextMonth();
                              },
                              child: Container(
                                width: 36,
                                height: 52,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: const Color(0xFF004283)
                                          .withOpacity(0.4),
                                      width: 2,
                                    ),
                                    left: BorderSide(
                                      color: const Color(0xFF004283)
                                          .withOpacity(0.4),
                                      width: 2,
                                    ),
                                    right: BorderSide(
                                      color: const Color(0xFF004283)
                                          .withOpacity(0.4),
                                      width: 2,
                                    ),
                                    bottom: BorderSide(
                                      color: const Color(0xFF004283)
                                          .withOpacity(0.4),
                                      width: 2,
                                    ),
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                  shape: BoxShape.rectangle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    size: 40,
                                    Icons.arrow_right_rounded,
                                    color: Color(0xFF004283),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Peakflow Chart
                  SizedBox(
                    width: screenSize.width,
                    height: 160 * screenRatio,
                    child: ReloadableChart(
                      baseLineScore:
                          peakflowReportData['baseLineScore'].toString(),
                      peakflowReportChartData: peakflowReportChartData,
                      hasData:
                          peakflowReportChartData.isNotEmpty ? true : false,
                    ),
                  ),
                  // Peakflow Legends Zone
                  PeakflowLegendsZone(
                    screenRatio: screenRatio,
                    screenSize: screenSize,
                  ),
                  // Peakflow Table
                  Expanded(
                    child: peakflowReportChartData.isNotEmpty
                        ? SizedBox(
                            key: ValueKey(currentMonth),
                            width: screenSize.width,
                            child: PeakflowReportTable(
                              peakflowReportTableData: peakflowReportTableData,
                            ),
                          )
                        : const SizedBox.shrink(),
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
