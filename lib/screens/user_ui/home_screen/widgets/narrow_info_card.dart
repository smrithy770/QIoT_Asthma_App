import 'package:asthmaapp/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class NarrowInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final Color backgroundColor;
  final Size screenSize;
  final double screenRatio;
  final bool isLoading;

  const NarrowInfoCard({
    Key? key,
    required this.title,
    required this.value,
    required this.backgroundColor,
    required this.screenSize,
    required this.screenRatio,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: _buildShimmerCard(),
          )
        : _buildCard();
  }

 Widget _buildShimmerCard() {
  return Container(
    width: screenSize.width * 0.9,
    height: screenSize.height * 0.14,
    padding: EdgeInsets.symmetric(
      horizontal: screenRatio * 4,
      vertical: screenRatio * 4,
    ),
    decoration: BoxDecoration(
      color: Colors.grey[300], 
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: screenSize.width * 0.5, 
            height: 8 * screenRatio,
            color: Colors.grey[300], 
          ),
        ),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: screenSize.width * 0.6, 
            height: 16 * screenRatio, 
            color: Colors.grey[300], 
          ),
        ),
      ],
    ),
  );
}

  Widget _buildCard() {
    return Container(
      width: screenSize.width * 0.9,
      height: screenSize.height * 0.14,
      padding: EdgeInsets.symmetric(
        horizontal: screenRatio * 4,
        vertical: screenRatio * 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryWhite,
              fontSize: 8 * screenRatio,
              fontWeight: FontWeight.normal,
              fontFamily: 'Roboto',
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryWhite,
              fontSize: 16 * screenRatio,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}