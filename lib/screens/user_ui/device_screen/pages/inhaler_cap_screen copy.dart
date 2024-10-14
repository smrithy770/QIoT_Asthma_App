import 'dart:async';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:asthmaapp/screens/user_ui/device_screen/widgets/custom_device_data_widget.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:intl/intl.dart';
import 'package:realm/realm.dart';

class InhalerCapScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  final BluetoothDevice inhalerDevice;

  const InhalerCapScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
    required this.inhalerDevice,
  });

  @override
  State<InhalerCapScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<InhalerCapScreen> {
  UserModel? userModel;
  int _counterValue = 0; // Counter value
  String _formattedTimestamp = 'Unknown'; // Timestamp value
  int _buttonPresses = 0; // Button presses value
  int _cumulativeButtonPresses = 0; // Cumulative button presses value
  int _requestDataIndex = 0; // Request Data Index value
  String _formattedrtcTime = 'Unknown'; // RTC Time value
  int _deviceId = 0; // Device ID value

  BluetoothService?
      _dataPointService; // Variable to hold the Data Point Service
  BluetoothService? _settingsService; // Variable to hold the Settings Service

  @override
  void initState() {
    super.initState();
    _connectAndReadValues();
    _loadUserData();
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
    if (results.isNotEmpty) {
      return results[0];
    }
    return null;
  }

  void _connectAndReadValues() async {
    try {
      await widget.inhalerDevice.connect();
      logger.d("Connected to device: ${widget.inhalerDevice.platformName}");

      // Discover services
      List<BluetoothService> services =
          await widget.inhalerDevice.discoverServices();

      // Find Data Point Service
      _dataPointService = services.firstWhereOrNull(
        (service) =>
            service.uuid.toString() == '4cde1523-f90f-4962-8f2d-e1adc76edb6d',
      );

      if (_dataPointService != null) {
        await Future.wait([
          _readCharacteristic(_dataPointService!,
              '4cde1524-f90f-4962-8f2d-e1adc76edb6d', _updateCounterValue),
          _readCharacteristic(_dataPointService!,
              '4cde1525-f90f-4962-8f2d-e1adc76edb6d', _updateTimestampValue),
          _readCharacteristic(
              _dataPointService!,
              '4cde1526-f90f-4962-8f2d-e1adc76edb6d',
              _updateButtonPressesValue),
          _readCharacteristic(
              _dataPointService!,
              '4cde1528-f90f-4962-8f2d-e1adc76edb6d',
              _updateCumulativeButtonPressesValue),
          _readCharacteristic(
              _dataPointService!,
              '4cde1527-f90f-4962-8f2d-e1adc76edb6d',
              _updateRequestDataIndexValue),
        ]);

        // Enable notifications for button presses characteristic
        _enableButtonPressesNotifications();
      } else {
        logger.e("Data Point Service not found");
      }

      // Find Settings Service
      _settingsService = services.firstWhereOrNull(
        (service) =>
            service.uuid.toString() == '4cde1530-f90f-4962-8f2d-e1adc76edb6d',
      );

      if (_settingsService != null) {
        await Future.wait([
          _readRtcCharacteristic(_settingsService!),
          _readCharacteristic(_settingsService!,
              '4cde1532-f90f-4962-8f2d-e1adc76edb6d', _updateDeviceIdValue),
        ]);
      } else {
        logger.e("Settings Service not found");
      }

      // Timer to handle the 30-second timeout for disconnection
      Timer(const Duration(seconds: 30), () {
        _disconnectDevice();
      });
    } catch (e) {
      logger.e("Failed to connect and read values: $e");
    }
  }

  Future<void> _enableButtonPressesNotifications() async {
    if (_dataPointService != null) {
      BluetoothCharacteristic? characteristic =
          _dataPointService!.characteristics.firstWhereOrNull(
        (c) => c.uuid.toString() == '4cde1526-f90f-4962-8f2d-e1adc76edb6d',
      );

      if (characteristic != null && characteristic.properties.notify) {
        try {
          // Subscribe to notifications
          await characteristic.setNotifyValue(true);

          characteristic.lastValueStream.listen((value) {
            _updateButtonPressesValue(value);
          });

          logger.d(
              "Listening for notifications on Button Presses characteristic");
        } catch (e) {
          logger.e("Error enabling notifications: $e");
        }
      } else {
        logger.e(
            "Button Presses characteristic not found or does not support notifications");
      }
    } else {
      logger.e("Data Point Service not found");
    }
  }

  Future<void> _readCharacteristic(BluetoothService service,
      String characteristicUuid, Function(List<int>) updateValue) async {
    BluetoothCharacteristic? characteristic =
        service.characteristics.firstWhereOrNull(
      (c) => c.uuid.toString() == characteristicUuid,
    );

    logger.d("Characteristic: $characteristic");
    logger.d("Characteristic properties: ${characteristic?.properties}");

    if (characteristic != null && characteristic.properties.read) {
      try {
        List<int> value = await characteristic.read();
        updateValue(value);
      } catch (e) {
        logger.e("Error reading characteristic $characteristicUuid: $e");
      }
    } else {
      logger.e("Characteristic $characteristicUuid not found or not readable");
    }
  }

  void _updateCounterValue(List<int> value) {
    if (value.length >= 2) {
      int counterValue = (value[1] << 8) | value[0]; // Little-endian format
      logger.d("Counter Value: $counterValue");
      setState(() {
        _counterValue = counterValue;
      });
      CustomSnackBarUtil.showCustomSnackBar("Counter Value: $counterValue",
          success: true);
    } else {
      logger.e("Unexpected value length for Counter characteristic");
    }
  }

  void _updateTimestampValue(List<int> value) {
    if (value.length >= 4) {
      int timestampValue = (value[3] << 24) |
          (value[2] << 16) |
          (value[1] << 8) |
          value[0]; // Little-endian format

      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(timestampValue * 1000);
      String formattedDate =
          DateFormat('dd MMM, yyyy - hh mm a').format(dateTime);

      logger.d("Timestamp Value: $formattedDate");
      setState(() {
        _formattedTimestamp = formattedDate;
      });
      CustomSnackBarUtil.showCustomSnackBar("Timestamp Value: $formattedDate",
          success: true);
    } else {
      logger.e("Unexpected value length for Timestamp characteristic");
    }
  }

  void _updateButtonPressesValue(List<int> value) {
    logger.d("Raw Button Presses Value: $value");
    if (value.length == 4) {
      int buttonPresses = value[0] | (value[1] << 8);
      logger.d("Button Presses Value: $buttonPresses");
      setState(() {
        _buttonPresses = buttonPresses;
      });
    } else if (value.length == 1) {
      int buttonPresses = value[0];
      logger.d("Button Presses Value: $buttonPresses");
      setState(() {
        _buttonPresses = buttonPresses;
      });
    } else {
      logger.e(
          "Unexpected value length for Button Presses characteristic: ${value.length}");
    }
  }

  void _updateCumulativeButtonPressesValue(List<int> value) {
    if (value.length == 4) {
      int cumulativeButtonPresses = value[0] |
          (value[1] << 8) |
          (value[2] << 16) |
          (value[3] << 24); // Combine all 4 bytes
      logger.d("Cumulative Button Presses Value: $cumulativeButtonPresses");
      setState(() {
        _cumulativeButtonPresses = cumulativeButtonPresses;
      });
      CustomSnackBarUtil.showCustomSnackBar(
          "Cumulative Button Presses Value: $cumulativeButtonPresses",
          success: true);
    } else {
      logger.e(
          "Unexpected value length for Cumulative Button Presses characteristic: ${value.length}");
    }
  }

  void _updateRequestDataIndexValue(List<int> value) {
    logger.d("Raw Request Data Index Value: $value");
    if (value.length == 4) {
      int requestDataIndex = value[0] | (value[1] << 8);
      logger.d("Request Data Index Value: $requestDataIndex");
      setState(() {
        _requestDataIndex = requestDataIndex;
      });
    } else {
      logger.e(
          "Unexpected value length for Request Data Index characteristic: ${value.length}");
    }
  }

  void _updateDeviceIdValue(List<int> value) {
    if (value.length == 4) {
      int deviceId =
          value[0] | (value[1] << 8) | (value[2] << 16) | (value[3] << 24);
      logger.d("Device ID: $deviceId");
      setState(() {
        _deviceId = deviceId;
      });
    } else {
      logger.e(
          "Unexpected value length for Device ID characteristic: ${value.length}");
    }
  }

  // Write the button presses value to Request Data Index characteristic
  Future<void> _writeRequestDataIndex(int buttonPresses) async {
    if (_dataPointService != null) {
      BluetoothCharacteristic? characteristic =
          _dataPointService!.characteristics.firstWhereOrNull(
        (c) => c.uuid.toString() == '4cde1527-f90f-4962-8f2d-e1adc76edb6d',
      );

      if (characteristic != null && characteristic.properties.write) {
        // Convert the button presses to bytes (2-byte unsigned integer)
        List<int> bytes = [
          buttonPresses & 0xFF, // Low byte
          (buttonPresses >> 8) & 0xFF, // High byte
        ];

        try {
          await characteristic.write(bytes);
          logger.d("Wrote to Request Data Index: $bytes");
          // After writing, read the new button presses value
          _readCharacteristic(
              _dataPointService!,
              '4cde1526-f90f-4962-8f2d-e1adc76edb6d',
              _updateButtonPressesValue);
        } catch (e) {
          logger.e("Error writing to Request Data Index characteristic: $e");
        }
      } else {
        logger.e("Request Data Index characteristic not found or not writable");
      }
    } else {
      logger.e("Data Point Service not found");
    }
  }

  Future<void> _readRtcCharacteristic(BluetoothService settingsService) async {
    BluetoothCharacteristic? rtcCharacteristic =
        settingsService.characteristics.firstWhereOrNull(
      (c) => c.uuid.toString() == '4cde1531-f90f-4962-8f2d-e1adc76edb6d',
    );

    if (rtcCharacteristic != null && rtcCharacteristic.properties.read) {
      try {
        List<int> rtcValue = await rtcCharacteristic.read();
        if (rtcValue.length == 4) {
          // Check if we received 4 bytes
          int rtcTimeValue = rtcValue[0] |
              (rtcValue[1] << 8) |
              (rtcValue[2] << 16) |
              (rtcValue[3] << 24); // Combine all 4 bytes
          DateTime dateTime =
              DateTime.fromMillisecondsSinceEpoch(rtcTimeValue * 1000);
          String formattedDate =
              DateFormat('dd MMM, yyyy - hh mm a').format(dateTime);
          logger.d("RTC Time Value: $rtcTimeValue");

          setState(() {
            _formattedrtcTime = formattedDate;
          });
        } else {
          logger.e(
              "RTC characteristic returned unexpected value length: ${rtcValue.length}");
        }
      } catch (e) {
        logger.e("Error reading RTC characteristic: $e");
      }
    } else {
      logger.e("RTC characteristic not found or not readable");
    }
  }

  void _disconnectDevice() {
    widget.inhalerDevice.disconnect();
    logger.d("Disconnected from device: ${widget.inhalerDevice.platformName}");
    CustomSnackBarUtil.showCustomSnackBar(
        "Disconnected from device: ${widget.inhalerDevice.platformName}",
        success: false);
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.primaryWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            'Inhaler Cap',
            style: TextStyle(
              fontSize: 10 * screenRatio,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenSize.height * 0.016),
              // Data from Data Point Service
              SizedBox(
                width: screenSize.width,
                height: screenRatio * 16,
                child: Text(
                  'Device Data',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryBlueText,
                    fontSize: screenRatio * 9,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomDeviceData(
                    label: 'Counter Value',
                    value: _counterValue.toString(),
                    screenRatio: screenRatio,
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  CustomDeviceData(
                    label: 'Timestamp Value',
                    value: _formattedTimestamp,
                    screenRatio: screenRatio,
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  CustomDeviceData(
                    label: 'Button Presses',
                    value: '$_buttonPresses',
                    screenRatio: screenRatio,
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  SizedBox(
                    width: screenSize.width,
                    child: ElevatedButton(
                      onPressed: () {
                        _writeRequestDataIndex(225);
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(
                          screenRatio * 16,
                          screenRatio * 24,
                        ),
                        foregroundColor: AppColors.primaryWhite,
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenRatio * 8,
                          vertical: screenRatio * 4,
                        ),
                      ),
                      child: Text(
                        'Check Button Presses for Index 225',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 8 * screenRatio,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  CustomDeviceData(
                    label: 'Cumulative Button Presses',
                    value: '$_cumulativeButtonPresses',
                    screenRatio: screenRatio,
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  CustomDeviceData(
                    label: 'Request Data Index',
                    value: '$_requestDataIndex',
                    screenRatio: screenRatio,
                  ),
                ],
              ),
              // Data from Settings Service
              SizedBox(height: screenSize.height * 0.016),
              // Data from Data Point Service
              SizedBox(
                width: screenSize.width,
                height: screenRatio * 16,
                child: Text(
                  'Settings Data',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryBlueText,
                    fontSize: screenRatio * 9,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomDeviceData(
                    label: 'Real Time Clock (RTC) Time',
                    value: _formattedrtcTime.toString(),
                    screenRatio: screenRatio,
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  CustomDeviceData(
                    label: 'Device ID',
                    value: _deviceId.toString(),
                    screenRatio: screenRatio,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
