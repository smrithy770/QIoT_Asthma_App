import 'package:asthmaapp/constants/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AsthmaActionPlanBottomSheet extends StatefulWidget {
  const AsthmaActionPlanBottomSheet({super.key});

  @override
  State<AsthmaActionPlanBottomSheet> createState() =>
      _AsthmaActionPlanBottomSheetState();
}

class _AsthmaActionPlanBottomSheetState
    extends State<AsthmaActionPlanBottomSheet> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  FilePickerResult? result;
  String? _result;

  Future<void> _pickAsthmaActionPlan() async {
    result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'pdf'
      ], // Add the extensions of allowed file types
    );

    if (result != null) {
      setState(() {
        _result = result!.files.single.path!;
      });
    } else {
      setState(() {
        _result = '';
      });
    }
  }

  Future<void> _submitAsthmaActionPlan() async {
    // PlatformFile file = result!.files.first;
    // // Handle the picked file, you can upload it to a server or store it locally
    // try {
    //   AsthmaActionPlanApi()
    //       .uploadAsthmaActionPlanData(file.path.toString())
    //       .then((value) async {
    //     if (value != null) {
    //       logger.d('Submitted: $value');
    //       Navigator.pop(context);

    //       CustomSnackBarUtil.showCustomSnackBar(
    //           'Your Asthma Action Plan has been uploaded!',
    //           success: true);
    //     }
    //   });
    // } catch (e) {
    //   logger.d('Error: $e');
    //   throw Exception('Error: $e');
    //   // CustomSnackBar(
    //   //   message: 'Error: $e!',
    //   //   success: false,
    //   // );
    // }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Container(
        width: screenSize.width,
        height: 320 * screenRatio,
        padding: EdgeInsets.all(screenSize.height * 0.02),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/svgs/cross.svg',
                    width: 24,
                    height: 24,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Text(
              'To upload your personal asthma action plan',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 8 * screenRatio,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: screenSize.height * 0.01),
            Text(
              'If you have a Personal Asthma Action Plan as agreed by your \nGP or asthma nurse, you can upload a digital version here.',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 6 * screenRatio,
                fontWeight: FontWeight.normal,
                fontFamily: 'Roboto',
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: screenSize.height * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                SizedBox(
                  width: screenSize.width * 0.04,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // 1st Dot
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(
                          left: 0,
                          top: 12,
                          right: 0,
                          bottom: 4,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF004283),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // 1st Dash
                      const Dash(
                        direction: Axis.vertical,
                        length: 22,
                        dashLength: 4,
                        dashColor: Color(0xFFFF8500),
                      ),
                      // 2nd Dot
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(
                          left: 0,
                          top: 4,
                          right: 0,
                          bottom: 4,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF004283),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // 2nd Dash
                      const Dash(
                        direction: Axis.vertical,
                        length: 40,
                        dashLength: 4,
                        dashColor: Color(0xFFFF8500),
                      ),
                      // 3rd Dot
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(
                          left: 0,
                          top: 4,
                          right: 0,
                          bottom: 4,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF004283),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                // Right Column
                SizedBox(
                  width: screenSize.width * 0.84,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: screenSize.width * 0.9,
                        height: 28,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tap on upload button.',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: const Color(0xFF6C6C6C),
                              fontSize: 7 * screenRatio,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: screenSize.width * 0.9,
                        height: 46,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Choose your personal plan document from your device.',
                            style: TextStyle(
                              color: const Color(0xFF6C6C6C),
                              fontSize: 7 * screenRatio,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: screenSize.width * 0.9,
                        height: 28,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tap on "Subnit"',
                            style: TextStyle(
                              color: const Color(0xFF6C6C6C),
                              fontSize: 7 * screenRatio,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: screenSize.height * 0.01),
            SizedBox(
              width: screenSize.width,
              height: screenSize.height * 0.024,
              child: Text(
                'Set personal asthma action plan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 7 * screenRatio,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 92, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: _pickAsthmaActionPlan,
                    child: Container(
                      width: screenSize.width * 0.32,
                      height: screenSize.height * 0.12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A2FF).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF00A2FF).withOpacity(0.4),
                          style: BorderStyle.solid,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/svgs/upload.svg',
                          width: 64,
                          height: 64,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  ElevatedButton(
                    onPressed: () {
                      _result != null ? _submitAsthmaActionPlan() : null;
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(
                          screenSize.width * 0.24, screenSize.height * 0.06),
                      foregroundColor: _result != null
                          ? AppColors.primaryWhite
                          : const Color(0xFFA6A6A6),
                      backgroundColor: _result != null
                          ? AppColors.primaryBlue
                          : const Color(0xFFEDEDED),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 8 * screenRatio,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
