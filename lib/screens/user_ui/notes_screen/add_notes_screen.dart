import 'dart:io';

import 'package:asthmaapp/api/note_api.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'notes_screen.dart';

class AddNotesScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;

  const AddNotesScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<AddNotesScreen> createState() => _AddNotesScreen();
}

class _AddNotesScreen extends State<AddNotesScreen> {
  UserModel? userModel;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String feelRating = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = getUserData(widget.realm);
    setState(() {
      userModel = user;
    });
  }

  UserModel? getUserData(Realm realm) {
    final results = realm.all<UserModel>();
    return results.isNotEmpty ? results[0] : null;
  }

  void _submitNote() async {
    if (userModel == null) return;
    if (_formKey.currentState!.validate()) {
      // Logic to submit the note to the database

      String title = _titleController.text.trim();
      String description = _descriptionController.text.trim();
      try {
        final response = await NoteApi().addNotes(
          userModel!.id,
          title,
          description,
          feelRating,
          userModel!.accessToken,
        );
        final jsonResponse = response;
        final status = jsonResponse['status'];
        if (status == 201) {
          CustomSnackBarUtil.showCustomSnackBar("Note added successfully",
              success: true);
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => NotesScreen(
                  realm: widget.realm,
                  deviceToken: widget.deviceToken,
                  deviceType: widget.deviceType,
                ),
              ),
              (Route<dynamic> route) => false,
            );
          }
        } else {
          // Handle different statuses
          String errorMessage;
          switch (status) {
            case 400:
              errorMessage = 'Bad request: Please check your input';
              break;
            case 500:
              errorMessage = 'Server error: Please try again later';
              break;
            default:
              errorMessage = 'Unexpected error: Please try again';
          }

          // Show error message
          CustomSnackBarUtil.showCustomSnackBar(errorMessage, success: false);
        }
      } on SocketException catch (e) {
        // Handle network-specific exceptions
        logger.d('NetworkException: $e');
        CustomSnackBarUtil.showCustomSnackBar(
            'Network error: Please check your internet connection',
            success: false);
      } on Exception catch (e) {
        // Handle generic exceptions
        logger.d('Exception: $e');
        CustomSnackBarUtil.showCustomSnackBar(
            'An error occurred while adding the note',
            success: false);
      }
    } else {
      if (_titleController.text.isEmpty) {
        CustomSnackBarUtil.showCustomSnackBar('Title can not be empty',
            success: false);
        return;
      }
      if (_descriptionController.text.isEmpty) {
        CustomSnackBarUtil.showCustomSnackBar('Description can not be empty',
            success: false);
        return;
      }
      if (feelRating.isEmpty) {
        CustomSnackBarUtil.showCustomSnackBar('Feeling rating can not be empty',
            success: false);
        return;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.primaryWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
              context,
              MaterialPageRoute(
                builder: (context) => NotesScreen(
                  realm: widget.realm,
                  deviceToken: widget.deviceToken,
                  deviceType: widget.deviceType,
                ),
              ),
            );
          },
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Add Notes',
            style: TextStyle(
              fontSize: screenRatio * 9,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            child: Container(
              width: screenSize.width,
              height: screenSize.height,
              padding: EdgeInsets.all(screenRatio * 4),
              child: Column(
                children: [
                  SizedBox(height: screenRatio * 4),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenRatio * 8,
                              vertical: screenRatio * 4,
                            ),
                            labelText: 'Title',
                            labelStyle: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: screenRatio * 6,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenRatio * 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'How are you Feeling today?',
                              style: TextStyle(
                                fontSize: 6 * screenRatio,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Container(
                                    color: feelRating == 'Happy'
                                        ? Colors.green
                                        : Colors.white,
                                    child: Icon(
                                      Icons.sentiment_satisfied_sharp,
                                      size: screenRatio * 16,
                                    ),
                                  ),
                                  color: feelRating == 'Happy'
                                      ? Colors.white
                                      : Colors.green,
                                  onPressed: () {
                                    setState(() {
                                      feelRating = 'Happy';
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Container(
                                    color: feelRating == 'Average'
                                        ? Colors.orange
                                        : Colors.white,
                                    child: Icon(
                                      Icons.sentiment_neutral,
                                      size: screenRatio * 16,
                                    ),
                                  ),
                                  color: feelRating == 'Average'
                                      ? Colors.white
                                      : Colors.orange,
                                  onPressed: () {
                                    setState(() {
                                      feelRating = 'Average';
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Container(
                                    color: feelRating == 'Sad'
                                        ? Colors.amber
                                        : Colors.white,
                                    child: Icon(
                                      Icons.sentiment_dissatisfied_sharp,
                                      size: screenRatio * 16,
                                    ),
                                  ),
                                  color: feelRating == 'Sad'
                                      ? Colors.white
                                      : Colors.amber,
                                  onPressed: () {
                                    setState(() {
                                      feelRating = 'Sad';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: screenRatio * 4),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 12,
                          maxLength: 1000,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenRatio * 8,
                              vertical: screenRatio * 4,
                            ),
                            labelText: 'Description',
                            labelStyle: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: screenRatio * 6,
                            ),
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenRatio * 4),
                  SizedBox(height: screenRatio * 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenSize.width * 0.4,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(
                              screenRatio * 16,
                              screenRatio * 24,
                            ),
                            foregroundColor: const Color(0xFF707070),
                            backgroundColor: const Color(0xFFFFFFFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                color: AppColors
                                    .primaryGreyText, // Specify the border color here
                                width: 1, // Specify the border width here
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenRatio * 8,
                              vertical: screenRatio * 4,
                            ),
                          ),
                          child: Text(
                            'Discard',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.primaryGreyText,
                              fontSize: 8 * screenRatio,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: screenSize.width * 0.4,
                        child: ElevatedButton(
                          onPressed: () {
                            _submitNote();
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(
                              screenRatio * 16,
                              screenRatio * 24,
                            ),
                            foregroundColor: const Color(0xFFFFFFFF),
                            backgroundColor: const Color(0xFF004283),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenRatio * 8,
                              vertical: screenRatio * 4,
                            ),
                          ),
                          child: Text(
                            'Add Note',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 8 * screenRatio,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenRatio * 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
