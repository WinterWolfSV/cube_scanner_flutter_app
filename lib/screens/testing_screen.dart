import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleDeviceScreen extends StatefulWidget {
  @override
  _BleDeviceScreenState createState() => _BleDeviceScreenState();
}

class _BleDeviceScreenState extends State<BleDeviceScreen> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> _subscription;
  DiscoveredDevice? _devices = null;
  String uuid = "00001802-0000-1000-8000-00805F9B34FB";
  String otherUuid = "00002A05-0000-1000-8000-00805F9B34FB";

  @override
  void initState() {
    super.initState();
    print("initState");
  }

  @override
  void dispose() {
    _subscription.cancel();
    _ble.deinitialize();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BLE Devices'),
      ),
      body: ElevatedButton(
        onPressed: _startScanning,
        child: Text('Scan'),
      ),
    );
  }

  void _startScanning() {
    _ble.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    ).listen(
          (device) async {
        _handleScannedDevice(device);
      },
      onError: (dynamic error) {
        print('Error: $error');
        // Code for handling scan error
      },
    );
  }

  void disconnectDevice() async {

  }

  void _handleScannedDevice(DiscoveredDevice device) async {
    if (device.serviceUuids.isNotEmpty &&
        device.serviceUuids[0].toString() ==
            "0000fe07-0000-1000-8000-00805f9b34fc") {
      print("Device name: ${device.name}");
      print("Device service names: ${device.serviceUuids[0]}");
      _connectToDevice(device);
    }
    // Code for handling results
  }

  void _connectToDevice(DiscoveredDevice device) {
    StreamSubscription<ConnectionStateUpdate> _connectedDeviceStream;

    _connectedDeviceStream = _ble.connectToDevice(id: device.id).listen(
          (connectionState) async {
        print("Connection state: ${connectionState}");
        if (connectionState.connectionState ==
            DeviceConnectionState.connected) {
          print("Connected to device");
          await _writeToCharacteristic(device);
        } else {
          print("Not connected to device");
        }
      },
      onError: (dynamic error) {
        print('Error: $error');
        // Code for handling connection error
      },
    );

    print(_connectedDeviceStream.runtimeType);

    // Wait for 5 seconds and cancel the connection stream
    // Future.delayed(Duration(seconds: 5), () {
    //   print("Cancelling stream");
    //   _connectedDeviceStream.cancel();
    // });
  }

  Future<void> _writeToCharacteristic(DiscoveredDevice device) async {
    String data = "Hello World";
    final characteristic = QualifiedCharacteristic(
      serviceId: device.serviceUuids[0],
      deviceId: device.id,
      characteristicId: Uuid.parse("00002A05-0000-1000-8000-00805F9B34FB"),
    );
    await _ble.writeCharacteristicWithResponse(characteristic, value: data.codeUnits);
  }

}

class BleDeviceDetailsScreen extends StatelessWidget {
  final DiscoveredDevice device;

  BleDeviceDetailsScreen(this.device);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Device Name: ${device.name ?? 'Unknown'}'),
            Text('Device ID: ${device.id}'),
            ElevatedButton(
              onPressed: () {
                // Implement connection logic here
                // You may want to use flutter_reactive_ble to connect to the device
              },
              child: Text('Connect'),
            ),
          ],
        ),
      ),
    );
  }
}
