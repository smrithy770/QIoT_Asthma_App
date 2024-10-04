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

class PeakflowDeviceScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;
  final BluetoothDevice pefDevice;

  const PeakflowDeviceScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
    required this.pefDevice,
  });

  @override
  State<PeakflowDeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<PeakflowDeviceScreen> {
  int _counterValue = 0; // Counter value
  String _formattedTimestamp = 'Unknown'; // Timestamp value
  int _sensorReading = 0; // Cumulative button presses value
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

  String _formatTime(int value) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(value * 1000);
    return DateFormat('dd MMM, yyyy - hh mm a').format(dateTime);
  }

  void _connectAndReadValues() async {
    try {
      await widget.pefDevice.connect();
      logger.d("Connected to device: ${widget.pefDevice.platformName}");

      // Discover services
      List<BluetoothService> services =
          await widget.pefDevice.discoverServices();

      // Find Data Point Service
      _dataPointService = services.firstWhereOrNull(
        (service) =>
            service.uuid.toString() == '4cde0001-f90f-4962-8f2d-e1adc76edb6d',
      );

      if (_dataPointService != null) {
        await Future.wait([
          _readCharacteristic(_dataPointService!,
              '4cde0002-f90f-4962-8f2d-e1adc76edb6d', _updateCounterValue),
          _readCharacteristic(_dataPointService!,
              '4cde0003-f90f-4962-8f2d-e1adc76edb6d', _updateTimestampValue),
          _readCharacteristic(
              _dataPointService!,
              '4cde0004-f90f-4962-8f2d-e1adc76edb6d',
              _updateSensorReadingValue),
          _readCharacteristic(
              _dataPointService!,
              '4cde0005-f90f-4962-8f2d-e1adc76edb6d',
              _updateRequestDataIndexValue),
        ]);
      } else {
        logger.e("Data Point Service not found");
      }

      // Find Settings Service
      _settingsService = services.firstWhereOrNull(
        (service) =>
            service.uuid.toString() == '4cde0011-f90f-4962-8f2d-e1adc76edb6d',
      );

      if (_settingsService != null) {
        await Future.wait([
          _readRtcCharacteristic(_settingsService!),
          _readCharacteristic(_settingsService!,
              '4cde0013-f90f-4962-8f2d-e1adc76edb6d', _updateDeviceIdValue),
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

      setState(() {
        _formattedTimestamp = _formatTime(timestampValue);
      });
    } else {
      logger.e("Unexpected value length for Timestamp characteristic");
    }
  }

  void _updateSensorReadingValue(List<int> value) {
    if (value.length == 4) {
      int cumulativeButtonPresses = value[0] |
          (value[1] << 8) |
          (value[2] << 16) |
          (value[3] << 24); // Combine all 4 bytes
      logger.d("Cumulative Button Presses Value: $cumulativeButtonPresses");
      setState(() {
        _sensorReading = cumulativeButtonPresses;
      });
    } else {
      logger.e(
          "Unexpected value length for Cumulative Button Presses characteristic: ${value.length}");
    }
  }

  void _updateRequestDataIndexValue(List<int> value) {
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

  Future<void> _readRtcCharacteristic(BluetoothService settingsService) async {
    BluetoothCharacteristic? rtcCharacteristic =
        settingsService.characteristics.firstWhereOrNull(
      (c) => c.uuid.toString() == '4cde0012-f90f-4962-8f2d-e1adc76edb6d',
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

          setState(() {
            _formattedrtcTime = _formatTime(rtcTimeValue);
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
    widget.pefDevice.disconnect();
    logger.d("Disconnected from device: ${widget.pefDevice.platformName}");
    CustomSnackBarUtil.showCustomSnackBar(
        "Disconnected from device: ${widget.pefDevice.platformName}",
        success: false);
    Navigator.of(context).pop();
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
            'Peakflow Device',
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
        physics: const ClampingScrollPhysics(),
        child: Center(
          child: Container(
            width: screenSize.width,
            // height: screenSize.height,
            padding: EdgeInsets.all(screenSize.height * 0.01),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: screenSize.width,
                  height: screenRatio * 16,
                  child: Text(
                    widget.pefDevice.platformName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primaryBlueText,
                      fontSize: screenRatio * 9,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
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
                  label: 'Sensor Reading Value',
                  value: _sensorReading.toString(),
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
        ),
      ),
    );
  }
}
