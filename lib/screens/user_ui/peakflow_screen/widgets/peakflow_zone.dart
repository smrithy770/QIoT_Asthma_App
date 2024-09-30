import 'package:flutter/material.dart';

class PeakflowZone extends StatelessWidget {
  final int integerPeakflowPercentage;
  const PeakflowZone({super.key, required this.integerPeakflowPercentage});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    return Container(
      width: screenSize.width * 0.5,
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blue[800]!, width: 2.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: screenSize.width * 0.5,
            child: Text(
              integerPeakflowPercentage >= 80
                  ? 'Green Zone'
                  : integerPeakflowPercentage < 80 &&
                          integerPeakflowPercentage >= 60
                      ? 'Amber Zone'
                      : integerPeakflowPercentage < 60 &&
                              integerPeakflowPercentage >= 50
                          ? 'Red Zone(Urgent)'
                          : 'Red Zone(Emerg.)',
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
          SizedBox(
            width: screenSize.width * 0.5,
            child: RichText(
              text: TextSpan(
                children: [
                   TextSpan(
                    text: 'Peakflow result is between ',
                    style: TextStyle(
                      color: Color(0xFF6C6C6C),
                      fontSize: 5 * screenRatio,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  TextSpan(
                    text: integerPeakflowPercentage >= 80
                        ? '80-100%'
                        : integerPeakflowPercentage < 80 &&
                                integerPeakflowPercentage >= 60
                            ? '60-79%'
                            : integerPeakflowPercentage < 60 &&
                                    integerPeakflowPercentage >= 50
                                ? '50-59%'
                                : '<50%',
                    style: TextStyle(
                      color: integerPeakflowPercentage >= 80
                          ? const Color(0xFF27AE60)
                          : integerPeakflowPercentage < 80 &&
                                  integerPeakflowPercentage >= 60
                              ? const Color(0xFFFF8500)
                              : const Color(0xFFFD4646),
                      fontSize: 6 * screenRatio,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: integerPeakflowPercentage >= 80
                        ? '. You are in the Green zone.'
                        : integerPeakflowPercentage < 80 &&
                                integerPeakflowPercentage >= 60
                            ? '. You are in the Amber zone.'
                            : integerPeakflowPercentage < 60 &&
                                    integerPeakflowPercentage >= 50
                                ? '. You are in the Red zone.'
                                : '. You are in the Red zone(Emergency).',
                    style:  TextStyle(
                      color: Color(0xFF6C6C6C),
                      fontSize: 5 * screenRatio,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
