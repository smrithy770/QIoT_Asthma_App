import 'package:flutter/material.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: Center(
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/svgs/logo.svg',
                width: screenSize.width * 0.5,
              ),
              const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                strokeCap: StrokeCap.round,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
