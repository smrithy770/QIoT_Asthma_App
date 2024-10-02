import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/models/fitness_and_stress_report_model/fitness_and_stress_report_chart_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// ignore: must_be_immutable
class FitnessReportChart extends StatefulWidget {
  List<FitnessAndStressReportChartModel>? data;
  bool hasData;
  FitnessReportChart({super.key, required this.data, required this.hasData});

  @override
  State<FitnessReportChart> createState() => _FitnessReportChartState();
}

class _FitnessReportChartState extends State<FitnessReportChart> {
  final Map<String, int> fitnessValueMap = {
    'Low': 1,
    'Medium': 2,
    'High': 3,
  };

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    DateFormat formatter = DateFormat('dd MMM - hh:mm a');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final double screenRatio =
        MediaQuery.of(context).size.height / MediaQuery.of(context).size.width;

    return !widget.hasData
        ? const Center(
            child: Text(
              'No stress data available',
              style: TextStyle(
                color: Color(0xFF004283),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
          )
        : SfCartesianChart(
            primaryXAxis: CategoryAxis(
              autoScrollingDelta: 7,
              autoScrollingMode: AutoScrollingMode.end,
              labelRotation: -90,
              edgeLabelPlacement: EdgeLabelPlacement.shift,
              labelStyle: TextStyle(
                fontSize: screenRatio * 4,
                color: Colors.black,
              ),
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(
                text: 'Fitness',
                textStyle: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 5 * screenRatio,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              // Assuming fitness is represented as numeric value
              minimum: 0,
              maximum: 3, // Adjust according to your fitness values
              interval: 1,
              labelFormat: '{value}',
            ),
            legend: Legend(
              isVisible: true,
              legendItemBuilder:
                  (String name, dynamic series, dynamic point, int index) {
                return Center(
                  child: SizedBox(
                    height: screenRatio * 16,
                    width: screenRatio * 128,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          child: Row(
                            children: [
                              SizedBox(
                                child: Row(
                                  children: [
                                    Text(
                                      '1 - Low',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Color(0xFFFD4646),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          child: Row(
                            children: [
                              Text(
                                '2 - Medium',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Color(0xFFF2C94C),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          child: Row(
                            children: [
                              Text(
                                '3 - High',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Color(0xFF27AE60),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries<FitnessAndStressReportChartModel, String>>[
              // Renders column chart
              ColumnSeries<FitnessAndStressReportChartModel, String>(
                dataSource: widget.data!,
                xValueMapper: (FitnessAndStressReportChartModel data, _) =>
                    formatDate(data.createdAt),
                yValueMapper: (FitnessAndStressReportChartModel data, _) {
                  return fitnessValueMap[data.fitness] ?? 0;
                },
                pointColorMapper: (FitnessAndStressReportChartModel data, _) {
                  if (data.fitness == 'High') {
                    return const Color(0xFF27AE60);
                  } else if (data.fitness == 'Medium') {
                    return const Color(0xFFF2C94C);
                  } else {
                    return const Color(0xFFFD4646);
                  }
                },
                dataLabelSettings: const DataLabelSettings(
                  isVisible: false,
                ),
              ),
            ],
          );
  }
}
