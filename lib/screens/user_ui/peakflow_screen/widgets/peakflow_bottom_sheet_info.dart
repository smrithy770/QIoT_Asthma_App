import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/screens/user_ui/peakflow_screen/widgets/clickable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../models/user_model/user_model.dart';

class PeakflowBottomSheetInfo extends StatefulWidget {
  final Realm realm;
  const PeakflowBottomSheetInfo({super.key,
    required this.realm,
  });

  @override
  State<PeakflowBottomSheetInfo> createState() =>
      _PeakflowBottomSheetInfoState();
}

class _PeakflowBottomSheetInfoState extends State<PeakflowBottomSheetInfo> {
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Make phone call method
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

  void checkPractionerContact(String userId) async {


    // Query the Realm database to get the user data using userId
    final existingUser = await widget.realm.query<UserModel>('userId == \$0', [userId]).firstOrNull;

    if (existingUser != null) {

      // Check if practionerContact is saved and not empty
      String? practionerContact = existingUser.practionerContact;
      if (practionerContact != null && practionerContact.isNotEmpty) {
        print('Practioner Contact is : $practionerContact');
        // Launch phone call with practioner contact
        await makePhoneCall(practionerContact);
      } else {
        print('Practioner Contact is not saved.');
      }
    } else {
      print('User not found in Realm.');
    }
  }

  Future<void> _loadUserData() async {
    final user = getUserData(widget.realm);
    if (user != null) {
      setState(() {
        userModel = user;
      });
    }
  }

  UserModel? getUserData(Realm realm) {
    final results = realm.all<UserModel>();
    if (results.isNotEmpty) {
      return results[0];
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;

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
              makePhoneCall('999');  // Example emergency number, replace with actual number if needed
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
            onTap: () {
              String userId = userModel!.userId; // Replace with actual userId you want to pass

              // Null check for userId before calling the method
              if (userId.isNotEmpty) {
                checkPractionerContact(userId); // Call the method to check practioner contact and make a call
              } else {
                print('User ID is empty or null');
              }
            },
          ),
        ],
      ),
    );
  }
}
