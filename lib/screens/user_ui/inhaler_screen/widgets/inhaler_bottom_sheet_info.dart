import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/screens/user_ui/inhaler_screen/widgets/clickable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class InhalerBottomSheetInfo extends StatefulWidget {
  const InhalerBottomSheetInfo({super.key});

  @override
  State<InhalerBottomSheetInfo> createState() => _InhalerBottomSheetInfoState();
}

class _InhalerBottomSheetInfoState extends State<InhalerBottomSheetInfo> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;

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
      height: screenRatio * 160,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: SvgPicture.asset(
                  'assets/svgs/user_assets/cross.svg',
                  width: screenRatio * 10,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          Text(
            'If you can\'t speak in a sentence, dial 999 or call your GP urgently.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenRatio * 9,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              color: Color(0xFFFD4646),
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.01),
            child: Text(
              'Take 10 puffs of your reliever inhaler every 5 minutes untill you improve or help arrives.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.errorRed,
                fontSize: screenRatio * 8,
                fontWeight: FontWeight.normal,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          ElevatedButton(
            onPressed: () {
              makePhoneCall('07463435160');
            },
            style: ElevatedButton.styleFrom(
              fixedSize: Size(
                screenSize.width * 0.8,
                screenSize.height * 0.08,
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
            child: Text(
              'Call 999',
              style: TextStyle(
                fontSize: screenRatio * 8,
                fontWeight: FontWeight.normal,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          const SizedBox(height: 16),
          ClickableText(
              textBeforeClickable: '',
              clickableText: 'Call In Case of Emergency (ICE) contact',
              underline: true,
              color: AppColors.primaryBlue,
              textAfterClickable: '',
              fontSize: screenRatio * 7,
              onTap: () {})
        ],
      ),
    );
  }
}
