import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:asthmaapp/utils/custom_snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import "descriptor_tile.dart";

class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;

  const CharacteristicTile(
      {Key? key, required this.characteristic, required this.descriptorTiles})
      : super(key: key);

  @override
  State<CharacteristicTile> createState() => _CharacteristicTileState();
}

class _CharacteristicTileState extends State<CharacteristicTile> {
  List<int> _value = [];

  late StreamSubscription<List<int>> _lastValueSubscription;

  @override
  void initState() {
    super.initState();
    _lastValueSubscription =
        widget.characteristic.lastValueStream.listen((value) {
      _value = value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _lastValueSubscription.cancel();
    super.dispose();
  }

  BluetoothCharacteristic get c => widget.characteristic;

  List<int> _getRandomBytes() {
    final math = Random();
    return [
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255)
    ];
  }

  Future onReadPressed() async {
    try {
      await c.read();
      CustomSnackBarUtil.showCustomSnackBar("Read: Success", success: true);
    } catch (e) {
      CustomSnackBarUtil.showCustomSnackBar("Read Error: $e", success: false);
    }
  }

  Future onWritePressed() async {
    try {
      await c.write(_getRandomBytes(),
          withoutResponse: c.properties.writeWithoutResponse);
      CustomSnackBarUtil.showCustomSnackBar("Write: Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
    } catch (e) {
      CustomSnackBarUtil.showCustomSnackBar("Write: Success", success: false);
    }
  }

  Future onSubscribePressed() async {
    try {
      String op = c.isNotifying == false ? "Subscribe" : "Unubscribe";
      await c.setNotifyValue(c.isNotifying == false);
      CustomSnackBarUtil.showCustomSnackBar("$op : Success", success: true);
      if (c.properties.read) {
        await c.read();
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      CustomSnackBarUtil.showCustomSnackBar("Subscribe Error: $e",
          success: false);
    }
  }

  Widget buildUuid(BuildContext context) {
    String uuid = '0x${widget.characteristic.uuid.str.toUpperCase()}';
    return Text(uuid, style: TextStyle(fontSize: 13));
  }

  Widget buildValue(BuildContext context) {
    if (_value.isEmpty) {
      return const Text("No data",
          style: TextStyle(fontSize: 13, color: Colors.grey));
    }

    try {
      // Debugging: Print the length of _value and its content
      print("Data length: ${_value.length}, Data content: $_value");

      if (_value.length == 2) {
        // Handle 2-byte unsigned integer
        int intValue = _value[0] | (_value[1] << 8);
        return Text("2-byte Integer Value: $intValue",
            style: const TextStyle(fontSize: 13, color: Colors.grey));
      } else if (_value.length == 4) {
        // Handle 4-byte data as two 2-byte unsigned integers
        int firstIntValue =
            _value[0] | (_value[1] << 8); // First 2-byte integer
        int secondIntValue =
            _value[2] | (_value[3] << 8); // Second 2-byte integer

        return Text(
          "First 2-byte Integer Value: $firstIntValue, Second 2-byte Integer Value: $secondIntValue",
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        );
      }

      // Default case for unsupported data types
      return Text("Unknown data format",
          style: const TextStyle(fontSize: 13, color: Colors.red));
    } catch (e) {
      return Text("Error processing data: $e",
          style: const TextStyle(fontSize: 13, color: Colors.red));
    }
  }

  Widget buildReadButton(BuildContext context) {
    return TextButton(
        child: Text("Read"),
        onPressed: () async {
          await onReadPressed();
          if (mounted) {
            setState(() {});
          }
        });
  }

  Widget buildWriteButton(BuildContext context) {
    bool withoutResp = widget.characteristic.properties.writeWithoutResponse;
    return TextButton(
        child: Text(withoutResp ? "WriteNoResp" : "Write"),
        onPressed: () async {
          await onWritePressed();
          if (mounted) {
            setState(() {});
          }
        });
  }

  Widget buildSubscribeButton(BuildContext context) {
    bool isNotifying = widget.characteristic.isNotifying;
    return TextButton(
        child: Text(isNotifying ? "Unsubscribe" : "Subscribe"),
        onPressed: () async {
          await onSubscribePressed();
          if (mounted) {
            setState(() {});
          }
        });
  }

  Widget buildButtonRow(BuildContext context) {
    bool read = widget.characteristic.properties.read;
    bool write = widget.characteristic.properties.write;
    bool notify = widget.characteristic.properties.notify;
    bool indicate = widget.characteristic.properties.indicate;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (read) buildReadButton(context),
        if (write) buildWriteButton(context),
        if (notify || indicate) buildSubscribeButton(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: ListTile(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Characteristic'),
            buildUuid(context),
            buildValue(context),
          ],
        ),
        subtitle: buildButtonRow(context),
        contentPadding: const EdgeInsets.all(0.0),
      ),
      children: widget.descriptorTiles,
    );
  }
}
