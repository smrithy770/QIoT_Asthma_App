import 'dart:io';

import 'package:asthmaapp/api/note_api.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model.dart';
import 'package:asthmaapp/screens/user_ui/notes_screen/widgets/notes_card_widget.dart';
import 'package:asthmaapp/screens/user_ui/widgets/custom_drawer.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

class NotesScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  const NotesScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<NotesScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NotesScreen> {
  UserModel? userModel;

  List<dynamic> allNotes = [];
  Map<String, dynamic> noteById = {};
  bool isFetching = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _handleRefresh();
  }

  Future<void> _loadUserData() async {
    final user = getUserData(widget.realm);
    if (user != null) {
      setState(() {
        userModel = user;
      });
    }
  }

  UserModel? getUserData(Realm realm) {
    final results = realm.all<UserModel>();
    return results.isNotEmpty ? results[0] : null;
  }

  Future<void> _handleRefresh() async {
    if (isFetching || userModel == null) return;
    setState(() {
      isFetching = true;
    });

    try {
      final jsonResponse = await NoteApi().getAllNotes(
        userModel!.id,
        userModel!.accessToken,
      );
      final status = jsonResponse['status'];

      if (status == 200) {
        final payload = jsonResponse['payload'];
        setState(() {
          allNotes = payload;
        });
      } else {
        logger.d('Failed to fetch drainage history: $jsonResponse');
      }
    } on SocketException catch (e) {
      logger.d('NetworkException: $e');
    } on Exception catch (e) {
      logger.d('Failed to fetch data: $e');
    } finally {
      setState(() {
        isFetching = false;
      });
    }
  }

  void _deleteNote(String noteId) async {
    if (userModel == null) return;

    try {
      final response = await NoteApi().deleteNoteById(
        userModel!.id,
        noteId,
        userModel!.accessToken,
      );
      final jsonResponse = response;
      final status = jsonResponse['status'];
      if (status == 200) {
        CustomSnackBarUtil.showCustomSnackBar("Note deleted successfully",
            success: true);
        _handleRefresh();
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
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Notes',
            style: TextStyle(
              fontSize: screenRatio * 9,
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
        onItemSelected: (int index) {
          logger.d(index);
        },
      ),
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        backgroundColor: AppColors.primaryWhite,
        onRefresh: _handleRefresh,
        child: allNotes.isEmpty
            ? const Center(
                child: Text('No notes available'),
              )
            : ListView.builder(
                padding: EdgeInsets.all(screenRatio * 4),
                itemCount: allNotes.length,
                itemBuilder: (context, index) {
                  final notes = allNotes[index];
                  return NoteCardWidget(
                    note: notes,
                    onEdit: () {
                      logger.d('Edit at index ${notes['_id']}');
                      Navigator.popAndPushNamed(
                        context,
                        '/edit_note_screen',
                        arguments: {
                          'realm': widget.realm,
                          'noteId': notes['_id'],
                          'deviceToken': widget.deviceToken,
                          'deviceType': widget.deviceType,
                        },
                      );
                    },
                    onDelete: () {
                      _deleteNote(notes['_id']);
                    },
                    screenRatio: screenRatio,
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/add_notes_screen',
            arguments: {
              'realm': widget.realm,
              'deviceToken': widget.deviceToken ?? '',
              'deviceType': widget.deviceType ?? '',
            },
          );
        },
        backgroundColor: AppColors.primaryBlue,
        child: Icon(
          Icons.add,
          color: AppColors.primaryWhite,
          size: screenRatio * 16,
        ),
      ),
    );
  }
}
