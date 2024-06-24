import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/screens/peakflow_screen/widgets/peakflow_bottom_sheet_info.dart';
import 'package:asthmaapp/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

class PeakflowScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const PeakflowScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<PeakflowScreen> createState() => _PeakflowScreenState();
}

class _PeakflowScreenState extends State<PeakflowScreen> {
  void _openpeakflowbottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => const PeakflowBottomSheetInfo(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: const Color(0xFF004283),
        foregroundColor: const Color(0xFFFFFFFF),
        title: const Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            'Peakflow',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
      drawer: CustomDrawer(
        realm: widget.realm,
        deviceToken: widget.deviceToken,
        deviceType: widget.deviceType,
        onClose: () {
          Navigator.of(context).pop();
        },
        onItemSelected: (int index) {
          print(index);
        },
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Container(
            color: AppColors.primaryWhite,
            width: screenSize.width,
            padding: EdgeInsets.all(screenSize.width * 0.016),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _openpeakflowbottomSheet(context);
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(
                      screenSize.width * 1.0,
                      screenSize.height * 0.06,
                    ),
                    foregroundColor: AppColors.primaryWhite,
                    backgroundColor: AppColors.errorRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Too Breathless to Perform?',
                    style: TextStyle(
                      color: AppColors.primaryWhiteText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
