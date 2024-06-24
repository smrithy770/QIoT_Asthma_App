import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ClickableText extends StatelessWidget {
  final String textBeforeClickable;
  final String firstclickableText;
  final bool underline;
  final Color color;
  final String textAfterFirstClickable;
  final String secondclickableText;
  final FontWeight? fontWeight;
  final double fontSize;
  final VoidCallback onTap;

  const ClickableText({
    super.key,
    required this.textBeforeClickable,
    required this.firstclickableText,
    this.underline = false,
    required this.color,
    required this.textAfterFirstClickable,
    required this.secondclickableText,
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
            text: firstclickableText,
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
            text: textAfterFirstClickable,
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
