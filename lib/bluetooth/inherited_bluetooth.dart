import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // return true to satisfy WillPopScope on HomePage
  Future<bool> disconnect() async {
    List<BluetoothDevice> devices = await flutterBlue.connectedDevices;
    if (devices.length != 0) {
      await devices[0].disconnect();
    }
    device = null;
    notifyListeners();
    return true;
  }

  // attempts to read the temperature
  // returns true if successful
  Future<bool> _parseTemp(BluetoothCharacteristic c) async {
    List<int> readResult;

    try {
      readResult = await c.read();
    } on PlatformException {
      // PlatformException indicates that a read was performed while another was in
      // progress. Do nothing and return false
      return false;
    }

    // add up the bytes
    int sum = readResult[1] * 256 + readResult[0];
    if (readResult[1] > 127) {
      // negative, find two's complement
      temp = -(65536 - sum) / 100;
    } else {
      temp = sum / 100;
    }
    return true;
  }

  // attempts to read the humidity
  // returns true if successful
  Future<bool> _parseHum(BluetoothCharacteristic c) async {
    List<int> readResult;

    try {
      readResult = await c.read();
    } on PlatformException {
      // PlatformException indicates that a read was performed while another was in
      // progress. Do nothing and return false
      return false;
    }

    // add up the bytes
    int sum = readResult[1] * 256 + readResult[0];
    hum = sum ~/ 100;
    return true;
  }

  // attempts to read the battery level
  // returns true if successful
  Future<bool> _parseBat(BluetoothCharacteristic c) async {
    List<int> readResult;

    try {
      readResult = await c.read();
    } on PlatformException {
      // PlatformException indicates that a read was performed while another was in
      // progress. Do nothing and return false
      return false;
    }

    bat = readResult[0];
    return true;
  }

  // reads all characteristics and returns true if temp and hum reads were successful
  // other functions will use the result to determine whether to save the data or not
  // and battery level is not relevant to the data stored in the database
  Future<bool> readAll() async {
    List<BluetoothDevice> devices = await flutterBlue.connectedDevices;
    bool tempSuccess;
    bool humSuccess;
    if (devices.length != 0) {
      List<BluetoothService> services = await devices[0].discoverServices();
      for (BluetoothService s in services) {
        if (s.uuid == Guid("0000181A-0000-1000-8000-00805F9B34FB")) {
          // environmental sensing service
          for (BluetoothCharacteristic c in s.characteristics) {
            if (c.uuid == Guid("00002A6E-0000-1000-8000-00805F9B34FB")) {
              tempSuccess = await _parseTemp(c);
            }
            if (c.uuid == Guid("00002A6F-0000-1000-8000-00805F9B34FB")) {
              humSuccess = await _parseHum(c);
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
    return tempSuccess && humSuccess;
  }
}
