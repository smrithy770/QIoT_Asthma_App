import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/peakflow_report_model/peakflow_report_chart_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// ignore: must_be_immutable
class PeakflowReportChart extends StatefulWidget {
  final List<PeakflowReportChartModel>? peakflowReportChartData;
  final String baseLineScore;
  final bool hasData;

  const PeakflowReportChart({
    super.key,
    required this.peakflowReportChartData,
    required this.baseLineScore,
    required this.hasData,
  });

  @override
  State<PeakflowReportChart> createState() => _PeakflowReportChartState();
}

class _PeakflowReportChartState extends State<PeakflowReportChart> {
  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    DateFormat formatter = DateFormat('dd MMM - hh:mm a');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final double screenRatio =
        MediaQuery.of(context).size.height / MediaQuery.of(context).size.width;

    logger.d('Peakflow: ${widget.hasData}');
    return !widget.hasData
        ? Center(
            child: Text(
              'No peakflow data available',
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
            primaryYAxis: NumericAxis(
              // Changed from CategoryAxis to NumericAxis
              minimum: 0,
              maximum: 800,
              interval: 100,
              plotBands: [
                PlotBand(
                  verticalTextPadding: '5%',
                  horizontalTextPadding: '5%',
                  textAngle: 0,
                  start: double.parse(widget
                      .baseLineScore), // Ensure base line score is parsed to double
                  end: double.parse(widget.baseLineScore),
                  borderColor: const Color(0xFF27AE60).withOpacity(1),
                  borderWidth: 2,
                ),
                PlotBand(
                  start: 0,
                  end: 200,
                  color: const Color(0xFFFD4646).withOpacity(0.4),
                ),
                PlotBand(
                  start: 200,
                  end: 400,
                  color: const Color(0xFFFF8500).withOpacity(0.4),
                ),
                PlotBand(
                  start: 400,
                  end: 800,
                  color: const Color(0xFF27AE60).withOpacity(0.4),
                ),
              ],
            ),
            legend: const Legend(
              isVisible: false,
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              header: 'Peakflow',
            ),
            series: <CartesianSeries<PeakflowReportChartModel, String>>[
              LineSeries<PeakflowReportChartModel, String>(
                dataSource: widget.peakflowReportChartData,
                xValueMapper: (PeakflowReportChartModel peakflow, _) =>
                    formatDate(peakflow.createdAt),
                yValueMapper: (PeakflowReportChartModel peakflow, _) =>
                    peakflow.peakflowValue,
                markerSettings: const MarkerSettings(isVisible: true),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                ),
              ),
            ],
          );
  }
}
