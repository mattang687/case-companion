import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:myapp/widgets.dart';

import 'ScanRoute.dart';
import 'ble.dart';

void main() {
  runApp(MaterialApp(
    title: "Case Companion", 
    home: CaseCompanionApp(new BTInfo()),
  ));
}

/*
  This is the main screen of the app. The user will be able to read data from
  the temperature, humidity, and battery characteristics, and they will be shown
  in the upper half of the screen. A button in the top right will allow the user
  to go to the scanning page, where he can connect to a device, which will be
  passed back here.

  Hopefully, a graph showing fluctuations over time will be implemented.

  Things to do:
  Read data
    Requires real-time access to the device and its services
    Must be able to send read requests to the device
  Auto connect
    Must be able to scan and connect to the last connected device if the app is
    closed. Scan in the background of the main route.
  Everything related to Bluetooth has to be separate from the UI. Pass around
  the Bluetooth state
  Pretty layout
*/
class CaseCompanionApp extends BTWidget {
  CaseCompanionApp(BTInfo btInfo) : super(btInfo);

  @override
  State<StatefulWidget> createState() => new _CaseCompanionAppState(btInfo);
}

class _CaseCompanionAppState extends BTWidgetState {
  _CaseCompanionAppState(BTInfo btInfo) : super(btInfo);

  _readCharacteristic(BluetoothCharacteristic c) async {
    await btInfo.device.readCharacteristic(c);
    setState(() {});
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

  Widget _buildDebug () {
    return Center(child: Column(children: <Widget>[
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () => setState(() {}),
        ),
        Text("device: ${btInfo.device != null ? btInfo.device.name : "device is null"}"),
        Text("btInfo exists: ${btInfo != null}"),
        Text("isConnected: ${btInfo.isConnected}"),
        Text("FlutterBlue instance exists: ${btInfo.flutterBlue != null}"),
        Text("scanResults exists: ${btInfo.scanResults != null}"),
        Text("isScanning: ${btInfo.isScanning}"),
        Text("state: ${btInfo.state.toString()}"),
        Text("stateSubscription exists: ${btInfo.stateSubscription != null}"),
        Text("numServices: ${btInfo.services == null ? "services is null": btInfo.services.length}"), 
        Text("deviceState: ${btInfo.deviceState.toString()}"),
        Text("scanSubscription exists: ${btInfo.scanSubscription != null}"),
        Text("deviceConnection exists: ${btInfo.deviceConnection != null}"),
        Text("deviceStateSubscription exists: ${btInfo.deviceStateSubscription != null}"),
        Text("valueChangedSubscriptions exists: ${btInfo.valueChangedSubscriptions != null}"),
      ],));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Case Companion"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScanRoute(btInfo)),
              );
            },
          )
        ],
      ),
      body: _buildDebug()
    );
  }
}