import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/screens/user_ui/peakflow_screen/widgets/notification_bottom_sheet_info.dart';
import 'package:asthmaapp/screens/user_ui/peakflow_screen/widgets/peakflow_bottom_sheet_info.dart';
import 'package:asthmaapp/screens/user_ui/peakflow_screen/widgets/peakflow_measure.dart';
import 'package:asthmaapp/widgets/custom_drawer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _peakflowvalueController =
      TextEditingController();

  void _openpeakflowbottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => const PeakflowBottomSheetInfo(),
    );
  }

  void _opennotificationbottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => const NotificationBottomSheet(),
    );
  }

  Future<void> openLink(String url) async {
    final Uri launchUri = Uri(
      scheme: 'https',
      host: url,
      path: '/',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _submitPeakflow() {
    if (_formKey.currentState!.validate()) {
      int pFlow = int.parse(_peakflowvalueController.text.trim());
      print(pFlow);
    }
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
                  SizedBox(height: screenSize.height * 0.016),
                  SizedBox(
                    width: screenSize.width,
                    child: const Text(
                      'To measure your Peakflow',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.primaryBlueText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.016),
                  SizedBox(
                    width: screenSize.width,
                    child: PeakflowMeasure(
                      screenSize: screenSize,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.016),
                  SizedBox(
                    width: screenSize.width * 0.9,
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text:
                                'To refresh how to perform Peakflow accurately visit ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: 'asthmaandlung.org.uk',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                openLink('asthmaandlung.org.uk');
                                print('Open asthmaandlung.org.uk');
                              },
                          ),
                          const TextSpan(
                            text: ' or ',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: 'nhs.uk ',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                openLink('nhs.uk');
                                print('nhs.uk');
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  SizedBox(
                    width: screenSize.width,
                    child: const Text(
                      'Enter Peakflow Value',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryBlueText,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 92, vertical: 8),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          TextFormField(
                            controller: _peakflowvalueController,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Peakflow Value',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {});
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Peakflow Value is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: screenSize.height * 0.01),
                          ElevatedButton(
                            onPressed: () {
                              _submitPeakflow();
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(screenSize.width * 0.24,
                                  screenSize.height * 0.06),
                              foregroundColor: const Color(0xFFFFFFFF),
                              backgroundColor: const Color(0xFF004283),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 18,
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
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Set your notification timings',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            decoration: TextDecoration.none,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _opennotificationbottomSheet(context);
                            },
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
