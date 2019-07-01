import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

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
}

class BTInfo {
  FlutterBlue flutterBlue;

  /// Scanning
  StreamSubscription scanSubscription;
  Map<DeviceIdentifier, ScanResult> scanResults;
  bool isScanning;

  /// State
  StreamSubscription stateSubscription;
  BluetoothState state;

  /// Device
  BluetoothDevice device;
  BluetoothDevice previousDevice;
  bool get isConnected => (device != null);
  StreamSubscription deviceConnection;
  StreamSubscription deviceStateSubscription;
  List<BluetoothService> services;
  Map<Guid, StreamSubscription> valueChangedSubscriptions;
  BluetoothDeviceState deviceState;

  BTInfo() {
    flutterBlue = FlutterBlue.instance;
    scanResults = new Map();
    isScanning = false;
    state = BluetoothState.unknown;
    services = new List();
    valueChangedSubscriptions = {};
    deviceState = BluetoothDeviceState.disconnected;
  }

  dispose() {
    scanSubscription.cancel();
    stateSubscription.cancel();
    deviceConnection.cancel();
    deviceStateSubscription.cancel();
  }
}