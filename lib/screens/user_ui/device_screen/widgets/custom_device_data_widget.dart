import 'package:asthmaapp/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CustomDeviceData extends StatelessWidget {
  final String label;
  final String value;
  final double screenRatio;

  const CustomDeviceData({
    super.key,
    required this.label,
    required this.value,
    required this.screenRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.height * screenRatio,
      height: screenRatio * 32,
      padding: EdgeInsets.all(screenRatio * 4),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.primaryBlueText,
              fontSize: screenRatio * 8,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primaryGreyText,
              fontSize: screenRatio * 7,
              fontWeight: FontWeight.normal,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}
