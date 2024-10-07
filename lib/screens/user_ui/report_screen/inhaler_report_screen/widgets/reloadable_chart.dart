import 'package:asthmaapp/models/inhaler_report_model/inhaler_report_chart_model.dart';
import 'package:asthmaapp/screens/user_ui/report_screen/inhaler_report_screen/widgets/inhaler_report_chart.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ReloadableChart extends StatefulWidget {
  List<InhalerReportChartModel> inhalerReportChartData;
  bool hasData;

  ReloadableChart({
    super.key,
    required this.inhalerReportChartData,
    required this.hasData,
  });

  @override
  ReloadableChartState createState() => ReloadableChartState();
}

class ReloadableChartState extends State<ReloadableChart> {
  void reloadWidget(List<InhalerReportChartModel> newData, bool newHasData) {
    setState(() {
      widget.inhalerReportChartData = newData;
      widget.hasData = newHasData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InhalerReportChart(
      inhalerReportChartData: widget.inhalerReportChartData,
      hasData: widget.hasData,
    );
  }
}
