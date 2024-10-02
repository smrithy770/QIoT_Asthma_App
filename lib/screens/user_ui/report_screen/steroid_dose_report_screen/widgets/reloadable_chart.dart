import 'package:asthmaapp/models/steroid_dose_report_model/steroid_dose_report_chart_model.dart';
import 'package:asthmaapp/screens/user_ui/report_screen/steroid_dose_report_screen/widgets/steroid_dose_report_chart.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ReloadableChart extends StatefulWidget {
  List<SteroidDoseReportChartModel> steroiddoseReportChartData;
  bool hasData;

  ReloadableChart({
    super.key,
    required this.steroiddoseReportChartData,
    required this.hasData,
  });

  @override
  ReloadableChartState createState() => ReloadableChartState();
}

class ReloadableChartState extends State<ReloadableChart> {
  void reloadWidget(
      List<SteroidDoseReportChartModel> newData, bool newHasData) {
    // logger.d("Reloadable Check: $newData and $newHasData");
    setState(() {
      widget.steroiddoseReportChartData = newData;
      widget.hasData = newHasData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SteroidDoseReportChart(
      steroiddoseReportChartData: widget.steroiddoseReportChartData,
      hasData: widget.hasData,
    );
  }
}
