import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/steroid_dose_report_model/steroid_dose_report_chart_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// ignore: must_be_immutable
class SteroidDoseReportChart extends StatefulWidget {
  final List<SteroidDoseReportChartModel>? steroiddoseReportChartData;
  final bool hasData;

  const SteroidDoseReportChart({
    super.key,
    required this.steroiddoseReportChartData,
    required this.hasData,
  });

  @override
  State<SteroidDoseReportChart> createState() => _SteroidDoseReportChartState();
}

class _SteroidDoseReportChartState extends State<SteroidDoseReportChart> {
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
              'No steroid dose data available',
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
              // Changed from CategoryAxis to NumericAxis
              minimum: 0,
              maximum: 200,
              interval: 100,
            ),
            legend: const Legend(
              isVisible: false,
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              header: 'Steroid Dose',
            ),
            series: <CartesianSeries<SteroidDoseReportChartModel, String>>[
              LineSeries<SteroidDoseReportChartModel, String>(
                dataSource: widget.steroiddoseReportChartData,
                xValueMapper: (SteroidDoseReportChartModel steroiddose, _) =>
                    formatDate(steroiddose.createdAt),
                yValueMapper: (SteroidDoseReportChartModel steroiddose, _) =>
                    steroiddose.steroiddoseValue,
                markerSettings: const MarkerSettings(isVisible: true),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                ),
              ),
            ],
          );
  }
}
