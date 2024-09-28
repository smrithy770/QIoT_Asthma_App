import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/screens/user_ui/widgets/custom_drawer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';

class SteroidDoseScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const SteroidDoseScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<SteroidDoseScreen> createState() => _SteroidDoseScreenState();
}

class _SteroidDoseScreenState extends State<SteroidDoseScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<FormState> _steroiddoseformKey = GlobalKey<FormState>();
  final TextEditingController _steroiddosevalueController =
      TextEditingController();
  FilePickerResult? result;
  String? _result;

  Future<void> _submitSteroidDose(int steroidDose) async {}
  Future<void> _submitSteroidCard() async {}
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: const Color(0xFF004283),
        foregroundColor: const Color(0xFFFFFFFF),
        title: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            'Steroid Dose',
            style: TextStyle(
              fontSize: screenRatio * 10,
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
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
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
                  SizedBox(
                    width: screenSize.width,
                    height: screenRatio * 12,
                    child: Text(
                      'Steroid Dose Entry',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF004283),
                        fontSize: screenRatio * 8,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  SizedBox(
                    width: screenSize.width,
                    height: screenSize.height * 0.16,
                    child: SvgPicture.asset(
                      'assets/svgs/user_assets/steroid.svg',
                      width: 64,
                      height: 64,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  SizedBox(
                    width: screenSize.width,
                    height: screenRatio * 12,
                    child: Text(
                      'Please enter your steroid dosage and hit submit.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF004283),
                        fontSize: screenRatio * 7,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 92, vertical: 8),
                    child: Form(
                      key: _steroiddoseformKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          TextFormField(
                            controller: _steroiddosevalueController,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenRatio * 8,
                                vertical: screenRatio * 4,
                              ),
                              border: OutlineInputBorder(),
                              hintText: 'Steroid Dose Value',
                              hintStyle: TextStyle(
                                color: Color(0xFF6C6C6C),
                                fontSize: screenRatio * 7,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {});
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Steroid Dose Value is required';
                              }

                              // Check if the input is a number
                              final num? peakflow = num.tryParse(value);
                              if (peakflow == null) {
                                return 'Please enter a valid number';
                              }

                              // Ensure the value is greater than 0
                              if (peakflow <= 0) {
                                return 'Steroid Dose value must be greater than 0';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: screenSize.height * 0.01),
                          ElevatedButton(
                            onPressed: () {
                              // _checkSteroidDose();
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(screenSize.width * 0.24,
                                  screenSize.height * 0.08),
                              foregroundColor: const Color(0xFFFFFFFF),
                              backgroundColor: const Color(0xFF004283),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                            ),
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                color: const Color(0xFFFFFFFF),
                                fontSize: 8 * screenRatio,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  SizedBox(
                    width: screenSize.width,
                    height: screenRatio * 12,
                    child: Text(
                      'Upload your steroid card',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF004283),
                        fontSize: 7 * screenRatio,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 92, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            // _pickSteroidCard;
                          },
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
                                'assets/svgs/user_assets/upload.svg',
                                width: 64,
                                height: 64,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenSize.height * 0.02),
                        ElevatedButton(
                          onPressed: () {
                            _result != null ? _submitSteroidCard() : null;
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(screenSize.width * 0.24,
                                screenSize.height * 0.08),
                            foregroundColor: _result != null
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFFA6A6A6),
                            backgroundColor: _result != null
                                ? const Color(0xFF004283)
                                : const Color(0xFFEDEDED),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                          ),
                          child: Text(
                            'Upload',
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
          ),
        ),
      ),
    );
  }
}
