import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

abstract class BTWidget extends StatefulWidget {
  BTWidget(this.btInfo);
  BTInfo btInfo;
}

abstract class BTWidgetState extends State<BTWidget> {
  BTWidgetState(this.btInfo);
  BTInfo btInfo;

  @override
  void initState() {
    super.initState();
    // Immediately get the state of FlutterBlue
    btInfo.flutterBlue.state.then((s) {
      setState(() {
        btInfo.state = s;
      });
    });
    // Subscribe to state changes
    btInfo.stateSubscription = btInfo.flutterBlue.onStateChanged().listen((s) {
      setState(() {
        btInfo.state = s;
      });
    });
  }

  @override
  void dispose() {
    btInfo.stateSubscription?.cancel();
    btInfo.stateSubscription = null;
    btInfo.scanSubscription?.cancel();
    btInfo.scanSubscription = null;
    btInfo.deviceConnection?.cancel();
    btInfo.deviceConnection = null;
    super.dispose();
  }

  startScan() {
    btInfo.scanResults = new Map();
    btInfo.scanSubscription = btInfo.flutterBlue
        .scan(
      timeout: const Duration(seconds: 5),
      /*withServices: [
          new Guid('0000180F-0000-1000-8000-00805F9B34FB')
        ]*/
    )
        .listen((scanResult) {
      print('localName: ${scanResult.advertisementData.localName}');
      print(
          'manufacturerData: ${scanResult.advertisementData.manufacturerData}');
      print('serviceData: ${scanResult.advertisementData.serviceData}');
      setState(() {
        btInfo.scanResults[scanResult.device.id] = scanResult;
      });
    }, onDone: stopScan);

    setState(() {
      btInfo.isScanning = true;
    });
  }

  stopScan() {
    btInfo.scanSubscription?.cancel();
    btInfo.scanSubscription = null;
    setState(() {
      btInfo.isScanning = false;
    });
  }

  connect(BluetoothDevice d) async {
    btInfo.device = d;
    // Connect to device
    btInfo.deviceConnection = btInfo.flutterBlue
        .connect(btInfo.device, timeout: const Duration(seconds: 4))
        .listen(
          null,
          onDone: disconnect,
        );

    // Update the connection state immediately
    btInfo.device.state.then((s) {
      setState(() {
        btInfo.deviceState = s;
      });
    });

    // Subscribe to connection changes
    btInfo.deviceStateSubscription = btInfo.device.onStateChanged().listen((s) {
      setState(() {
        btInfo.deviceState = s;
      });
      if (s == BluetoothDeviceState.connected) {
        btInfo.device.discoverServices().then((s) {
          setState(() {
            btInfo.services = s;
          });
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
    setState(() {
      btInfo.device = null;
    });
  }
}

class  BTInfo {
  BTInfo() {
    flutterBlue = FlutterBlue.instance;
    scanResults = new Map();
    isScanning = false;
    state = BluetoothState.unknown;
    services = new List();
    valueChangedSubscriptions = {};
    deviceState = BluetoothDeviceState.disconnected;
  }
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
  bool get isConnected => (device != null);
  StreamSubscription deviceConnection;
  StreamSubscription deviceStateSubscription;
  List<BluetoothService> services;
  Map<Guid, StreamSubscription> valueChangedSubscriptions;
  BluetoothDeviceState deviceState;

  dispose() {
    scanSubscription.cancel();
    stateSubscription.cancel();
    deviceConnection.cancel();
    deviceStateSubscription.cancel();
  }
}