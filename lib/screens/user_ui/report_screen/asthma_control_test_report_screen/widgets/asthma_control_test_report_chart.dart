import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/asthma_control_test_report_model/asthma_control_test_report_chart_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// ignore: must_be_immutable
class AsthmaControlTestReportChart extends StatefulWidget {
  List<AsthmaControlTestReportChartModel>? asthmacontroltestReportChartData;
  bool hasData;
  AsthmaControlTestReportChart(
      {super.key,
      required this.asthmacontroltestReportChartData,
      required this.hasData});

  @override
  State<AsthmaControlTestReportChart> createState() =>
      _AsthmaControlTestReportChartState();
}

class _AsthmaControlTestReportChartState
    extends State<AsthmaControlTestReportChart> {
  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    DateFormat formatter = DateFormat('dd MMM - hh:mm a');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final double screenRatio =
        MediaQuery.of(context).size.height / MediaQuery.of(context).size.width;
    logger.d('AsthmaControlTestReportChart: ${widget.hasData}');
    return !widget.hasData
        ? Center(
            child: Text(
              'No asthma control test data available',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 6 * screenRatio,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
          )
        : SfCartesianChart(
            zoomPanBehavior: ZoomPanBehavior(
              enablePanning: true,
            ),
            enableAxisAnimation: true,
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
            primaryYAxis: const NumericAxis(
              // Assuming fitness is represented as numeric value
              minimum: 0,
              maximum: 30, // Adjust according to your fitness values
              interval: 5,
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                child: Row(
                                  children: [
                                    Text(
                                      'Value:25',
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
                        SizedBox(
                          child: Row(
                            children: [
                              Text(
                                'Value:21-24',
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
                                'Value:<20',
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
                );
              },
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              header: 'Asthma Control Test',
            ),
            series: <CartesianSeries<AsthmaControlTestReportChartModel,
                String>>[
              // Renders column chart
              ColumnSeries<AsthmaControlTestReportChartModel, String>(
                dataSource: widget.asthmacontroltestReportChartData!,
                xValueMapper: (AsthmaControlTestReportChartModel
                            asthmacontroltestReportChartData,
                        _) =>
                    formatDate(asthmacontroltestReportChartData.createdAt),
                yValueMapper: (AsthmaControlTestReportChartModel
                            asthmacontroltestReportChartData,
                        _) =>
                    asthmacontroltestReportChartData.asthmacontroltestValue,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: false,
                ),
                pointColorMapper: (AsthmaControlTestReportChartModel
                        asthmacontroltestReportChartData,
                    _) {
                  if (asthmacontroltestReportChartData.asthmacontroltestValue <
                      21) {
                    return const Color(0xFFFD4646);
                  } else if (asthmacontroltestReportChartData
                          .asthmacontroltestValue <
                      25) {
                    return const Color(0xFFF2C94C);
                  } else {
                    return const Color(0xFF27AE60);
                  }
                },
              ),
            ],
          );
  }
}
