import 'dart:async';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:asthmaapp/screens/user_ui/device_screen/widgets/custom_device_data_widget.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
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
  int _buttonPresses = 0; // Button presses value
  int _requestDataIndex = 0; // Request Data Index value

  BluetoothService? _dataPointService; // Variable to hold the Data Point Service

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
          _readCharacteristic(
              _dataPointService!,
              '4cde1526-f90f-4962-8f2d-e1adc76edb6d',
              _updateButtonPressesValue),
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

          logger.d("Listening for notifications on Button Presses characteristic");
        } catch (e) {
          logger.e("Error enabling notifications: $e");
        }
      } else {
        logger.e("Button Presses characteristic not found or does not support notifications");
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the button presses value
              Text(
                'Button Presses: $_buttonPresses',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),

              // Elevated Button to write to Request Data Index
              ElevatedButton(
                onPressed: () {
                  _writeRequestDataIndex(225);
                },
                child: const Text('Send Request Data Index'),
              ),
              SizedBox(height: 20),

              // Display the request data index value
              Text(
                'Request Data Index: $_requestDataIndex',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}