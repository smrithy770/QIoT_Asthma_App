import 'package:flutter/material.dart';
import 'package:asthmaapp/constants/app_colors.dart';

class CustomElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isViewSteroidCardButton;
  final double screenRatio;
  final double screenWidth;
  final double screenHeight;

  const CustomElevatedButton({
    Key? key,
    required this.label,
    required this.onPressed,
    required this.isViewSteroidCardButton,
    required this.screenRatio,
    required this.screenWidth,
    required this.screenHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: Size(
          screenWidth * 1.0,
          screenHeight * 0.08,
        ),
        foregroundColor: AppColors.primaryWhite,
        backgroundColor: AppColors.primaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 8 * screenRatio,
          vertical: 8 * screenRatio,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 7 * screenRatio,
          fontWeight: FontWeight.normal,
          fontFamily: 'Roboto',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
