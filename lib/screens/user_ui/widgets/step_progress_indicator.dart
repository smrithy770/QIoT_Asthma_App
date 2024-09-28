import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StepProgressIndicator extends StatefulWidget {
  final int totalSteps, currentStep;

  StepProgressIndicator({required this.totalSteps, required this.currentStep});

  @override
  _StepProgressIndicatorState createState() => _StepProgressIndicatorState();
}

class _StepProgressIndicatorState extends State<StepProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(widget.totalSteps * 2 - 1, (index) {
            if (index.isEven) {
              int stepIndex = index ~/ 2;
              return CircleAvatar(
                radius: 20,
                backgroundColor: stepIndex <= widget.currentStep
                    ? const Color(0xFF004283)
                    : const Color(0xFF004283).withOpacity(0.1),
                child: stepIndex == widget.currentStep
                    ? SvgPicture.asset(
                        'assets/svgs/user_assets/check.svg',
                        width: 16,
                      )
                    : Text(
                        (stepIndex + 1).toString(),
                        style: const TextStyle(
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
              );
            } else {
              return Container(
                width: 28,
                height: 2,
                color: index ~/ 2 < widget.currentStep
                    ? const Color(0xFF004283)
                    : const Color(0xFFD7D7D7),
              );
            }
          }),
        ),
      ],
    );
  }
}
