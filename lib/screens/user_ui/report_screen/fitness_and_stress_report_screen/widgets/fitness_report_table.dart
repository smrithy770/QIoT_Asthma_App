import 'package:asthmaapp/models/fitness_and_stress_report_model/fitness_and_stress_report_table_model.dart';
import 'package:asthmaapp/utils/convertToCustomFormat.dart';
import 'package:flutter/material.dart';

class FitnessReportTable extends StatefulWidget {
  final List<FitnessAndStressReportTableModel> data;
  const FitnessReportTable({super.key, required this.data});

  @override
  _FitnessReportTableState createState() => _FitnessReportTableState();
}

class _FitnessReportTableState extends State<FitnessReportTable> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    double screenRatio = screenSize.height / screenSize.width;

    // Define column widths
    final double fitnessObservedOnWidth =
        screenSize.width * 0.4; // Adjust as needed
    final double fitnessWidth = screenSize.width * 0.4; // Adjust as needed

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columnSpacing: 2 * screenRatio, // Adjust as per your design
          columns: [
            DataColumn(
              label: SizedBox(
                width: fitnessObservedOnWidth, // Set width
                child: Text(
                  'Fitness Observed On',
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
                width: fitnessWidth, // Set width
                child: Text(
                  'Fitness',
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
                  width: fitnessObservedOnWidth,
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
                  width: fitnessWidth,
                  child: Text(
                    data.fitness.toString(),
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
