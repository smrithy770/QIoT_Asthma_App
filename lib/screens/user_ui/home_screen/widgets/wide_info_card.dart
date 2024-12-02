import 'package:asthmaapp/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class WideInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final Color backgroundColor;
  final double width;
  final double height;
  final double screenRatio;
  final bool isLoading;

  const WideInfoCard({
    Key? key,
    required this.title,
    required this.value,
    required this.backgroundColor,
    required this.width,
    required this.height,
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
    width: width,
    height: height,
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
            width: width * 0.7, 
            height: 7 * screenRatio, 
            color: Colors.grey[300], 
          ),
        ),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: width * 0.8,
            height: 14 * screenRatio, 
            color: Colors.grey[300], 
          ),
        ),
      ],
    ),
  );
}


  Widget _buildCard() {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: screenRatio * 8,
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
              fontSize: 7 * screenRatio,
              fontWeight: FontWeight.normal,
              fontFamily: 'Roboto',
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryWhite,
              fontSize: 14 * screenRatio,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}
