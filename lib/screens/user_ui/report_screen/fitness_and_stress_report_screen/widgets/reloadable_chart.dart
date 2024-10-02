import 'package:asthmaapp/models/fitness_and_stress_report_model/fitness_and_stress_report_chart_model.dart';
import 'package:asthmaapp/screens/user_ui/report_screen/fitness_and_stress_report_screen/widgets/fitness_report_chart.dart';
import 'package:asthmaapp/screens/user_ui/report_screen/fitness_and_stress_report_screen/widgets/stress_report_chart.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ReloadableChart extends StatefulWidget {
  List<FitnessAndStressReportChartModel> fitnessandstressChartData;
  bool hasData;
  String tab;

  ReloadableChart({
    super.key,
    required this.fitnessandstressChartData,
    required this.hasData,
    required this.tab,
  });

  @override
  ReloadableChartState createState() => ReloadableChartState();
}

class ReloadableChartState extends State<ReloadableChart> {
  void reloadStressWidget(
      List<FitnessAndStressReportChartModel> newData, bool newHasData) {
    setState(() {
      widget.fitnessandstressChartData = newData;
      widget.hasData = newHasData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.tab == 'fitness'
        ? FitnessReportChart(
            data: widget.fitnessandstressChartData,
            hasData: widget.hasData,
          )
        : StressReportChart(
            data: widget.fitnessandstressChartData,
            hasData: widget.hasData,
          );
  }
}
