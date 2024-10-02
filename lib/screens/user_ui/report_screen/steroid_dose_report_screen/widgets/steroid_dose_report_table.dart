import 'package:asthmaapp/models/steroid_dose_report_model/steroid_dose_report_table_model.dart';
import 'package:asthmaapp/utils/convertToCustomFormat.dart';
import 'package:flutter/material.dart';

class SteroidDoseReportTable extends StatefulWidget {
  final List<SteroidDoseReportTableModel> steroiddoseReportTableData;
  const SteroidDoseReportTable({
    super.key,
    required this.steroiddoseReportTableData,
  });

  @override
  _SteroidDoseReportTableState createState() => _SteroidDoseReportTableState();
}

class _SteroidDoseReportTableState extends State<SteroidDoseReportTable> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    double screenRatio = screenSize.height / screenSize.width;

    // Define column widths
    final double steroiddoseObservedOnWidth =
        screenSize.width * 0.4; // Adjust as needed
    final double steroidDoseValueWidth =
        screenSize.width * 0.4; // Adjust as needed

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columnSpacing: 2 * screenRatio, // Adjust as per your design
          columns: [
            DataColumn(
              label: SizedBox(
                width: steroiddoseObservedOnWidth, // Set width
                child: Text(
                  'Steroid Dose Observed On',
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
                width: steroidDoseValueWidth, // Set width
                child: Text(
                  'Steroid Dose',
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
          rows: widget.steroiddoseReportTableData.reversed.toList().map((data) {
            return DataRow(cells: [
              DataCell(
                SizedBox(
                  width: steroiddoseObservedOnWidth, // Set width
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
                  width: steroidDoseValueWidth, // Set width
                  child: Text(
                    data.steroidDoseValue.toString(),
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
