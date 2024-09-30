import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/screens/user_ui/widgets/custom_drawer.dart';
import 'package:asthmaapp/screens/user_ui/widgets/questionnaire_widget.dart';
import 'package:asthmaapp/screens/user_ui/widgets/step_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import '../../../act_questions.dart';

class AsthmaControlTestScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const AsthmaControlTestScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<AsthmaControlTestScreen> createState() =>
      _AsthmaControlTestScreenState();
}

class _AsthmaControlTestScreenState extends State<AsthmaControlTestScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final PageController _pageController = PageController(initialPage: 0);

  int currentStep = 0;
  int totalSteps = act_questions.length;

  int totalScore = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_pageListener);
  }

  @override
  void dispose() {
    _pageController.removeListener(_pageListener);
    _pageController.dispose();
    super.dispose();
  }

  void _pageListener() {
    setState(() {
      currentStep = _pageController.page?.round() ?? 0;
      if (currentStep == totalSteps - 1) {
        logger.d('Total Score: ${calculateTotalScore()} && step: $currentStep');
      }
    });
  }

  void moveToNextPage() {
    if (_pageController.page!.round() < totalSteps - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      setState(() {
        currentStep = totalSteps;
      });
      logger.d('Total Score: ${calculateTotalScore()} && step: $currentStep');
    }
  }

  int calculateTotalScore() {
    totalScore = 0;
    for (Map<String, dynamic> questionData in act_questions) {
      int selectedAnswerIndex = questionData['selectedAnswerIndex'];
      if (selectedAnswerIndex != -1) {
        // Increment total score by the score of the selected answer
        totalScore += selectedAnswerIndex + 1;
      }
    }
    return totalScore;
  }

  Future<void> _submitACT() async {
    // try {
    //   final Map<String, dynamic>? actData =
    //       await ACTDataApi().postAsthmaControlTestData(totalScore);
    //   if (actData != null) {
    //     logger.d('ACT Data: $actData');
    //     const CustomSnackBar(
    //       message: 'Your ACT has been submitted!',
    //       success: true,
    //     );
    //     _clearAllSelections();
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) =>
    //             AsthmaControlTestResultScreen(score: totalScore),
    //       ),
    //     );
    //   } else {
    //     const CustomSnackBar(
    //       message: 'Failed to submit ACT!',
    //       success: false,
    //     );
    //   }
    // } catch (e) {
    //   CustomSnackBar(
    //     message: 'Error: $e!',
    //     success: false,
    //   );
    // }
  }

  void _clearAllSelections() {
    setState(() {
      for (var question in act_questions) {
        question['selectedAnswerIndex'] = -1;
        question['score'] = 0;
      }
      currentStep = 0;
      _pageController.jumpToPage(
          0); // Optionally reset the page view to the first question
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF004283),
          foregroundColor: const Color(0xFFFFFFFF),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Asthma Control Test',
              style: TextStyle(
                fontSize: 10 * screenRatio,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ),
        drawer: CustomDrawer(
          realm: widget.realm,
          deviceToken: widget.deviceToken,
          deviceType: widget.deviceType,
          onClose: () {
            Navigator.of(context).pop();
          },
          itemName: (String name) {
            logger.d(name);
          },
        ),
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const ClampingScrollPhysics(),
            child: Center(
              child: Container(
                width: screenSize.width,
                height: screenSize.height,
                padding: EdgeInsets.all(screenSize.height * 0.01),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: screenSize.width,
                      height: screenRatio * 12,
                      child: Text(
                        'Asthma Control Test (ACT)',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Color(0xFF004283),
                          fontSize: 8 * screenRatio,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.01),
                    SizedBox(
                      width: screenSize.width,
                      height: screenRatio * 96,
                      child: Center(
                        child: Text(
                          'Your Asthma Score will assist your Health Care Professional in helping you reach the best asthma control possible. Asthma Score is a way of working out your level of asthma control. Even if you think your asthma is under control, knowing your Asthma Score is still important. To work out your Asthma Score answer the question below:',
                          textAlign: TextAlign.left,
                          softWrap: true,
                          style: TextStyle(
                            color: Color(0xFF004283),
                            fontSize: 8 * screenRatio,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.01),
                    SizedBox(
                      width: screenSize.width,
                      height: screenSize.height * 0.08,
                      child: StepProgressIndicator(
                          totalSteps: totalSteps, currentStep: currentStep),
                    ),
                    SizedBox(height: screenSize.height * 0.01),
                    SizedBox(
                      width: screenSize.width,
                      height: 128 * screenRatio,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: act_questions.length,
                        itemBuilder: (context, index) {
                          // Retrieve question data for the current index
                          Map<String, dynamic> questionData =
                              act_questions[index];
                          return QuestionnaireWidget(
                            question: questionData['question'],
                            options: questionData['options'],
                            selectedAnswerIndex:
                                questionData['selectedAnswerIndex'],
                            onTap: (answerIndex, selectedScore) {
                              setState(() {
                                // Update the selected answer index for the current question
                                act_questions[index]['selectedAnswerIndex'] =
                                    answerIndex;
                                // Calculate score for the current question
                                act_questions[index]['score'] = selectedScore;
                                moveToNextPage();
                              });
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: screenSize.width,
                      height: screenSize.height * 0.08,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: currentStep != 5
                                ? null
                                : () {
                                    _submitACT();
                                  },
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(screenSize.width * 0.24,
                                  screenSize.height * 0.06),
                              foregroundColor: const Color(0xFFFFFFFF),
                              backgroundColor: const Color(0xFF004283),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _clearAllSelections();
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(screenSize.width * 0.24,
                                  screenSize.height * 0.06),
                              foregroundColor: const Color(0xFF707070),
                              backgroundColor: const Color(0xFFFFFFFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                  color: Color(
                                      0xFF707070), // Specify the border color here
                                  width: 1, // Specify the border width here
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Color(0xFF707070),
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
