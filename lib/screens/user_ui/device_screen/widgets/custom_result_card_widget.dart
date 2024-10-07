import 'package:asthmaapp/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomResultCard extends StatelessWidget {
  final Size screenSize;
  final ScanResult result;
  final VoidCallback onTap;

  const CustomResultCard({
    Key? key,
    required this.screenSize,
    required this.result,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenRatio = screenSize.height / screenSize.width;
    return Card(
      elevation: 2,
      color: AppColors.primaryWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(screenRatio * 6),
        leading: SvgPicture.asset(
          'assets/svgs/user_assets/bluetooth.svg',
          width: screenRatio * 16,
        ),
        title: Text(
          result.device.platformName.isNotEmpty
              ? result.device.platformName
              : "Unknown Device",
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: screenRatio * 7,
          ),
        ),
        subtitle: Text(
          'RSSI: ${result.rssi} dBm',
          style: TextStyle(
            color: AppColors.primaryGreyText,
            fontWeight: FontWeight.bold,
            fontSize: screenRatio * 5,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            fixedSize: Size(screenSize.width * 0.3, screenSize.height * 0.05),
            foregroundColor: AppColors.primaryWhite,
            backgroundColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Text(
            'Connect',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryWhite,
              fontSize: screenRatio * 6,
              fontWeight: FontWeight.normal,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
    );
  }
}
