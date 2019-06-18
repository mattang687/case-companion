import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:myapp/main.dart';

import 'widgets.dart';

class ScanRoute extends StatefulWidget {
  BluetoothInfo info;

  ScanRoute(this.info);

  @override
  State<StatefulWidget> createState() => new _ScanRouteState(info);

}

class _ScanRouteState extends State<ScanRoute> {

  /// Scanning
  StreamSubscription _scanSubscription;
  Map<DeviceIdentifier, ScanResult> scanResults = new Map();
  bool isScanning = false;

  _ScanRouteState(this.info);
  BluetoothInfo info;

  @override
  void dispose() {
    info.stateSubscription?.cancel();
    info.stateSubscription = null;
    _scanSubscription?.cancel();
    _scanSubscription = null;
    info.deviceConnection?.cancel();
    info.deviceConnection = null;
    super.dispose();
  }

  _connect(BluetoothDevice d) async {
    info.device = d;
    // Connect to device
    info.deviceConnection = info.flutterBlue
        .connect(info.device, timeout: const Duration(seconds: 4))
        .listen(
          null,
          onDone: _disconnect,
        );

    // Update the connection state immediately
    info.device.state.then((s) {
      setState(() {
        info.deviceState = s;
      });
    });

    // Subscribe to connection changes
    info.deviceStateSubscription = info.device.onStateChanged().listen((s) {
      setState(() {
        info.deviceState = s;
      });
      if (s == BluetoothDeviceState.connected) {
        info.device.discoverServices().then((s) {
          setState(() {
            info.services = s;
          });
        });
      }
    });
  }

  _disconnect() {
    // Remove all value changed listeners
    info.valueChangedSubscriptions.forEach((uuid, sub) => sub.cancel());
    info.valueChangedSubscriptions.clear();
    info.deviceStateSubscription?.cancel();
    info.deviceStateSubscription = null;
    info.deviceConnection?.cancel();
    info.deviceConnection = null;
    setState(() {
      info.device = null;
    });
  }

  _buildScanResultTiles() {
    return scanResults.values
        .map((r) => ScanResultTile(
              result: r,
              onTap: () => _connect(r.device),
            ))
        .toList();
  }

  _startScan() {
    _scanSubscription = info.flutterBlue
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
        scanResults[scanResult.device.id] = scanResult;
      });
    }, onDone: _stopScan);

    setState(() {
      isScanning = true;
    });
  }

  _stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    setState(() {
      isScanning = false;
    });
  }

  _buildProgressBarTile() {
    return new LinearProgressIndicator();
  }

  @override
  Widget build(BuildContext context) {
    var tiles = new List<Widget>();
    tiles.addAll(_buildScanResultTiles());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Connect to a Device"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _startScan(),
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          (isScanning) ? _buildProgressBarTile() : new Container(),
          ListView(
            children: tiles,
          )
        ],
      ),
    );
  }
}