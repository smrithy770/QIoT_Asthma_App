import 'dart:async';

import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/main.dart';
import 'package:asthmaapp/screens/user_ui/device_screen/pages/inhaler_cap_screen.dart';
import 'package:asthmaapp/screens/user_ui/device_screen/pages/pef_device_screen.dart';
import 'package:asthmaapp/screens/user_ui/widgets/custom_drawer.dart';
import 'package:asthmaapp/screens/user_ui/device_screen/widgets/scan_result_tile.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:asthmaapp/utils/extra.dart';
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
  List<BluetoothDevice> _systemDevices = [];
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
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  //Scan for Inhaler Cap
  Future<void> onInhalerPressed() async {
    setState(() {
      inhalerCap = true;
      pefDevice = false;
    });
    try {
      _systemDevices = await FlutterBluePlus.systemDevices;
    } catch (e) {
      CustomSnackBarUtil.showCustomSnackBar("System Devices Error: $e",
          success: false);
    }
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
        if (mounted) {
          setState(() {
            _scanResults = results
                .where((result) => result.advertisementData.advName.isNotEmpty)
                .toList();
          });
        }
      }, onError: (e) {
        CustomSnackBarUtil.showCustomSnackBar("Scan Error: $e", success: false);
      });

      _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
        if (mounted) {
          setState(() {
            _isScanning = state;
          });
        }
      });
    } catch (e) {
      CustomSnackBarUtil.showCustomSnackBar("Start Scan Error: $e",
          success: false);
    }
  }

  //Scan for PEF Device
  Future<void> onPEFPressed() async {
    setState(() {
      inhalerCap = false;
      pefDevice = true;
    });
    try {
      _systemDevices = await FlutterBluePlus.systemDevices;
    } catch (e) {
      CustomSnackBarUtil.showCustomSnackBar("System Devices Error: $e",
          success: false);
    }
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
        if (mounted) {
          setState(() {
            _scanResults = results
                .where((result) => result.advertisementData.advName.isNotEmpty)
                .toList();
          });
        }
      }, onError: (e) {
        CustomSnackBarUtil.showCustomSnackBar("Scan Error: $e", success: false);
      });

      _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
        if (mounted) {
          setState(() {
            _isScanning = state;
          });
        }
      });
    } catch (e) {
      CustomSnackBarUtil.showCustomSnackBar("Start Scan Error: $e",
          success: false);
    }
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .map(
          (r) => ScanResultTile(
            result: r,
            onTap: () {
              onConnectPressed(r.device);
            },
          ),
        )
        .toList();
  }

  Future onStopPressed() async {
    // setState(() {
    //   inhalerCap = false;
    //   pefDevice = false;
    // });
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      CustomSnackBarUtil.showCustomSnackBar("Stop Scan Error: $e",
          success: false);
    }
  }

  void onConnectPressed(BluetoothDevice device) {
    device.connectAndUpdateStream().catchError((e) {
      CustomSnackBarUtil.showCustomSnackBar("Connect Error: $e",
          success: false);
    });

    CustomSnackBarUtil.showCustomSnackBar("Connected", success: true);
    inhalerCap == true && pefDevice == false
        ? Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InhalerCapScreen(device: device),
            ),
          )
        : Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PEFDeviceScreen(device: device),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

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
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Devices',
            style: TextStyle(
              fontSize: 24,
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
        onItemSelected: (int index) {
          logger.d(index);
        },
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const ClampingScrollPhysics(),
        child: Center(
          child: Container(
            width: screenSize.width,
            height: screenSize.height,
            padding: EdgeInsets.all(screenSize.width * 0.016),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SizedBox(
                //   width: screenSize.width,
                //   height: screenSize.height * 0.024,
                //   child: const Text(
                //     'Device',
                //     textAlign: TextAlign.center,
                //     style: TextStyle(
                //       color: Color(0xFF004283),
                //       fontSize: 24,
                //       fontWeight: FontWeight.bold,
                //       fontFamily: 'Roboto',
                //     ),
                //   ),
                // ),
                // SizedBox(height: screenSize.height * 0.016),
                SizedBox(
                  width: screenSize.width,
                  height: screenSize.height * 0.024,
                  child: const Text(
                    'Find your Device',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF004283),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.016),
                SizedBox(
                  width: screenSize.width,
                  height: screenSize.height * 0.08,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: FlutterBluePlus.isScanningNow && inhalerCap
                              ? onStopPressed
                              : onInhalerPressed, // Start scanning on button press
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(screenSize.width * 0.5,
                                screenSize.height * 0.08),
                            foregroundColor: const Color(0xFF004283),
                            backgroundColor: const Color(0xFFFFFFFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: const BorderSide(
                                color: Color(0xFF004283), width: 2),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                          ),
                          child: Text(
                            FlutterBluePlus.isScanningNow && inhalerCap
                                ? 'Stop Scanning'
                                : 'Inhaler Cap',
                            style: const TextStyle(
                              color: Color(0xFF004283),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenSize.width * 0.02),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: FlutterBluePlus.isScanningNow && pefDevice
                              ? onStopPressed
                              : onPEFPressed,
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(screenSize.width * 0.5,
                                screenSize.height * 0.08),
                            foregroundColor: const Color(0xFF004283),
                            backgroundColor: const Color(0xFFFFFFFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            side: const BorderSide(
                                color: Color(0xFF004283), width: 2),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                          ),
                          child: Text(
                            FlutterBluePlus.isScanningNow && pefDevice
                                ? 'Stop Scanning'
                                : 'PEF Device',
                            style: const TextStyle(
                              color: Color(0xFF004283),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenSize.height * 0.016),
                _isScanning
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF004283),
                        ),
                      )
                    : Expanded(
                        child: ListView(
                          children: <Widget>[
                            ..._buildScanResultTiles(context),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
