import 'package:asthmaapp/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CustomDrawerListItem extends StatelessWidget {
  final Color backgroundColor;
  final String assetPath;
  final String name;
  final VoidCallback onTap;

  const CustomDrawerListItem({
    super.key,
    required this.backgroundColor,
    required this.assetPath,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenSize.width,
        height: 64,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: screenSize.width * 0.06),
              Text(
                name,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: AppColors.primaryWhiteText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Comic Neue',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
