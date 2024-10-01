import 'package:asthmaapp/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// ignore: must_be_immutable
class PeakflowBaselineChart extends StatefulWidget {
  final int peakFlow, baseLineScore, integerPeakflowPercentage;
  const PeakflowBaselineChart(
      {super.key,
      required this.peakFlow,
      required this.baseLineScore,
      required this.integerPeakflowPercentage});

  @override
  State<PeakflowBaselineChart> createState() => _PeakflowBaselineChartState();
}

class _PeakflowBaselineChartState extends State<PeakflowBaselineChart> {
  @override
  Widget build(BuildContext context) {
    final List<ChartData> chartData1 = [
      ChartData('Peakflow', widget.peakFlow),
    ];
    final List<ChartData> chartData2 = [
      ChartData('Baseline', widget.baseLineScore),
    ];
    return Scaffold(
      body: Center(
        child: SfCartesianChart(
          primaryXAxis: const CategoryAxis(
            arrangeByIndex: true,
          ),
          primaryYAxis: const NumericAxis(
            minimum: 0,
            maximum: 800,
            interval: 100,
          ),
          palette: <Color>[
            widget.integerPeakflowPercentage >= 80
                ? const Color(0xFF27AE60)
                : widget.integerPeakflowPercentage < 80 &&
                        widget.integerPeakflowPercentage >= 60
                    ? const Color(0xFFFF8500)
                    : const Color(0xFFFD4646),
            AppColors.primaryBlue
          ],
          series: <CartesianSeries<ChartData, String>>[
            // Renders column chart
            ColumnSeries<ChartData, String>(
              dataSource: chartData1,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
              ),
            ),
            // Renders column chart
            ColumnSeries<ChartData, String>(
              color: AppColors.primaryBlue,
              dataSource: chartData2,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final int y;
}
