import 'dart:async';

import 'package:cube_scanner/screens/logic/bluetooth_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

Guid targetService = Guid("0000FE07-0000-1000-8000-00805F9B34FC");

class BleDeviceScreen extends StatefulWidget {
  @override
  _BleDeviceScreenState createState() => _BleDeviceScreenState();
}

class _BleDeviceScreenState extends State<BleDeviceScreen> {
  String processUuid = "YOUR_PROCESS_UUID";

  @override
  void initState() {
    super.initState();
    initializeBle();
  }

  Future<void> initializeBle() async {
    // Request location permissions if needed
    // bleScan();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: const Text('BLE Device Scan')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('BLE Device Scan'),
            ElevatedButton(
                onPressed: () => sendToDevice("Hello world!"), child: Text('Send to device')),
          ],
        ),
      ),
    );
  }
  Future<void> sendToDevice(String message) async {
    BluetoothHandler ble = BluetoothHandler();
    while (!ble.isCharacteristicConnected()) {
      await Future.delayed(const Duration(seconds: 1));
    }
    await ble.sendToDevice(message);
  }
}
