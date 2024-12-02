import 'package:asthmaapp/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MedicationReminderCard extends StatelessWidget {
  final String svgAsset;
  final String title;
  final Widget subtitle;
  final double screenRatio;
  final VoidCallback? onTap;

  const MedicationReminderCard({
    Key? key,
    required this.svgAsset,
    required this.title,
    required this.subtitle,
    required this.screenRatio,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Optional tap handler for navigation or interaction
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: screenRatio * 45,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    svgAsset,
                    width: screenRatio * 24,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: screenRatio * 8,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    // child: Text(
                    //   subtitle,
                    //   textAlign: TextAlign.left,
                    //   style: TextStyle(
                    //     color: AppColors.primaryLightBlueText,
                    //     fontSize: screenRatio * 9,
                    //     fontWeight: FontWeight.bold,
                    //     fontFamily: 'Roboto',
                    //   ),
                    // ),
                    child: subtitle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}