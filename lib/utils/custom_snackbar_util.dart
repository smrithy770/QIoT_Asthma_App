import 'package:flutter/material.dart';
import 'package:asthmaapp/widgets/custom_snackbar.dart';

class CustomSnackBarUtil {
  static final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showCustomSnackBar(String message, {bool success = true}) {
    final snackBar = SnackBar(
      content: CustomSnackBar(
        message: message,
        success: success,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
    );

    // Use the root scaffold messenger key to show the snackbar
    rootScaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }
}
