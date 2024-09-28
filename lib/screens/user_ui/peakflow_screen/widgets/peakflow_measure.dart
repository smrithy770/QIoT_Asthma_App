import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';

class PeakflowMeasure extends StatelessWidget {
  final Size screenSize;
  final double screenRatio;
  const PeakflowMeasure({
    super.key,
    required this.screenSize,
    required this.screenRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        SizedBox(
          width: screenSize.width * 0.04,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // 1st Dot
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(
                  left: 0,
                  top: 12,
                  right: 0,
                  bottom: 4,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF004283),
                  shape: BoxShape.circle,
                ),
              ),
              // 1st Dash
              const Dash(
                direction: Axis.vertical,
                length: 18,
                dashLength: 4,
                dashColor: Color(0xFFFF8500),
              ),
              // 2nd Dot
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(
                  left: 0,
                  top: 4,
                  right: 0,
                  bottom: 4,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF004283),
                  shape: BoxShape.circle,
                ),
              ),
              // 2nd Dash
              const Dash(
                direction: Axis.vertical,
                length: 32,
                dashLength: 4,
                dashColor: Color(0xFFFF8500),
              ),
              // 3rd Dot
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(
                  left: 0,
                  top: 4,
                  right: 0,
                  bottom: 4,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF004283),
                  shape: BoxShape.circle,
                ),
              ),
              // 3rd Dash
              const Dash(
                direction: Axis.vertical,
                length: 16,
                dashLength: 4,
                dashColor: Color(0xFFFF8500),
              ),
              // 4th Dot
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(
                  left: 0,
                  top: 4,
                  right: 0,
                  bottom: 4,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF004283),
                  shape: BoxShape.circle,
                ),
              ),
              // 4th Dash
              const Dash(
                direction: Axis.vertical,
                length: 36,
                dashLength: 4,
                dashColor: Color(0xFFFF8500),
              ),
              // 5th Dot
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(
                  left: 0,
                  top: 4,
                  right: 0,
                  bottom: 4,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF004283),
                  shape: BoxShape.circle,
                ),
              ), // Dash
              // 5th Dash
              const Dash(
                direction: Axis.vertical,
                length: 16,
                dashLength: 4,
                dashColor: Color(0xFFFF8500),
              ),
              // 6th Dot
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(
                  left: 0,
                  top: 4,
                  right: 0,
                  bottom: 4,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF004283),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        // Right Column
        SizedBox(
          width: screenSize.width * 0.89,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 4),
              SizedBox(
                width: screenSize.width * 0.9,
                height: 24,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Slide the marker to zero',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Color(0xFF6C6C6C),
                      fontSize: screenRatio * 8,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: screenSize.width * 0.9,
                height: 42,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Stand or sit upright and hold the meter level',
                    style: TextStyle(
                      color: Color(0xFF6C6C6C),
                      fontSize: screenRatio * 8,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: screenSize.width * 0.9,
                height: 24,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Take a deep breath',
                    style: TextStyle(
                      color: Color(0xFF6C6C6C),
                      fontSize: screenRatio * 8,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: screenSize.width * 0.9,
                height: 44,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Make sure your mouth makes a tight seal around the mouthpiece',
                    style: TextStyle(
                      color: Color(0xFF6C6C6C),
                      fontSize: screenRatio * 8,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: screenSize.width * 0.9,
                height: 24,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Blow as hard and fast as you can into the meter',
                    style: TextStyle(
                      color: Color(0xFF6C6C6C),
                      fontSize: screenRatio * 8,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: screenSize.width * 0.9,
                height: 44,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Repeat steps 1-5 three times and record your best score below',
                    style: TextStyle(
                      color: Color(0xFF6C6C6C),
                      fontSize: screenRatio * 8,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
