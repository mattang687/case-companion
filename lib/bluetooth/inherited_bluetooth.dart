import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

// handles all interaction with BLE
class InheritedBluetooth with ChangeNotifier {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice device;
  BluetoothDevice previousDevice;
  List<BluetoothService> services;
  double temp;
  int hum;
  int bat;

  bool isScanning;

  bool isConnected() => device != null;

  Future<void> startScan() async {
    isScanning = true;
    await flutterBlue.startScan(
      timeout: Duration(seconds: 4), 
    );
    isScanning = false;
    return;
  }

  // return true when done to pop scope on scan page
  Future<bool> stopScan() async {
    isScanning = false;
    await flutterBlue.stopScan();
    return true;
  }

  Future<void> connect(BluetoothDevice d) async {
    if (isScanning) {
      stopScan();
    }
    try {
      await d.connect(timeout: Duration(seconds: 4));
    } on TimeoutException {
      return;
    }
    device = (await flutterBlue.connectedDevices)[0];
    previousDevice = device;
    notifyListeners();
    return;
  }

  Future<void> disconnect() async {
    List<BluetoothDevice> devices = await flutterBlue.connectedDevices;
    if (devices.length != 0) {
      await devices[0].disconnect();
    }
    device = null;
    notifyListeners();
    return;
  }

  Future<void> _parseTemp(BluetoothCharacteristic c) async {
    List<int> ret = await c.read();

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
    return;
  }

  Future<void> _parseHum(BluetoothCharacteristic c) async {
    List<int> ret = await c.read();

    // add up the bytes
    int sum = ret[1] * 256 + ret[0];
    hum = sum ~/ 100;
    return;
  }

  Future<void> _parseBat(BluetoothCharacteristic c) async {
    List<int> ret = await c.read();
    bat = ret[0];
    return;
  }

  Future<void> readAll() async {
    List<BluetoothDevice> devices = await flutterBlue.connectedDevices;
    if (devices.length != 0) {
      List<BluetoothService> services = await devices[0].discoverServices();
      for (BluetoothService s in services) {
        if (s.uuid == Guid("0000181A-0000-1000-8000-00805F9B34FB")) {
          // environmental sensing service
          for (BluetoothCharacteristic c in s.characteristics) {
            if (c.uuid == Guid("00002A6E-0000-1000-8000-00805F9B34FB")) {
              await _parseTemp(c);
            }
            if (c.uuid == Guid("00002A6F-0000-1000-8000-00805F9B34FB")) {
              await _parseHum(c);
            }
          }
        }
        if (s.uuid == Guid("0000180F-0000-1000-8000-00805F9B34FB")) {
          // battery service
          for (BluetoothCharacteristic c in s.characteristics) {
            if (c.uuid == Guid("00002A19-0000-1000-8000-00805F9B34FB")) {
              await _parseBat(c);
            }
          }
        }
      }
    }
    notifyListeners();
    return;
  }
}
