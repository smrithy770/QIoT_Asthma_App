import 'package:flutter/material.dart';

class LevelWidget extends StatelessWidget {
  final String widgetName;
  final String level;
  final String? groupValue;
  final ValueChanged<String?> onChanged;
  final Size screenSize;

  const LevelWidget({
    Key? key,
    required this.widgetName,
    required this.level,
    required this.groupValue,
    required this.onChanged,
    required this.screenSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    return GestureDetector(
      onTap: () {
        onChanged(level);
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        width: screenSize.width * 0.28,
        // height: screenSize.height * 0.1,
        constraints: const BoxConstraints(
          // minHeight: screenSize.height * 0.20,
          maxHeight: double.infinity,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Radio<String>(
              value: level,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            Text(
              level,
              style: TextStyle(
                color: widgetName == 'Fitness'
                    ? level == 'Low'
                        ? const Color(0xFFFD4646)
                        : level == 'Medium'
                            ? const Color(0xFFF2C94C)
                            : const Color(0xFF27AE60)
                    : level == 'High'
                        ? const Color(0xFFFD4646)
                        : level == 'Medium'
                            ? const Color(0xFFF2C94C)
                            : const Color(0xFF27AE60),
                fontSize: 6 * screenRatio,
                fontWeight: FontWeight.normal,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
