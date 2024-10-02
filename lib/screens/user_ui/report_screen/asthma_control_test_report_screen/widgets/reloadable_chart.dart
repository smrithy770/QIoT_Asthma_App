import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/asthma_control_test_report_model/asthma_control_test_report_chart_model.dart';
import 'package:asthmaapp/screens/user_ui/report_screen/asthma_control_test_report_screen/widgets/asthma_control_test_report_chart.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ReloadableChart extends StatefulWidget {
  List<AsthmaControlTestReportChartModel> asthmaControlTestReportChartData;
  bool hasData;

  ReloadableChart({
    super.key,
    required this.asthmaControlTestReportChartData,
    required this.hasData,
  });

  @override
  ReloadableChartState createState() => ReloadableChartState();
}

class ReloadableChartState extends State<ReloadableChart> {
  void reloadWidget(
      List<AsthmaControlTestReportChartModel> newData, bool newHasData) {
    setState(() {
      widget.asthmaControlTestReportChartData = newData;
      widget.hasData = newHasData;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    logger.d('ReloadableChart: ${widget.hasData}');
    return AsthmaControlTestReportChart(
      asthmacontroltestReportChartData: widget.asthmaControlTestReportChartData,
      hasData: widget.hasData,
    );
  }
}
