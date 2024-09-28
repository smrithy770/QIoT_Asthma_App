import 'package:flutter/material.dart';

class QuestionnaireWidget extends StatelessWidget {
  final String question;
  final List<String> options;
  final int selectedAnswerIndex;
  final Function(int, int) onTap;

  const QuestionnaireWidget({
    Key? key,
    required this.question,
    required this.options,
    required this.selectedAnswerIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    return SizedBox(
      width: screenSize.width,
      height: screenSize.height * 0.56,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            question,
            style: TextStyle(
              color: Color(0xFF004283),
              fontSize: 7 * screenRatio,
              fontWeight: FontWeight.normal,
              fontFamily: 'Roboto',
            ),
          ),
          SizedBox(height: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(options.length, (index) {
              return GestureDetector(
                onTap: () {
                  onTap(
                      index,
                      index +
                          1); // Pass index as selected answer index, and index + 1 as score
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.04,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Icon(
                          selectedAnswerIndex == index
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: Colors.blue,
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: Text(
                          options[index],
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Color(0xFF004283),
                            fontSize: 7 * screenRatio,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
