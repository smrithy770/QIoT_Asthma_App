import 'dart:io';

import 'package:asthmaapp/api/inhaler_api.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/inhaler_report_model/inhaler_report_chart_model.dart';
import 'package:asthmaapp/models/inhaler_report_model/inhaler_report_table_model.dart';
import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

class InhalerReportScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const InhalerReportScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<InhalerReportScreen> createState() => _InhalerReportScreenState();
}

class _InhalerReportScreenState extends State<InhalerReportScreen> {
  UserModel? userModel;
  Map<String, dynamic> peakflowReportData = {};

  List<InhalerReportChartModel> inhalerReportChartData = [];
  List<InhalerReportTableModel> inhalerReportTableData = [];

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
      final jsonResponse = await InhalerApi().getInhalerHistory(
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
          inhalerReportChartData.add(
            InhalerReportChartModel(
              i['createdAt'],
              i['inhalerValue'],
            ),
          );
          inhalerReportTableData.add(
            InhalerReportTableModel(
              i['createdAt'],
              i['inhalerValue'],
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
      inhalerReportChartData.clear();
      inhalerReportTableData.clear();
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
      inhalerReportChartData.clear();
      inhalerReportTableData.clear();
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
            'Inhaler Reports',
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
                children: [],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
