import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/screens/user_ui/peakflow_screen/widgets/clickable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class PeakflowBottomSheetInfo extends StatefulWidget {
  const PeakflowBottomSheetInfo({super.key});

  @override
  State<PeakflowBottomSheetInfo> createState() =>
      _PeakflowBottomSheetInfoState();
}

class _PeakflowBottomSheetInfoState extends State<PeakflowBottomSheetInfo> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    Future<void> makePhoneCall(String phoneNumber) async {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        throw 'Could not launch $phoneNumber';
      }
    }

    return Container(
      width: screenSize.width,
      height: screenSize.height * 0.32,
      padding: EdgeInsets.all(screenSize.width * 0.02),
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
                  width: 32,
                  height: 32,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const Text(
            'If you can\'t speak in a sentence, dial 999 or call your GP urgently.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              color: Color(0xFFFD4646),
            ),
          ),
          SizedBox(height: screenSize.height * 0.016),
          Padding(
            padding: EdgeInsets.only(
              left: screenSize.width * 0.01,
              right: screenSize.width * 0.01,
            ),
            child: const Text(
              'Take 10 puffs of your reliever inhaler every 5 minutes untill you improve or help arrives.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.errorRed,
                fontSize: 16,
                fontWeight: FontWeight.normal,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.016),
          ElevatedButton(
            onPressed: () {
              makePhoneCall('07463435160');
            },
            style: ElevatedButton.styleFrom(
              fixedSize: Size(
                screenSize.width * 0.8,
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
              'Call 999',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.016),
          ClickableText(
              textBeforeClickable: '',
              clickableText: 'Call In Case of Emergency (ICE) contact',
              underline: true,
              color: const Color(0xFF004283),
              textAfterClickable: '',
              fontSize: 16,
              onTap: () {})
        ],
      ),
    );
  }
}
