import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/inhaler_report_model/inhaler_report_chart_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// ignore: must_be_immutable
class InhalerReportChart extends StatefulWidget {
  final List<InhalerReportChartModel>? inhalerReportChartData;
  final bool hasData;

  const InhalerReportChart({
    super.key,
    required this.inhalerReportChartData,
    required this.hasData,
  });

  @override
  State<InhalerReportChart> createState() => _InhalerReportChartState();
}

class _InhalerReportChartState extends State<InhalerReportChart> {
  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    DateFormat formatter = DateFormat('dd MMM - hh:mm a');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final double screenRatio =
        MediaQuery.of(context).size.height / MediaQuery.of(context).size.width;

    logger.d('Inhaler: ${widget.hasData}');
    return !widget.hasData
        ? Center(
            child: Text(
              'No inhaler data available',
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
              maximum: 10,
              interval: 1,
            ),
            legend: const Legend(
              isVisible: false,
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              header: 'Inhaler',
            ),
            series: <CartesianSeries<InhalerReportChartModel, String>>[
              LineSeries<InhalerReportChartModel, String>(
                dataSource: widget.inhalerReportChartData,
                xValueMapper: (InhalerReportChartModel inhaler, _) =>
                    formatDate(inhaler.createdAt),
                yValueMapper: (InhalerReportChartModel inhaler, _) =>
                    inhaler.inhalerValue,
                markerSettings: const MarkerSettings(isVisible: true),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                ),
              ),
            ],
          );
  }
}
