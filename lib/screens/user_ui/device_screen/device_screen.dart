import 'dart:async';
import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/screens/user_ui/device_screen/widgets/custom_device_button_widget.dart';
import 'package:asthmaapp/screens/user_ui/device_screen/widgets/custom_result_card_widget.dart';
import 'package:asthmaapp/screens/user_ui/widgets/custom_drawer.dart';
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
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  bool inhalerCap = false;
  bool pefDevice = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Cancel subscriptions when disposing of the state
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  void startScanning() {
    if (_isScanning) return; // Prevent starting a new scan if already scanning

    // Start scanning for devices
    _isScanning = true;
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4))
        .catchError((error) {
      // Handle any errors during scanning
      setState(() {
        _isScanning = false;
      });
      logger.e("Error starting scan: $error");
    });

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        _scanResults = results;
      });
    });

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
                'assets/svgs/user_assets/user_drawer_icon.svg', // Replace with your custom icon asset path
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
                              inhalerCap = !inhalerCap;
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
                              pefDevice = !pefDevice;
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
                            // Handle connection logic here
                            logger.d(
                                "Connecting to ${result.device.platformName}");
                            inhalerCap
                                ? Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/inhaler_cap_screen',
                                    (Route<dynamic> route) => true,
                                    arguments: {
                                      'realm': widget.realm,
                                      'deviceToken': widget.deviceToken,
                                      'deviceType': widget.deviceType,
                                      'inhalerDevice': result.device,
                                    },
                                  )
                                : Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/peakflow_device_screen',
                                    (Route<dynamic> route) => true,
                                    arguments: {
                                      'realm': widget.realm,
                                      'deviceToken': widget.deviceToken,
                                      'deviceType': widget.deviceType,
                                      'pefDevice': result.device,
                                    },
                                  );
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
