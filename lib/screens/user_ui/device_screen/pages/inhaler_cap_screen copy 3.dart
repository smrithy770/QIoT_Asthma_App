import 'dart:async';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
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
  int _counterValue = 0; // Counter value
  String _formattedTimestamp = 'Unknown'; // Timestamp value
  int _buttonPresses = 0; // Button presses value
  int _cumulativeButtonPresses = 0; // Cumulative button presses value
  int _requestDataIndex = 0; // Request Data Index value

  BluetoothService?
      _dataPointService; // Variable to hold the Data Point Service

  @override
  void initState() {
    super.initState();
    _connectAndReadValues();
  }

  void _connectAndReadValues() async {
    try {
      await widget.inhalerDevice.connect();
      logger.d("Connected to device: ${widget.inhalerDevice.platformName}");
      CustomSnackBarUtil.showCustomSnackBar(
        "Connected to device: ${widget.inhalerDevice.platformName}",
        success: true,
      );

      // Discover services
      List<BluetoothService> services =
          await widget.inhalerDevice.discoverServices();

      // Find Data Point Service
      _dataPointService = services.firstWhereOrNull(
        (service) =>
            service.uuid.toString() == '4cde1523-f90f-4962-8f2d-e1adc76edb6d',
      );

      // If Data Point Service is found, read the characteristics
      if (_dataPointService != null) {
        await _readCounterCharacteristic(_dataPointService!);
        await _readTimestampCharacteristic(_dataPointService!);
        await _readButtonPressesCharacteristic(_dataPointService!);
        await _readCumulativeButtonPressesCharacteristic(
            _dataPointService!); // Read cumulative button presses
        await _readRequestDataIndexCharacteristic(_dataPointService!);
      } else {
        logger.e("Data Point Service not found");
      }

      // Timer to handle the 30-second timeout for disconnection
      Timer(const Duration(seconds: 30), () {
        _disconnectDevice();
      });
    } catch (e) {
      logger.e("Failed to connect and read values: $e");
    }
  }

  Future<void> _readCounterCharacteristic(
      BluetoothService _dataPointService) async {
    BluetoothCharacteristic? counterCharacteristic =
        _dataPointService.characteristics.firstWhereOrNull(
      (characteristic) =>
          characteristic.uuid.toString() ==
          '4cde1524-f90f-4962-8f2d-e1adc76edb6d',
    );

    if (counterCharacteristic != null &&
        counterCharacteristic.properties.read) {
      List<int> value = await counterCharacteristic.read();

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
    } else {
      logger.e("Counter characteristic not found or not readable");
    }
  }

  Future<void> _readTimestampCharacteristic(
      BluetoothService _dataPointService) async {
    BluetoothCharacteristic? timestampCharacteristic =
        _dataPointService.characteristics.firstWhereOrNull(
      (characteristic) =>
          characteristic.uuid.toString() ==
          '4cde1525-f90f-4962-8f2d-e1adc76edb6d',
    );

    if (timestampCharacteristic != null &&
        timestampCharacteristic.properties.read) {
      List<int> value = await timestampCharacteristic.read();

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
          _formattedTimestamp =
              formattedDate; // Add this to hold the formatted date
        });
        CustomSnackBarUtil.showCustomSnackBar(
          "Timestamp Value: $formattedDate",
          success: true,
        );
      } else {
        logger.e("Unexpected value length for Timestamp characteristic");
      }
    } else {
      logger.e("Timestamp characteristic not found or not readable");
    }
  }

  Future<void> _readButtonPressesCharacteristic(
      BluetoothService _dataPointService) async {
    BluetoothCharacteristic? buttonPressesCharacteristic =
        _dataPointService.characteristics.firstWhereOrNull(
      (characteristic) =>
          characteristic.uuid.toString() ==
          '4cde1526-f90f-4962-8f2d-e1adc76edb6d',
    );

    if (buttonPressesCharacteristic != null &&
        buttonPressesCharacteristic.properties.read) {
      try {
        List<int> value = await buttonPressesCharacteristic.read();

        if (value.length == 4) {
          int buttonPresses = value[0] |
              (value[1] << 8) |
              (value[2] << 16) |
              (value[3] << 24); // Interpret as unsigned int
          logger.d("Button Presses Value: $buttonPresses");
          setState(() {
            _buttonPresses = buttonPresses; // Update the button presses value
          });
          CustomSnackBarUtil.showCustomSnackBar(
            "Button Presses Value: $buttonPresses",
            success: true,
          );
        } else {
          logger.e(
              "Unexpected value length for Button Presses characteristic: ${value.length}");
        }
      } catch (e) {
        logger.e("Error reading Button Presses characteristic: $e");
      }
    } else {
      logger.e("Button Presses characteristic not found or not readable");
    }
  }

  Future<void> _readCumulativeButtonPressesCharacteristic(
      BluetoothService _dataPointService) async {
    BluetoothCharacteristic? cumulativeButtonPressesCharacteristic =
        _dataPointService.characteristics.firstWhereOrNull(
      (characteristic) =>
          characteristic.uuid.toString() ==
          '4cde1528-f90f-4962-8f2d-e1adc76edb6d', // Cumulative Button Presses UUID
    );

    if (cumulativeButtonPressesCharacteristic != null &&
        cumulativeButtonPressesCharacteristic.properties.read) {
      try {
        List<int> value = await cumulativeButtonPressesCharacteristic.read();

        if (value.length == 2) {
          int cumulativeButtonPresses =
              value[0] | (value[1] << 8); // Little-endian format
          logger.d("Cumulative Button Presses Value: $cumulativeButtonPresses");
          setState(() {
            _cumulativeButtonPresses =
                cumulativeButtonPresses; // Update the cumulative button presses value
          });
          CustomSnackBarUtil.showCustomSnackBar(
            "Cumulative Button Presses Value: $cumulativeButtonPresses",
            success: true,
          );
        } else {
          logger.e(
              "Unexpected value length for Cumulative Button Presses characteristic: ${value.length}");
        }
      } catch (e) {
        logger.e("Error reading Cumulative Button Presses characteristic: $e");
      }
    } else {
      logger.e(
          "Cumulative Button Presses characteristic not found or not readable");
    }
  }

  Future<void> _readRequestDataIndexCharacteristic(
      BluetoothService _dataPointService) async {
    BluetoothCharacteristic? requestDataIndexCharacteristic =
        _dataPointService.characteristics.firstWhereOrNull(
      (characteristic) =>
          characteristic.uuid.toString() ==
          '4cde1527-f90f-4962-8f2d-e1adc76edb6d',
    );

    if (requestDataIndexCharacteristic != null &&
        requestDataIndexCharacteristic.properties.read) {
      try {
        List<int> value = await requestDataIndexCharacteristic.read();

        if (value.length == 4) {
          int requestDataIndex = (value[1] << 8) | value[0]; // First two bytes
          // If there are other data points, handle them accordingly
          logger.d("Request Data Index Value: $requestDataIndex");
          setState(() {
            _requestDataIndex = requestDataIndex; // Update request data index
          });
          CustomSnackBarUtil.showCustomSnackBar(
            "Request Data Index Value: $requestDataIndex",
            success: true,
          );
        } else {
          logger.e(
              "Unexpected value length for Request Data Index characteristic: ${value.length}");
        }
      } catch (e) {
        logger.e("Error reading Request Data Index characteristic: $e");
      }
    } else {
      logger.e("Request Data Index characteristic not found or not readable");
    }
  }

  Future<void> _disconnectDevice() async {
    if (widget.inhalerDevice.isConnected) {
      await widget.inhalerDevice.disconnect();
      logger
          .d("Disconnected from device: ${widget.inhalerDevice.platformName}");
      CustomSnackBarUtil.showCustomSnackBar(
        "Disconnected from device: ${widget.inhalerDevice.platformName}",
        success: true,
      );
    }
  }

  @override
  void dispose() {
    _disconnectDevice();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final double screenRatio = screenSize.height / screenSize.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inhaler Cap Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomDeviceData(
              label: 'Counter Value',
              value: '$_counterValue',
              screenRatio: screenRatio,
            ),
            CustomDeviceData(
              label: 'Timestamp',
              value: _formattedTimestamp,
              screenRatio: screenRatio,
            ),
            CustomDeviceData(
              label: 'Button Presses',
              value: '$_buttonPresses',
              screenRatio: screenRatio,
            ),
            CustomDeviceData(
              label: 'Cumulative Button Presses',
              value: '$_cumulativeButtonPresses',
              screenRatio: screenRatio,
            ),
            CustomDeviceData(
              label: 'Request Data Index',
              value: '$_requestDataIndex',
              screenRatio: screenRatio,
            ),
          ],
        ),
      ),
    );
  }
}
