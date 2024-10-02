import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/screens/user_ui/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:asthmaapp/widgets/clickable_text.dart';

class AboutScreen extends StatelessWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const AboutScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  Future<void> _launchBrowser(String web) async {
    final Uri toLaunch = Uri(scheme: 'https', host: web, path: 'headers/');
    if (!await launchUrl(toLaunch, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $toLaunch');
    } else {
      throw 'Could not launch $web';
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.primaryWhite,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: SvgPicture.asset(
                'assets/svgs/user_assets/user_drawer_icon.svg', // Replace with your custom icon asset path
                width: screenRatio * 10,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'About',
            style: TextStyle(
              fontSize: screenRatio * 10,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
      drawer: CustomDrawer(
        realm: realm,
        deviceToken: deviceToken,
        deviceType: deviceType,
        onClose: () {
          Navigator.of(context).pop();
        },
        itemName: (String name) {
          logger.d(name);
        },
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Container(
            color: AppColors.primaryWhite,
            width: screenSize.width,
            height: screenSize.height,
            padding: EdgeInsets.all(screenSize.height * 0.016),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClickableText(
                  textBeforeClickable:
                      'QIoT are a UK based company who simplify technology by securely connecting medical devices to our AI platform through an App.  The AI securely analyses the real time usage of such devices and creates actionable reports that are used by healthcare professionals to provide real time support to patients.\n\nWhilst we deliver real time information, please note this App uses data for statistical analysis purposes only and is not to be used as an emergency response service or treated as a medical device.\n\nIf you have any questions regards functionality or experience any problems accessing or using the App, or indeed require any further support, please email us at info@qiot.co.uk noting APP ISSUES in the subject line.\n\nQIoT Ltd are registered in the UK. Registration Number SC606878.\n\n',
                  firstclickableText: 'www.qiot.co.uk',
                  color: const Color(0xFF0D8EF8),
                  textAfterFirstClickable: '',
                  secondclickableText: '',
                  fontSize: 16,
                  onTap: () {
                    _launchBrowser('www.qiot.co.uk');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
