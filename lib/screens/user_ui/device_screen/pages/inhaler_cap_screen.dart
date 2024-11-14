import 'dart:async';
import 'dart:io';
import 'package:asthmaapp/api/inhaler_api.dart';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:asthmaapp/screens/user_ui/device_screen/widgets/custom_device_data_widget.dart';
import 'package:asthmaapp/services/permission_service.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
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
  Map<String, dynamic> inhalerReportData = {};
  int _buttonPresses = 0;
  String _formattedrtcTime = 'Unknown'; // RTC Time value
  String _deviceId = ''; // Device ID value
  int _requestDataIndex = 0;
  int _dataIndex = 0;
  List<int> buttonPressesList = [];
  List<String> timestampList = [];
  List<int> processedList = [];
  BluetoothService? _dataPointService;
  BluetoothService? _settingsService;
  StreamSubscription<List<int>>? _buttonPressesSubscription;
  final PermissionService _permissionService =
      PermissionService(); // Create an instance of PermissionService
  Position? _currentPosition;
  Timer? _dataRequestTimer;
  String _formattedTimestamp = 'Unknown'; // Timestamp value
  bool _reconnect = true;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _connectAndReadValues();
    _loadUserData();
    getInhalerData(DateTime.now().month, DateTime.now().year);
    Future.delayed(const Duration(seconds: 2), () {
      _loopThroughAndSaveButtonPresses();
    });
  }

  Future<void> _requestPermissions() async {
    await _permissionService.locationPermission();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );
      // Store the location data
      setState(() {
        _currentPosition = position;
      });
      // Use the location data (latitude, longitude)
      logger.d('Current Location: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      // Handle location retrieval error
      CustomSnackBarUtil.showCustomSnackBar('Error retrieving location: $e',
          success: false);
    }
  }

  Future<void> _loadUserData() async {
    final user = getUserData(widget.realm);
    if (user != null && mounted) {
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

  Future<void> getInhalerData(int currentMonth, int currentYear) async {
    try {
      final jsonResponse = await InhalerApi().getInhalerHistory(
        userModel!.userId,
        currentMonth,
        currentYear,
        userModel!.accessToken,
      );
      final status = jsonResponse['status'];
      if (status == 200 && mounted) {
        final payload = jsonResponse['payload'];
        setState(() {
          inhalerReportData = payload;
          _dataIndex = inhalerReportData['inhaler']
              [inhalerReportData['inhaler'].length - 1]['dataIndex'];
        });
        logger.d('Inhaler data index: $_dataIndex');
      }
    } on SocketException catch (e) {
      logger.e('NetworkException: $e');
    } on Exception catch (e) {
      logger.e('Failed to fetch data: $e');
    }
  }

  void _submitInhaler(List<int> processedList) async {
    if (userModel == null) return;

    // Ensure location data is available
    if (_currentPosition == null) {
      CustomSnackBarUtil.showCustomSnackBar(
        'Unable to get location. Please enable location services.',
        success: false,
      );
      return;
    }

    try {
      for (int i = 0; i < processedList.length; i++) {
        // Get the button press value from processedList
        int inhalerValue = processedList[i];
        String createdAt = timestampList[i];

        // Parse the createdAt timestamp in custom format
        DateFormat format = DateFormat("dd MMM, yyyy - hh mm a");
        DateTime createdAtDateTime = format.parse(createdAt);

        logger.d('Created At: $createdAtDateTime');

        // Compute the corresponding dataIndex
        int dataIndex = _dataIndex + i + 1;

        // Send the API request for each button press
        final response = await InhalerApi().addInhaler(
          userModel!.userId,
          _deviceId
              .toString(), // You can update this if you need to pass any specific value
          dataIndex, // Send the computed dataIndex here
          inhalerValue, // Send the button press value
          {
            'type': 'Point',
            'coordinates': [
              _currentPosition!.longitude,
              _currentPosition!.latitude
            ],
          },
          DateTime.now().month,
          DateTime.now().year,
          createdAtDateTime,
          userModel!.accessToken,
        );

        final jsonResponse = response;
        final status = jsonResponse['status'];

        if (status == 201) {
          logger.d('Timestamp: $timestampList');
          CustomSnackBarUtil.showCustomSnackBar(
            "Inhaler data added successfully for all data indices",
            success: true,
          );
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
          'An error occurred while adding inhaler data',
          success: false);
    }
  }

  Future<void> _connectAndReadValues() async {
    try {
      await widget.inhalerDevice.connect();
      logger.d("Connected to device: ${widget.inhalerDevice.platformName}");

      List<BluetoothService> services =
          await widget.inhalerDevice.discoverServices();

      _dataPointService = services.firstWhereOrNull(
        (service) =>
            service.uuid.toString() == '4cde1523-f90f-4962-8f2d-e1adc76edb6d',
      );

      if (_dataPointService != null) {
        await Future.wait([
          _readCharacteristic(
              _dataPointService!,
              '4cde1527-f90f-4962-8f2d-e1adc76edb6d',
              _updateRequestDataIndexValue),
        ]);

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
          await characteristic.setNotifyValue(true);
          // Save the subscription
          _buttonPressesSubscription =
              characteristic.lastValueStream.listen((value) {
            if (mounted) {
              _updateButtonPressesValue(value);
            }
          });
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

    if (characteristic != null && characteristic.properties.read) {
      try {
        List<int> value = await characteristic.read();
        if (mounted) {
          updateValue(value);
        }
      } catch (e) {
        logger.e("Error reading characteristic $characteristicUuid: $e");
      }
    } else {
      logger.e("Characteristic $characteristicUuid not found or not readable");
    }
  }

  void _updateRequestDataIndexValue(List<int> value) {
    logger.d("Raw Request Data Index Value: $value");
    if (value.length == 4) {
      int requestDataIndex = value[0] | (value[1] << 8);
      logger.d("Request Data Index Value: $requestDataIndex");
      if (mounted) {
        setState(() {
          _requestDataIndex = requestDataIndex;
        });
      }
    } else {
      logger.e(
          "Unexpected value length for Request Data Index characteristic: ${value.length}");
    }
  }

  void _updateButtonPressesValue(List<int> value) {
    if (value.length == 4) {
      int buttonPresses = value[0];
      if (mounted) {
        setState(() {
          _buttonPresses = buttonPresses;
          buttonPressesList.add(buttonPresses); // Add to list
        });
      }
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

      if (mounted) {
        setState(() {
          _formattedTimestamp = formattedDate;
          timestampList.add(_formattedTimestamp); // Add to list
        });
      }
    }
  }

  Future<void> _loopThroughAndSaveButtonPresses() async {
    // Clear the list before fetching new button presses
    buttonPressesList.clear();

    // Log current indices for debugging purposes
    logger
        .d("Starting data request loop from $_dataIndex to $_requestDataIndex");

    // Loop from _dataIndex to _requestDataIndex
    for (int i = _dataIndex + 1; i <= _requestDataIndex; i++) {
      logger.d("Requesting data for index: $i");

      // Write the current index to the device to fetch the corresponding button press
      await _writeRequestDataIndex(i);

      // Short delay between requests to avoid overloading the device
      await Future.delayed(const Duration(milliseconds: 50));

      // Optionally, log the size of buttonPressesList to track progress
      logger.d("Button presses list size: ${buttonPressesList.length}");
    }
    List<int> processedList = [];
    for (int i = 0; i < buttonPressesList.length; i += 2) {
      processedList.add(buttonPressesList[i]);
    }

    _dataRequestTimer = Timer(const Duration(seconds: 2), () {
      _submitInhaler(processedList);
    });

    logger.d("Button presses saved: $processedList");
  }

  Future<void> _writeRequestDataIndex(int index) async {
    if (_dataPointService != null) {
      BluetoothCharacteristic? characteristic =
          _dataPointService!.characteristics.firstWhereOrNull(
        (c) => c.uuid.toString() == '4cde1527-f90f-4962-8f2d-e1adc76edb6d',
      );

      if (characteristic != null && characteristic.properties.write) {
        List<int> bytes = [
          index & 0xFF, // Low byte
          (index >> 8) & 0xFF, // High byte
        ];

        try {
          await characteristic.write(bytes);
          await Future.wait([
            _readCharacteristic(
                _dataPointService!,
                '4cde1526-f90f-4962-8f2d-e1adc76edb6d',
                _updateButtonPressesValue),
            _readCharacteristic(_dataPointService!,
                '4cde1525-f90f-4962-8f2d-e1adc76edb6d', _updateTimestampValue),
          ]);
        } catch (e) {
          logger.e("Error writing to Request Data Index characteristic: $e");
        }
      }
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

  void _updateDeviceIdValue(List<int> value) {
    if (value.length == 4) {
      // Combine the bytes to form the deviceId, assuming 4 bytes
      int deviceId =
          value[0] | (value[1] << 8) | (value[2] << 16) | (value[3] << 24);

      // Convert to hexadecimal string
      String hexDeviceId =
          deviceId.toRadixString(16).padLeft(8, '0').toUpperCase();

      logger.d("Device ID (Hex): $hexDeviceId");

      setState(() {
        // Optionally store the hexDeviceId instead of the integer deviceId
        _deviceId = hexDeviceId;
      });
    } else {
      logger.e(
          "Unexpected value length for Device ID characteristic: ${value.length}");
    }
  }

  void _disconnectDevice() {
    widget.inhalerDevice.disconnect();
    logger.d("Disconnected from device: ${widget.inhalerDevice.platformName}");
    // Start attempting to reconnect immediately
    _attemptReconnect();
  }

  void _attemptReconnect() async {
    while (_reconnect) {
      try {
        logger.d("Attempting to reconnect...");
        await widget.inhalerDevice.connect();
        logger.d("Reconnected to device: ${widget.inhalerDevice.platformName}");

        // If successful, break the loop and read values
        await _connectAndReadValues();

        // Fetch inhaler data again after reconnecting
        getInhalerData(DateTime.now().month, DateTime.now().year);
        break; // Exit the loop after a successful connection
      } catch (e) {
        logger.e("Reconnection failed: $e");
        await Future.delayed(
            const Duration(seconds: 5)); // Wait before retrying
      }
    }
  }

  @override
  void dispose() {
    // Cancel the subscription and disconnect the device
    _buttonPressesSubscription?.cancel();
    widget.inhalerDevice.disconnect();

    _dataRequestTimer?.cancel();
    super.dispose();
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
            // Perform any necessary cleanup
            setState(() {
              _reconnect = false;
            });
            _buttonPressesSubscription?.cancel();
            widget.inhalerDevice.disconnect();
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
        child: Center(
          child: Container(
            width: screenSize.width,
            padding: EdgeInsets.all(screenRatio * 6),
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
                    'Your Device Data',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primaryBlueText,
                      fontSize: screenRatio * 9,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.016),
                CustomDeviceData(
                  label: 'Recent compression count',
                  value: _buttonPresses.toString(),
                  screenRatio: screenRatio,
                ),
                SizedBox(height: screenSize.height * 0.016),
                SvgPicture.asset(
                  'assets/svgs/user_assets/peakflow.svg',
                  width: screenRatio * 64,
                ),
                SizedBox(height: screenSize.height * 0.016),
                CustomDeviceData(
                  label: 'Recorded at',
                  value: _formattedrtcTime.toString(),
                  screenRatio: screenRatio,
                ),
                SizedBox(height: screenSize.height * 0.016),
                CustomDeviceData(
                  label: 'From device ID',
                  value: _deviceId.toString(),
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
