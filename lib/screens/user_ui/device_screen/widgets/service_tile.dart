import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'characteristic_tile.dart';

class ServiceTile extends StatefulWidget {
  final BluetoothService service;
  final List<CharacteristicTile> characteristicTiles;

  const ServiceTile({
    Key? key,
    required this.service,
    required this.characteristicTiles,
  }) : super(key: key);

  @override
  _ServiceTileState createState() => _ServiceTileState();
}

class _ServiceTileState extends State<ServiceTile> {
  bool _isExpanded = true; // Start with the tile expanded

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Service', style: TextStyle(color: Colors.blue)),
          Text(
            'UUID: ${widget.service.uuid.toString().toUpperCase()}',
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
      children: widget.characteristicTiles,
      initiallyExpanded: _isExpanded, // Automatically expand
      onExpansionChanged: (bool expanding) {
        setState(() {
          _isExpanded = expanding;
        });
      },
    );
  }
}