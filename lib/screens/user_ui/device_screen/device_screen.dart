import 'dart:async';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/models/user_model/user_model.dart';
import 'package:asthmaapp/screens/user_ui/device_screen/widgets/custom_device_button_widget.dart';
import 'package:asthmaapp/screens/user_ui/device_screen/widgets/custom_result_card_widget.dart';
import 'package:asthmaapp/screens/user_ui/widgets/custom_drawer.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:realm/realm.dart';

class DeviceScreen extends StatefulWidget {
  final Realm realm;
  final String? deviceToken, deviceType;

  const DeviceScreen({
    super.key,
    required this.realm,
    required this.deviceToken,
    required this.deviceType,
  });

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  UserModel? userModel;
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  bool inhalerCap = false;
  bool pefDevice = false;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    // Stop scanning and cancel subscriptions when disposing of the state
    stopScanning();
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  Future<void> startScanning() async {
    if (_isScanning) return; // Prevent starting a new scan if already scanning

    // Start scanning for devices
    _isScanning = true;
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 8));
    } catch (error) {
      // Handle any errors during scanning
      logger.e("Error starting scan: $error");
      setState(() {
        _isScanning = false;
      });
    }

    // Listen for scan results
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        _scanResults = results;

        // _scanResults = results
        //     .where((result) => result.device.platformName.contains("QIoT_CI"))
        //     .toList();
      });
      // if (_scanResults.isNotEmpty) {
      //   // Print a message when a "QIoT IntDr" device is found
      //   logger.d("Device found: ${_scanResults[0].device.platformName}");
      //   CustomSnackBarUtil.showCustomSnackBar(
      //       'Device found: ${_scanResults[0].device.platformName}',
      //       success: true);

      //   // Stop scanning immediately
      //   stopScanning();
      //   if (inhalerCap) {
      //     try {
      //       Navigator.pushNamedAndRemoveUntil(
      //         context,
      //         '/inhaler_cap_screen',
      //         (Route<dynamic> route) => true,
      //         arguments: {
      //           'realm': widget.realm,
      //           'deviceToken': widget.deviceToken,
      //           'deviceType': widget.deviceType,
      //           'inhalerDevice': _scanResults[0].device,
      //         },
      //       );
      //     } catch (error) {
      //       // Show a snackbar if an error occurs during navigation
      //       logger.e("Error navigating to inhaler cap screen: $error");
      //       CustomSnackBarUtil.showCustomSnackBar(
      //         'Failed to navigate to the inhaler cap screen. Please try again.',
      //         success: false,
      //       );
      //     }
      //   }
      // }
    });

    // Listen for scanning status
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((isScanning) {
      setState(() {
        _isScanning = isScanning;
      });
    });
  }

  void stopScanning() {
    // Stop scanning for devices
    FlutterBluePlus.stopScan().catchError((error) {
      logger.e("Error stopping scan: $error");
    });
    _isScanning = false;
  }

  void connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      // Once connected, discover services
      List<BluetoothService> services = await device.discoverServices();
      services.forEach((service) {
        print('Service: ${service.uuid}');
        // You can do something with the services here, e.g., update UI
      });

      // Navigate to the appropriate screen based on the device type
      if (inhalerCap) {
        try {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/inhaler_cap_screen',
            (Route<dynamic> route) => true,
            arguments: {
              'realm': widget.realm,
              'deviceToken': widget.deviceToken,
              'deviceType': widget.deviceType,
              'inhalerDevice': device,
            },
          );
        } catch (error) {
          // Show a snackbar if an error occurs during navigation
          logger.e("Error navigating to inhaler cap screen: $error");
          CustomSnackBarUtil.showCustomSnackBar(
            'Error navigating to inhaler cap screen: $error',
            success: false,
          );
        }
      } else if (pefDevice) {
        try {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/peakflow_device_screen',
            (Route<dynamic> route) => true,
            arguments: {
              'realm': widget.realm,
              'deviceToken': widget.deviceToken,
              'deviceType': widget.deviceType,
              'pefDevice': device,
            },
          );
        } catch (error) {
          // Show a snackbar if an error occurs during navigation
          logger.e("Error navigating to peakflow device screen: $error");
          CustomSnackBarUtil.showCustomSnackBar(
            'Error navigating to peakflow device screen: $error',
            success: false,
          );
        }
      }
    } catch (e) {
      logger.e("Error connecting to device: $e");
      // Show a message to the user about the error
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
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: SvgPicture.asset(
                'assets/svgs/user_assets/user_drawer_icon.svg',
                width: 24,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Devices',
            style: TextStyle(
              fontSize: screenRatio * 10,
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
        itemName: (String name) {
          logger.d(name);
        },
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Container(
              color: AppColors.primaryWhite,
              width: screenSize.width,
              padding: EdgeInsets.all(screenSize.width * 0.016),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenSize.width,
                    height: screenRatio * 16,
                    child: Text(
                      'Find your Device',
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
                  SizedBox(
                    width: screenSize.width,
                    height: screenSize.height * 0.06,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomDeviceButton(
                          screenSize: screenSize,
                          label: _isScanning ? 'Scanning' : 'Inhaler Cap',
                          isSelected: inhalerCap,
                          onTap: () {
                            setState(() {
                              inhalerCap = true;
                              pefDevice = false;
                            });
                            inhalerCap ? startScanning() : stopScanning();
                          },
                        ),
                        SizedBox(width: screenSize.width * 0.02),
                        CustomDeviceButton(
                          screenSize: screenSize,
                          label: _isScanning ? 'Scanning' : 'PEF Device',
                          isSelected: pefDevice,
                          onTap: () {
                            setState(() {
                              pefDevice = true;
                              inhalerCap = false;
                            });
                            pefDevice ? startScanning() : stopScanning();
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  if (_isScanning)
                    Center(
                      child: Container(
                        width: screenRatio * 32,
                        height: screenRatio * 32,
                        padding: EdgeInsets.all(screenRatio * 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryWhite.withOpacity(1.0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const CircularProgressIndicator(
                          backgroundColor: AppColors.primaryWhite,
                          color: AppColors.primaryBlue,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    ), // Show loading indicator while scanning
                  ..._scanResults
                      .where((result) => result.device.platformName.isNotEmpty)
                      .map(
                        (result) => CustomResultCard(
                          screenSize: screenSize,
                          result: result,
                          onTap: () {
                            // Connect to the selected device
                            logger.d(
                                "Connecting to ${result.device.platformName}");
                            connectToDevice(result.device);
                          },
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
