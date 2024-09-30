import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PeakflowPercentage extends StatelessWidget {
  final int integerPeakflowPercentage;
  const PeakflowPercentage(
      {super.key, required this.integerPeakflowPercentage});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    String stringPeakflowPercentage = integerPeakflowPercentage.toString();
    return Container(
      width: screenSize.width * 0.5,
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: integerPeakflowPercentage >= 80
              ? const Color(0xFF27AE60)
              : integerPeakflowPercentage < 80 &&
                      integerPeakflowPercentage >= 60
                  ? const Color(0xFFFF8500)
                  : const Color(0xFFFD4646),
          width: 2.0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: screenSize.width * 0.5,
            child: Text(
              'Your Peakflow Result',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: integerPeakflowPercentage >= 80
                    ? const Color(0xFF27AE60)
                    : integerPeakflowPercentage < 80 &&
                            integerPeakflowPercentage >= 60
                        ? const Color(0xFFFF8500)
                        : const Color(0xFFFD4646),
                fontSize: 5 * screenRatio,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$stringPeakflowPercentage%',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: integerPeakflowPercentage >= 80
                      ? const Color(0xFF27AE60)
                      : integerPeakflowPercentage < 80 &&
                              integerPeakflowPercentage >= 60
                          ? const Color(0xFFFF8500)
                          : const Color(0xFFFD4646),
                  fontSize: 14 * screenRatio,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4.0),
              SvgPicture.asset(
                integerPeakflowPercentage >= 80
                    ? 'assets/svgs/user_assets/smile.svg'
                    : integerPeakflowPercentage < 80 &&
                            integerPeakflowPercentage >= 60
                        ? 'assets/svgs/user_assets/normal.svg'
                        : integerPeakflowPercentage < 60 &&
                                integerPeakflowPercentage >= 50
                            ? 'assets/svgs/user_assets/sad.svg'
                            : 'assets/svgs/user_assets/very-sad.svg',
                width: 36,
                height: 36,
                color: const Color(0xFF004283),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
