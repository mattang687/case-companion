import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/services.dart';

import 'bluetooth_info.dart';

// handles all interaction with BLE
class InheritedBluetooth with ChangeNotifier {
  final BTInfo btInfo = new BTInfo();
  double temp;
  int hum;
  int bat;

  void startScan() {
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
    // return true to satisfy WillPopScope widget in ScanPage
    btInfo.scanSubscription?.cancel();
    btInfo.scanSubscription = null;
    btInfo.isScanning = false;
    notifyListeners();
    return true;
  }

  void connect(BluetoothDevice d) async {
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

  void disconnect() {
    // Remove all value changed listeners
    btInfo.valueChangedSubscriptions.forEach((uuid, sub) => sub.cancel());
    btInfo.valueChangedSubscriptions.clear();
    btInfo.deviceStateSubscription?.cancel();
    btInfo.deviceStateSubscription = null;
    btInfo.deviceConnection?.cancel();
    btInfo.deviceConnection = null;
    // Clear services
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

  // if the read fails because the device isn't ready, try again
  Future<List<int>> _repeatedRead(BluetoothCharacteristic c) async {
    try {
      return await btInfo.device.readCharacteristic(c);
    } on PlatformException {
      return Future.delayed(
          Duration(milliseconds: 200), () async => await _repeatedRead(c));
    }
  }

  Future<void> _readTemp() async {
    if (!btInfo.isConnected) {
      temp = 0;
      notifyListeners();
      return;
    }
    // Base UUID: 00000000-0000-1000-8000-00805F9B34FB
    // data is stored in two bytes, most significant last
    // two's complement for negative numbers
    BluetoothCharacteristic cTemp = BluetoothCharacteristic(
      descriptors: <BluetoothDescriptor>[],
      properties: null,
      serviceUuid: new Guid("0000181A-0000-1000-8000-00805F9B34FB"),
      uuid: new Guid("00002A6E-0000-1000-8000-00805F9B34FB"),
    );

    List<int> ret = await _repeatedRead(cTemp);

    // add up the bytes
    double tgt;
    int sum = ret[1] * 256 + ret[0];
    if (ret[1] > 127) {
      // negative, find two's complement
      tgt = -(65536 - sum) / 100;
    } else {
      tgt = sum / 100;
    }
    temp = tgt;
    notifyListeners();
    return;
  }

  Future<void> _readHum() async {
    if (!btInfo.isConnected) {
      hum = 0;
      notifyListeners();
      return;
    }
    // Base UUID: 00000000-0000-1000-8000-00805F9B34FB
    // data is stored in two bytes, most significant last, unsigned
    BluetoothCharacteristic cHum = BluetoothCharacteristic(
      descriptors: <BluetoothDescriptor>[],
      properties: null,
      serviceUuid: new Guid("0000181A-0000-1000-8000-00805F9B34FB"),
      uuid: new Guid("00002A6F-0000-1000-8000-00805F9B34FB"),
    );

    List<int> ret = await _repeatedRead(cHum);

    // add up the bytes
    int sum = ret[1] * 256 + ret[0];
    hum = sum ~/ 100;
    notifyListeners();
    return;
  }

  Future<void> _readBat() async {
    if (!btInfo.isConnected) {
      bat = 0;
      notifyListeners();
      return;
    }
    // Base UUID: 00000000-0000-1000-8000-00805F9B34FB
    // data is stored in one byte, unsigned
    BluetoothCharacteristic cBat = BluetoothCharacteristic(
      descriptors: <BluetoothDescriptor>[],
      properties: null,
      serviceUuid: new Guid("0000180F-0000-1000-8000-00805F9B34FB"),
      uuid: new Guid("00002A19-0000-1000-8000-00805F9B34FB"),
    );

    List<int> ret = await _repeatedRead(cBat);
    bat = ret[0];
    notifyListeners();
    return;
  }

  Future<void> refresh() async {
    await _readTemp();
    await _readHum();
    await _readBat();
  }
}
