import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothHandler {
  static final Guid targetService =
      Guid("0000FE07-0000-1000-8000-00805F9B34FC");
  static const String targetCharacteristic = "2a05";

  BluetoothDevice? device;
  BluetoothService? service;
  BluetoothCharacteristic? characteristic;

  BluetoothHandler() {
    bleScan();
  }

  bool isDeviceConnected() {
    return this.device != null;
  }

  bool isServiceConnected() {
    return this.service != null;
  }

  bool isCharacteristicConnected() {
    return this.characteristic != null;
  }

  Future<void> bleScan() async {
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: false);


    var subscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        if (results.isNotEmpty) {
          ScanResult r = results.last; // the most recently found device
          this.device = r.device;

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
      if (this.device != null) {
        print("Found device ${this.device!.remoteId}");

        await connectToBleDevice(this.device!);
        if (Platform.isAndroid) {
          await device!.requestMtu(512);
        }
        break;
      } else {
        print("Waiting for device");
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  Future<void> connectToBleDevice(BluetoothDevice? device) async {
    if (device == null) {
      bleScan();
      print("Device is null");
      return;
    }
    print("Connecting to ${device.remoteId}");
    await device.connect();
    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) {
      if (service.uuid == targetService) {
        this.service = service;
        getCharacteristics(service);
      }
    });
    await Future.delayed(Duration(seconds: 5));
    await disconnectBleDevice(device);
  }

  Future<void> disconnectBleDevice(BluetoothDevice device) async {
    await device.disconnect();
  }

  Future<void> getCharacteristics(BluetoothService? localService) async {
    if (localService == null) {
      connectToBleDevice(this.device);
      print("Service is null");
      return;
    }
    List<BluetoothCharacteristic> characteristics =
        localService.characteristics;
    characteristics.forEach((characteristic) {
      if (characteristic.uuid.toString() == targetCharacteristic) {
        this.characteristic = characteristic;
      }
    });
  }

  Future<void> sendToDevice(String data) async {
    while(!isCharacteristicConnected()){
      print("Establishing connection to device...");
      await Future.delayed(const Duration(seconds: 1));
    }
    for(int i = 0; i < 10; i++){
      if(isCharacteristicConnected()){
        break;
      }
      print("Establishing connection to device...");
      await Future.delayed(const Duration(seconds: 1));
    }

    print("Sending to device now...");
    // await this.characteristic!.write(data.codeUnits);
    List<String> dataSplit = data.trim().split(" ");
    dataSplit.add("|");
    for(int i = 0; i < dataSplit.length; i++){
      await this.characteristic!.write(dataSplit[i].codeUnits);
      // await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}
