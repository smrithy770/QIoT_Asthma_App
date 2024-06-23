import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return AlertDialog(
      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      title: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF003A74),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/svgs/alert.svg',
            width: 64, // Adjust width as needed
            height: 64, // Adjust height as needed
          ),
          SizedBox(
            height: screenSize.height * 0.02,
          ),
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFF003A74),
              fontSize: 16,
              fontWeight: FontWeight.normal,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            fixedSize: Size(screenSize.width * 1.0, screenSize.height * 0.06),
            foregroundColor: const Color(0xFFFFFFFF),
            backgroundColor: const Color(0xFF004283),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          ),
          child: const Text('Retry'),
        ),
      ],
    );
  }
}
