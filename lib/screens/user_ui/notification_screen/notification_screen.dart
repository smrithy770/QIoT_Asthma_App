import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Map<String, dynamic> payLoad = {};
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    // final Map<String, dynamic> data =
    //     ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final data = ModalRoute.of(context)!.settings.arguments;
    if (data is RemoteMessage) {
      payLoad = data.data;
    }
    if (data is NotificationResponse) {
      payLoad = jsonDecode(data.payload!);
    }
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.primaryWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, '/home');
          },
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Notifications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
      body: Center(
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                payLoad.toString(),
                style: const TextStyle(
                  color: AppColors.primaryBlueText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
