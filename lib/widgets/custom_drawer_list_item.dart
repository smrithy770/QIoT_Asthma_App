import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomDrawerListItem extends StatelessWidget {
  final String assetPath;
  final String name;
  final VoidCallback onTap;

  const CustomDrawerListItem({
    super.key,
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
        color: Colors.transparent,
        width: screenSize.width,
        height: screenSize.height * 0.048,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: screenSize.width * 0.06),
              SizedBox(
                width: screenSize.width * 0.08,
                child: SvgPicture.asset(assetPath),
              ),
              SizedBox(width: screenSize.width * 0.04),
              Text(
                name,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: Color(0xFF004283),
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
