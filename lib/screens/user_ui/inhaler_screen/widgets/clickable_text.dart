import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ClickableText extends StatelessWidget {
  final String textBeforeClickable;
  final String clickableText;
  final bool underline;
  final Color color;
  final String textAfterClickable;
  final FontWeight? fontWeight;
  final double fontSize;
  final VoidCallback onTap;

  const ClickableText({
    super.key,
    required this.textBeforeClickable,
    required this.clickableText,
    this.underline = false,
    required this.color,
    required this.textAfterClickable,
    required this.fontSize,
    required this.onTap,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: textBeforeClickable,
            style: TextStyle(
              color: Colors.black,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
          TextSpan(
            text: clickableText,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: fontWeight,
              decoration: underline == false
                  ? TextDecoration.none
                  : TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = onTap,
          ),
          TextSpan(
            text: textAfterClickable,
            style: TextStyle(
              color: Colors.black,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    );
  }
}
