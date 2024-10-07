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

  int _deviceId = 0; // Device ID value

  BluetoothService?
      _dataPointService; // Variable to hold the Data Point Service

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
            service.uuid.toString() == '4cde1530-f90f-4962-8f2d-e1adc76edb6d',
      );

      if (_dataPointService != null) {
        // Log available characteristics to debug
        _logAvailableCharacteristics(_dataPointService!);

        await Future.wait([
          _readCharacteristic(_dataPointService!,
              '4cde1532-f90f-4962-8f2d-e1adc76edb6d', _updateDeviceIdValue),
        ]);
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

  Future<void> _readCharacteristic(BluetoothService service,
      String characteristicUuid, Function(List<int>) updateValue) async {
    BluetoothCharacteristic? characteristic =
        service.characteristics.firstWhereOrNull(
      (c) => c.uuid.toString() == characteristicUuid,
    );

    if (characteristic != null) {
      logger.d("Found characteristic: $characteristic");
      if (characteristic.properties.read) {
        try {
          List<int> value = await characteristic.read();
          updateValue(value);
        } catch (e) {
          logger.e("Error reading characteristic $characteristicUuid: $e");
        }
      } else {
        logger.e("Characteristic $characteristicUuid not readable");
      }
    } else {
      logger.e("Characteristic $characteristicUuid not found");
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

  void _logAvailableCharacteristics(BluetoothService service) {
    service.characteristics.forEach((characteristic) {
      logger.d('Available characteristic UUID: ${characteristic.uuid}');
    });
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
        physics: const ClampingScrollPhysics(),
        child: Center(
          child: Container(
            width: screenSize.width,
            padding: EdgeInsets.all(screenSize.height * 0.01),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenSize.height * 0.01),
                SizedBox(
                  width: screenSize.width,
                  height: screenRatio * 16,
                  child: Text(
                    widget.inhalerDevice.platformName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primaryBlueText,
                      fontSize: screenRatio * 9,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.01),
                CustomDeviceData(
                  label: 'Device ID',
                  value: _deviceId.toString(),
                  screenRatio: screenRatio,
                ),
                SizedBox(height: screenSize.height * 0.01),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
