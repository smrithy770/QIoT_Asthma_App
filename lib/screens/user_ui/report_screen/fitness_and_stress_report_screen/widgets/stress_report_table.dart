import 'package:asthmaapp/models/fitness_and_stress_report_model/fitness_and_stress_report_table_model.dart';
import 'package:asthmaapp/utils/convertToCustomFormat.dart';
import 'package:flutter/material.dart';

class StressReportTable extends StatefulWidget {
  final List<FitnessAndStressReportTableModel> data;
  const StressReportTable({super.key, required this.data});

  @override
  _StressReportTableState createState() => _StressReportTableState();
}

class _StressReportTableState extends State<StressReportTable> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    double screenRatio = screenSize.height / screenSize.width;

// Define column widths
    final double stressObservedOnWidth =
        screenSize.width * 0.4; // Adjust as needed
    final double stressWidth = screenSize.width * 0.4; // Adjust as needed

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columnSpacing: 16, // Adjust as per your design
          columns: [
            DataColumn(
              label: SizedBox(
                width: stressObservedOnWidth,
                child: Text(
                  'Stress Observed On',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 5 * screenRatio,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: stressWidth,
                child: Text(
                  'Stress',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 5 * screenRatio,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
          ],
          rows: widget.data.reversed.toList().map((data) {
            return DataRow(cells: [
              DataCell(
                SizedBox(
                  width: stressObservedOnWidth,
                  child: Text(
                    convertToCustomFormat(data.createdAt.toString()),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 5 * screenRatio,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: stressWidth,
                  child: Text(
                    data.stress.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 5 * screenRatio,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
