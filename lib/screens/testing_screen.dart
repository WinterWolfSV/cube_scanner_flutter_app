import 'dart:async';

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
                onPressed: () => bleScan(), child: Text('Start Scan')),
            ElevatedButton(
                onPressed: () => disconnectAllBleDevices(),
                child: Text("Disconnect All")),
          ],
        ),
      ),
    );
  }

  Future<void> disconnectAllBleDevices() async {
    await FlutterBluePlus.systemDevices
        .then((value) => value.forEach((element) {
              print("Disconnecting ${element.remoteId}");
              element.disconnect();
            }));
  }

  Future<void> bleScan() async {
    BluetoothDevice? device;
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: false);

    var subscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        if (results.isNotEmpty) {
          print("boop!");
          ScanResult r = results.last; // the most recently found device
          device = r.device;
          print(
              '${r.device.remoteId}: "${r.advertisementData.advName}" found!');
        }
      },
      onError: (e) => print(e),
    );

    await FlutterBluePlus.startScan(
        withServices: [targetService], timeout: const Duration(seconds: 5));
    FlutterBluePlus.cancelWhenScanComplete(subscription);
    for (int i = 0; i < 10; i++) {
      if (device != null) {
        print("Found device ${device!.remoteId}");
        await connectToBleDevice(device!);
        break;
      } else {
        print("Waiting for device");
        await Future.delayed(Duration(seconds: 1));
      }
    }
  }

  Future<void> connectToBleDevice(BluetoothDevice device) async {
    print("Connecting to ${device.remoteId}");
    await device.connect();
    List<BluetoothService> services = await device.discoverServices();
    print(services.length);
    services.forEach((service) {
      if (service.uuid == targetService) {
        sendToService(service);
      }
    });
    await Future.delayed(Duration(seconds: 1));
    await disconnectBleDevice(device);
  }

  Future<void> disconnectBleDevice(BluetoothDevice device) async {
    await device.disconnect();
  }

  Future<void> sendToService(BluetoothService service) async {
    List<BluetoothCharacteristic> characteristics = service.characteristics;
    characteristics.forEach((characteristic) {
      if (characteristic.uuid.toString() ==
          "2a05") {
        print("Found characteristic");
        print(characteristic.uuid);
        characteristic.write("Hello World!".codeUnits);
      }
    });
  }
}
