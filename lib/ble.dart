import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class  BTInfo {
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

abstract class BTWidget extends StatefulWidget {
  final BTInfo btInfo;

  const BTWidget(this.btInfo);
}

abstract class BTWidgetState extends State<BTWidget> {
  BTInfo btInfo;

  @override
  void initState() {
    super.initState();
    btInfo = widget.btInfo;
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

  startScan() {
    btInfo.scanResults = new Map();
    btInfo.scanSubscription = btInfo.flutterBlue
        .scan(
      timeout: const Duration(seconds: 5),
    )
        .listen((scanResult) {
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
    // Clear Services
    btInfo.services = new List();
    setState(() {
      btInfo.device = null;
    });
  }
}