import 'dart:async';
import 'dart:convert';
import 'dart:math';

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
      return Text("No data",
          style: TextStyle(fontSize: 13, color: Colors.grey));
    }

    // Convert the list of int (bytes) to a string
    String jsonString = utf8.decode(_value);
    print("Received JSON String: $jsonString");

    try {
      // Decode the JSON string
      List<dynamic> jsonList = jsonDecode(jsonString);

      // Assuming the first element contains the temperature and humidity data
      if (jsonList.isNotEmpty) {
        Map<String, dynamic> json = jsonList[0];

        // Extract the temperature and humidity
        String temperature = (json['t'] / 10).toString();
        String humidity = (json['h'] / 10).toString();

        return Column(
          children: [
            Text(temperature,
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            Text(humidity,
                style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        );
      } else {
        return Text("No data",
            style: TextStyle(fontSize: 13, color: Colors.grey));
      }
    } catch (e) {
      print("Error decoding JSON: $e");
      return Text("Error decoding data",
          style: TextStyle(fontSize: 13, color: Colors.red));
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
