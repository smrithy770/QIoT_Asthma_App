import 'package:asthmaapp/models/inhaler_report_model/inhaler_report_table_model.dart';
import 'package:asthmaapp/utils/convertToCustomFormat.dart';
import 'package:flutter/material.dart';

class InhalerReportTable extends StatefulWidget {
  final List<InhalerReportTableModel> inhalerReportTableData;
  const InhalerReportTable({
    super.key,
    required this.inhalerReportTableData,
  });

  @override
  _InhalerReportTableState createState() => _InhalerReportTableState();
}

class _InhalerReportTableState extends State<InhalerReportTable> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    double screenRatio = screenSize.height / screenSize.width;

    // Define column widths
    final double peakflowObservedOnWidth =
        screenSize.width * 0.4; // Adjust as needed
    final double peakflowValueWidth =
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
                width: peakflowObservedOnWidth, // Set width
                child: Text(
                  'Inhaler Observed On',
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
                width: peakflowValueWidth, // Set width
                child: Text(
                  'Inhaler Value',
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
          rows: widget.inhalerReportTableData.reversed.toList().map((data) {
            return DataRow(cells: [
              DataCell(
                SizedBox(
                  width: peakflowObservedOnWidth, // Set width
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
                  width: peakflowValueWidth, // Set width
                  child: Text(
                    data.inhalerValue.toString(),
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
