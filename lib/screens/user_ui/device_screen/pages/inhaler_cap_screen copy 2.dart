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
  String _formattedrtcTime = 'Unknown'; // RTC Time value
  int _deviceId = 0; // Device ID value

  BluetoothService?
      _dataPointService; // Variable to hold the Data Point Service
  BluetoothService? _settingsService; // Variable to hold the Settings Service

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
          _readCharacteristic(_dataPointService!,
              '4cde1532-f90f-4962-8f2d-e1adc76edb6d', _updateDeviceIdValue),
        ]);
      } else {
        logger.e("Data Point Service not found");
      }

      // Find Settings Service
      _settingsService = services.firstWhereOrNull(
        (service) =>
            service.uuid.toString() == '4cde1530-f90f-4962-8f2d-e1adc76edb6d',
      );

      if (_settingsService != null) {
        await _readRtcCharacteristic(_settingsService!);
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

  Future<void> _readCharacteristic(BluetoothService service,
      String characteristicUuid, Function(List<int>) updateValue) async {
    BluetoothCharacteristic? characteristic =
        service.characteristics.firstWhereOrNull(
      (c) => c.uuid.toString() == characteristicUuid,
    );

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
    if (value.length == 4) {
      int buttonPresses = value[0] |
          (value[1] << 8) |
          (value[2] << 16) |
          (value[3] << 24); // Interpret as unsigned int
      logger.d("Button Presses Value: $buttonPresses");
      setState(() {
        _buttonPresses = buttonPresses;
      });
      CustomSnackBarUtil.showCustomSnackBar(
          "Button Presses Value: $buttonPresses",
          success: true);
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
    if (value.length == 4) {
      int requestDataIndex = value[0] |
          (value[1] << 8) |
          (value[2] << 16) |
          (value[3] << 24); // Combine all 4 bytes
      logger.d("Request Data Index Value: $requestDataIndex");
      setState(() {
        _requestDataIndex = requestDataIndex;
      });
      CustomSnackBarUtil.showCustomSnackBar(
          "Request Data Index Value: $requestDataIndex",
          success: true);
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
        "Disconnected from device: ${widget.inhalerDevice.platformName}");
    Navigator.of(context).pop();
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
              value: _counterValue.toString(),
              screenRatio: screenRatio,
            ),
            CustomDeviceData(
              label: 'Timestamp Value',
              value: _formattedTimestamp,
              screenRatio: screenRatio,
            ),
            CustomDeviceData(
              label: 'Button Presses Value',
              value: _buttonPresses.toString(),
              screenRatio: screenRatio,
            ),
            CustomDeviceData(
              label: 'Cumulative Button Presses Value',
              value: _cumulativeButtonPresses.toString(),
              screenRatio: screenRatio,
            ),
            CustomDeviceData(
              label: 'Request Data Index',
              value: _requestDataIndex.toString(),
              screenRatio: screenRatio,
            ),
            CustomDeviceData(
              label: 'Device ID',
              value: _deviceId.toString(),
              screenRatio: screenRatio,
            ),
            CustomDeviceData(
              label: 'RTC Time',
              value: _formattedrtcTime.toString(),
              screenRatio: screenRatio,
            ),
          ],
        ),
      ),
    );
  }
}
