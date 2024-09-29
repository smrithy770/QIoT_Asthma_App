import 'package:asthmaapp/constants/app_colors.dart';
import 'package:flutter/material.dart';

class NarrowInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final Color backgroundColor;
  final double width;
  final double height;
  final double screenRatio;

  const NarrowInfoCard({
    Key? key,
    required this.title,
    required this.value,
    required this.backgroundColor,
    required this.width,
    required this.height,
    required this.screenRatio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: screenRatio * 8,
        vertical: screenRatio * 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryWhite,
              fontSize:
                  8 * screenRatio, // Updated based on your new screen ratio
              fontWeight: FontWeight.normal,
              fontFamily: 'Roboto',
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryWhite,
              fontSize:
                  16 * screenRatio, // Updated based on your new screen ratio
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}
