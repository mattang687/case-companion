import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/services.dart';

import 'bluetooth_info.dart';

class InheritedBluetooth with ChangeNotifier {
  final BTInfo btInfo = new BTInfo();

  startScan() {
    btInfo.scanResults = new Map();
    btInfo.scanSubscription = btInfo.flutterBlue
        .scan(
      timeout: const Duration(seconds: 5),
    )
        .listen((scanResult) {
      btInfo.scanResults[scanResult.device.id] = scanResult;
      notifyListeners();
    }, onDone: stopScan);

    btInfo.isScanning = true;
    notifyListeners();
  }

  Future<bool> stopScan() async {
    // return true to satisfy WillPopScope widget
    btInfo.scanSubscription?.cancel();
    btInfo.scanSubscription = null;
    btInfo.isScanning = false;
    notifyListeners();
    return true;
  }

  connect(BluetoothDevice d) async {
    stopScan();
    disconnect();
    btInfo.device = d;
    btInfo.previousDevice = d;
    // Connect to device
    btInfo.deviceConnection = btInfo.flutterBlue
        .connect(btInfo.device, timeout: const Duration(seconds: 4))
        .listen(
          null,
          onDone: disconnect,
        );

    // Update the connection state immediately
    btInfo.device.state.then((s) {
      btInfo.deviceState = s;
      notifyListeners();
    });

    // Subscribe to connection changes
    btInfo.deviceStateSubscription = btInfo.device.onStateChanged().listen((s) {
      btInfo.deviceState = s;
      notifyListeners();
      if (s == BluetoothDeviceState.connected) {
        btInfo.device.discoverServices().then((s) {
          btInfo.services = s;
          notifyListeners();
        });
      }
    });
  }

  disconnect() {
    // Remove all value changed listeners
    btInfo.valueChangedSubscriptions.forEach((uuid, sub) => sub.cancel());
    btInfo.valueChangedSubscriptions.clear();
    btInfo.deviceStateSubscription?.cancel();
    btInfo.deviceStateSubscription = null;
    btInfo.deviceConnection?.cancel();
    btInfo.deviceConnection = null;
    // Clear Services
    btInfo.services = new List();
    btInfo.device = null;
    notifyListeners();
  }

  dispose() {
    btInfo.stateSubscription?.cancel();
    btInfo.stateSubscription = null;
    btInfo.scanSubscription?.cancel();
    btInfo.scanSubscription = null;
    btInfo.deviceConnection?.cancel();
    btInfo.deviceConnection = null;
    super.dispose();
  }

  Future<List<int>> _repeatedRead(BluetoothCharacteristic c) async {
    try {
      return await btInfo.device.readCharacteristic(c);
    } on PlatformException {
      return Future.delayed(
          Duration(milliseconds: 200), () async => await _repeatedRead(c));
    }
  }

  Future<double> readTemp() async {
    if (!btInfo.isConnected) {
      return 0;
    }
    // Base UUID: 00000000-0000-1000-8000-00805F9B34FB
    // two bytes, most significant last, two's complement for negative numbers
    BluetoothCharacteristic cTemp = BluetoothCharacteristic(
      descriptors: <BluetoothDescriptor>[],
      properties: null,
      serviceUuid: new Guid("0000181A-0000-1000-8000-00805F9B34FB"),
      uuid: new Guid("00002A6E-0000-1000-8000-00805F9B34FB"),
    );

    List<int> ret = await _repeatedRead(cTemp);
    double tgt;
    int sum = ret[1] * 256 + ret[0];
    if (ret[1] > 127) {
      // negative, find two's complement
      tgt = -(65536 - sum) / 100;
    } else {
      tgt = sum / 100;
    }
    return tgt;
  }

  Future<int> readHum() async {
    if (!btInfo.isConnected) {
      return 0;
    }
    // Base UUID: 00000000-0000-1000-8000-00805F9B34FB
    // two bytes, most significant last, unsigned
    BluetoothCharacteristic cHum = BluetoothCharacteristic(
      descriptors: <BluetoothDescriptor>[],
      properties: null,
      serviceUuid: new Guid("0000181A-0000-1000-8000-00805F9B34FB"),
      uuid: new Guid("00002A6F-0000-1000-8000-00805F9B34FB"),
    );

    List<int> ret = await _repeatedRead(cHum);
    int sum = ret[1] * 256 + ret[0];
    return sum ~/ 100;
  }

  Future<int> readBat() async {
    if (!btInfo.isConnected) {
      return 0;
    }
    // Base UUID: 00000000-0000-1000-8000-00805F9B34FB
    // one byte, unsigned
    BluetoothCharacteristic cBat = BluetoothCharacteristic(
      descriptors: <BluetoothDescriptor>[],
      properties: null,
      serviceUuid: new Guid("0000180F-0000-1000-8000-00805F9B34FB"),
      uuid: new Guid("00002A19-0000-1000-8000-00805F9B34FB"),
    );

    List<int> ret = await _repeatedRead(cBat);
    return ret[0];
  }
}