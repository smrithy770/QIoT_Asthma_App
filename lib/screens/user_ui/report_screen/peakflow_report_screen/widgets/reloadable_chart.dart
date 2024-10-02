import 'package:asthmaapp/models/peakflow_report_model/peakflow_report_chart_model.dart';
import 'package:asthmaapp/screens/user_ui/report_screen/peakflow_report_screen/widgets/peakflow_report_chart.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ReloadableChart extends StatefulWidget {
  String baseLineScore;
  List<PeakflowReportChartModel> peakflowReportChartData;
  bool hasData;

  ReloadableChart({
    super.key,
    required this.baseLineScore,
    required this.peakflowReportChartData,
    required this.hasData,
  });

  @override
  ReloadableChartState createState() => ReloadableChartState();
}

class ReloadableChartState extends State<ReloadableChart> {
  void reloadWidget(List<PeakflowReportChartModel> newData, bool newHasData) {
    setState(() {
      widget.peakflowReportChartData = newData;
      widget.hasData = newHasData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PeakflowReportChart(
      baseLineScore: widget.baseLineScore,
      peakflowReportChartData: widget.peakflowReportChartData,
      hasData: widget.hasData,
    );
  }
}
