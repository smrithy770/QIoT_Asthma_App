import 'dart:async';
import 'dart:io';

import 'package:asthmaapp/constants/app_colors.dart';
import 'package:asthmaapp/screens/user_ui/device_screen/widgets/characteristic_tile.dart';
import 'package:asthmaapp/screens/user_ui/device_screen/widgets/descriptor_tile.dart';
import 'package:asthmaapp/screens/user_ui/device_screen/widgets/service_tile.dart';
import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:asthmaapp/utils/extra.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class InhalerCapScreen extends StatefulWidget {
  final BluetoothDevice device;

  const InhalerCapScreen({Key? key, required this.device}) : super(key: key);

  @override
  State<InhalerCapScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<InhalerCapScreen> {
  int? _rssi;
  int? _mtuSize;
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;
  List<BluetoothService> _services = [];
  bool _isDiscoveringServices = false;
  bool _isConnecting = false;
  bool _isDisconnecting = false;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;
  late StreamSubscription<bool> _isConnectingSubscription;
  late StreamSubscription<bool> _isDisconnectingSubscription;
  late StreamSubscription<int> _mtuSubscription;

  @override
  void initState() {
    super.initState();

    _connectionStateSubscription =
        widget.device.connectionState.listen((state) async {
      _connectionState = state;
      if (state == BluetoothConnectionState.connected) {
        _services = []; // must rediscover services
      }
      if (state == BluetoothConnectionState.connected && _rssi == null) {
        _rssi = await widget.device.readRssi();
      }
      if (mounted) {
        setState(() {});
      }
    });

    _mtuSubscription = widget.device.mtu.listen((value) {
      _mtuSize = value;
      if (mounted) {
        setState(() {});
      }
    });

    _isConnectingSubscription = widget.device.isConnecting.listen((value) {
      _isConnecting = value;
      if (mounted) {
        setState(() {});
      }
    });

    _isDisconnectingSubscription =
        widget.device.isDisconnecting.listen((value) {
      _isDisconnecting = value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    _mtuSubscription.cancel();
    _isConnectingSubscription.cancel();
    _isDisconnectingSubscription.cancel();
    super.dispose();
  }

  bool get isConnected {
    onDiscoverServicesPressed();
    return _connectionState == BluetoothConnectionState.connected;
  }

  Future<void> onConnectPressed() async {
    try {
      await widget.device.connectAndUpdateStream();
      CustomSnackBarUtil.showCustomSnackBar("Connect: Success", success: true);
    } catch (e) {
      if (e is FlutterBluePlusException &&
          e.code == FbpErrorCode.connectionCanceled.index) {
        // ignore connections canceled by the user
      } else {
        CustomSnackBarUtil.showCustomSnackBar("Connect Error: $e",
            success: false);
      }
    }
  }

  Future<void> onCancelPressed() async {
    try {
      await widget.device.disconnectAndUpdateStream(queue: false);
      CustomSnackBarUtil.showCustomSnackBar("Cancel: Success", success: true);
    } catch (e) {
      CustomSnackBarUtil.showCustomSnackBar("Cancel: Error", success: false);
    }
  }

  Future<void> onDisconnectPressed() async {
    try {
      await widget.device.disconnectAndUpdateStream();
      CustomSnackBarUtil.showCustomSnackBar("Disconnect: Success",
          success: true);
    } catch (e) {
      CustomSnackBarUtil.showCustomSnackBar("Disconnect Error: $e",
          success: false);
    }
  }

  Future<void> onDiscoverServicesPressed() async {
    if (mounted) {
      setState(() {
        _isDiscoveringServices = true;
      });
    }
    try {
      _services = await widget.device.discoverServices();
      print(
          "Services available: ${_services.length} ${_services.map((s) => s.uuid).toList()}");

      if (Platform.isAndroid && _services.length > 2) {
        // Skip the first two services for Android
        _services = _services.skip(2).toList();
        CustomSnackBarUtil.showCustomSnackBar(
            "Services discovered successfully, skipping first two.",
            success: true);
      } else {
        CustomSnackBarUtil.showCustomSnackBar(
            "Services discovered successfully",
            success: true);
      }

      // Enable notifications for all characteristics
      for (BluetoothService service in _services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          await characteristic.setNotifyValue(true);
        }
      }
    } catch (e) {
      CustomSnackBarUtil.showCustomSnackBar("Discover Services Error: $e",
          success: false);
    }

    if (mounted) {
      setState(() {
        _isDiscoveringServices = false;
      });
    }
  }

  List<Widget> _buildServiceTiles() {
    // Filter services to include only the one with the desired UUID
    final filteredServices = _services
        .where((s) =>
            s.uuid.toString().toLowerCase() ==
            '4cde1523-f90f-4962-8f2d-e1adc76edb6d'.toLowerCase())
        .toList();

    return filteredServices
        .map((s) => ServiceTile(
              service: s,
              characteristicTiles: s.characteristics
                  .map((c) => _buildCharacteristicTile(c))
                  .toList(),
            ))
        .toList();
  }

  CharacteristicTile _buildCharacteristicTile(BluetoothCharacteristic c) {
    return CharacteristicTile(
      characteristic: c,
      descriptorTiles:
          c.descriptors.map((d) => DescriptorTile(descriptor: d)).toList(),
    );
  }

  Widget buildSpinner() {
    return const Padding(
      padding: EdgeInsets.all(14.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: CircularProgressIndicator(
          backgroundColor: Colors.black12,
          color: Colors.black26,
        ),
      ),
    );
  }

  Widget buildRssiTile() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isConnected
            ? const Icon(Icons.bluetooth_connected)
            : const Icon(Icons.bluetooth_disabled),
        Text((isConnected && _rssi != null) ? '${_rssi!} dBm' : '',
            style: Theme.of(context).textTheme.bodySmall)
      ],
    );
  }

  Widget buildConnectButton() {
    return Row(children: [
      if (_isConnecting || _isDisconnecting) buildSpinner(),
      TextButton(
        onPressed: _isConnecting
            ? onCancelPressed
            : (isConnected ? onDisconnectPressed : onConnectPressed),
        child: Text(
          _isConnecting ? "CANCEL" : (isConnected ? "DISCONNECT" : "CONNECT"),
          style: Theme.of(context)
              .primaryTextTheme
              .labelLarge
              ?.copyWith(color: Colors.white),
        ),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return ScaffoldMessenger(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF004283),
          foregroundColor: const Color(0xFFFFFFFF),
          title: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Inhaler Cap',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto'),
            ),
          ),
          actions: [buildConnectButton()],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              width: screenSize.width,
              padding: EdgeInsets.all(screenSize.height * 0.01),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: screenSize.width,
                    height: screenSize.height * 0.024,
                    child: Text(
                      'Inhaler Cap is ${_connectionState.toString().split('.')[1]}.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  ..._buildServiceTiles(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
