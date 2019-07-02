import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';

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