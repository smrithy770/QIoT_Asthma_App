import 'package:asthmaapp/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CustomDeviceButton extends StatelessWidget {
  final Size screenSize;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomDeviceButton({
    Key? key,
    required this.screenSize,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenRatio = screenSize.height / screenSize.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenSize.width * 0.44, // Adjust width as needed
        height: screenSize.height * 0.06,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.primaryWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primaryBlue,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color:
                  isSelected ? AppColors.primaryWhite : AppColors.primaryBlue,
              fontSize: screenRatio * 6, // Adjust font size as needed
              fontWeight: FontWeight.normal,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
    );
  }
}
