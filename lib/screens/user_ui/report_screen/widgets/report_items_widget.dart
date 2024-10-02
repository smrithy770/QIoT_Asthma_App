import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ReportItem extends StatelessWidget {
  final String assetPath;
  final String reportTitle;
  final Color backgroundColor;
  final Color textColor;
  final double screenRatio;
  final Function onTap;

  const ReportItem({
    super.key,
    required this.assetPath,
    required this.reportTitle,
    required this.backgroundColor,
    required this.textColor,
    required this.screenRatio,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        width: screenRatio * 50,
        height: screenRatio * 50,
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              assetPath,
              width: 32 * screenRatio,
              height: 32 * screenRatio,
            ),
            Text(
              reportTitle,
              style: TextStyle(
                fontSize: 8 * screenRatio,
                fontWeight: FontWeight.normal,
                fontFamily: 'Roboto',
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
