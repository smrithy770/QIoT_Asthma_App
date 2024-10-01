import 'package:asthmaapp/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomAlertDialog extends StatelessWidget {
  final String type;
  final String title;
  final String content;
  final VoidCallback optionOne;
  final VoidCallback? optionTwo;

  const CustomAlertDialog({
    super.key,
    required this.type,
    required this.title,
    required this.content,
    required this.optionOne,
    this.optionTwo,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return AlertDialog(
      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      title: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF003A74),
            fontSize: 24,
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
            type == 'alert'
                ? 'assets/svgs/user_assets/alert.svg'
                : 'assets/svgs/user_assets/child.svg',
            width: 64, // Adjust width as needed
            height: 64, // Adjust height as needed
          ),
          SizedBox(
            height: screenSize.height * 0.02,
          ),
          Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF003A74),
              fontSize: 20,
              fontWeight: FontWeight.normal,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
      actions: <Widget>[
        type == 'alert'
            ? ElevatedButton(
                onPressed: () {
                  optionOne();
                },
                style: ElevatedButton.styleFrom(
                  fixedSize:
                      Size(screenSize.width * 1.0, screenSize.height * 0.06),
                  foregroundColor: AppColors.primaryWhite,
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                ),
                child: const Text('Retry'),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenSize.width * 0.32,
                    child: ElevatedButton(
                      onPressed: () {
                        optionOne();
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(
                            screenSize.width * 1.0, screenSize.height * 0.06),
                        foregroundColor: AppColors.primaryWhite,
                        backgroundColor: AppColors.okGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 8),
                      ),
                      child: const Text('Yes'),
                    ),
                  ),
                  SizedBox(
                    width: screenSize.width * 0.32,
                    child: ElevatedButton(
                      onPressed: () {
                        optionTwo!();
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(
                            screenSize.width * 1.0, screenSize.height * 0.06),
                        foregroundColor: AppColors.primaryWhite,
                        backgroundColor: AppColors.errorRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 8),
                      ),
                      child: const Text('No'),
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}
