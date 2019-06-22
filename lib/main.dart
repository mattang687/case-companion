import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:myapp/widgets.dart';
import 'package:flutter/services.dart';

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
  State<StatefulWidget> createState() => new _CaseCompanionAppState();
}

class _CaseCompanionAppState extends BTWidgetState {
  _CaseCompanionAppState() : super();

  bool inCelsius = true;
  bool isUpdating = false;
  int temp;
  int hum;
  int bat;

  @override
  initState() {
    super.initState();
    _updateData();
  }

  _updateData() async {
    Future<List<int>> _repeatedRead(BluetoothCharacteristic c) async {
      try {
        return await btInfo.device.readCharacteristic(c);
      } on PlatformException {
        return Future.delayed(Duration(milliseconds: 200), 
          () async => await _repeatedRead(c));
      }
    }

    Future<int> _readTemp() async {
      // Base UUID: 00000000-0000-1000-8000-00805F9B34FB
      // two bytes, most significant last, two's complement for negative numbers
      BluetoothCharacteristic cTemp = BluetoothCharacteristic(
        descriptors: <BluetoothDescriptor>[], 
        properties: null, 
        serviceUuid: new Guid("0000181A-0000-1000-8000-00805F9B34FB"), 
        uuid: new Guid("00002A6E-0000-1000-8000-00805F9B34FB")
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
      return tgt.round();
    }
    // if (inCelsius) {
    //   return tgt.round();
    // } else {
    //   return (tgt * 9 / 5 + 32).round();
    // }

    Future<int> _readHum() async {
      // Base UUID: 00000000-0000-1000-8000-00805F9B34FB
      // two bytes, most significant last, unsigned
      BluetoothCharacteristic cHum = BluetoothCharacteristic(
        descriptors: <BluetoothDescriptor>[], 
        properties: null, 
        serviceUuid: new Guid("0000181A-0000-1000-8000-00805F9B34FB"), 
        uuid: new Guid("00002A6F-0000-1000-8000-00805F9B34FB")
      );

      List<int> ret = await _repeatedRead(cHum);
      int sum = ret[1] * 256 + ret[0];
      return sum ~/ 100;
    }

    Future<int> _readBat() async {
      // Base UUID: 00000000-0000-1000-8000-00805F9B34FB
      // one byte, unsigned
      BluetoothCharacteristic cBat = BluetoothCharacteristic(
        descriptors: <BluetoothDescriptor>[], 
        properties: null, 
        serviceUuid: new Guid("0000180F-0000-1000-8000-00805F9B34FB"), 
        uuid: new Guid("00002A19-0000-1000-8000-00805F9B34FB")
      );

      List<int> ret = await _repeatedRead(cBat);
      return ret[0];
    }

    if (btInfo.isConnected) {
      temp = await _readTemp();
      hum = await _readHum();
      bat = await _readBat();
    }
    
    setState(() => isUpdating = false);
  }

  Widget buildTemp() {
    if (!btInfo.isConnected) {
      return Icon(Icons.bluetooth_disabled);
    }
    if (isUpdating) {
      return Icon(Icons.bluetooth_searching);
    }
    return new TempWidget(temp);
  }

  Widget buildHum() {
    if (!btInfo.isConnected) {
      return Icon(Icons.bluetooth_disabled);
    }
    if (isUpdating) {
      return Icon(Icons.bluetooth_searching);
    }
    return HumWidget(hum);
  }

  Widget buildBat() {
    if (!btInfo.isConnected) {
      return Icon(Icons.bluetooth_disabled);
    }
    if (isUpdating) {
      return Icon(Icons.bluetooth_searching);
    }
    return BatWidget(bat);
  }

  Widget buildUpdateButton() {
    return IconButton(
      icon: Icon(Icons.refresh),
      onPressed: () {
        setState(() => isUpdating = true);
        _updateData();
      }
    );
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
      body: Center(child: Column(
        children: <Widget>[
          buildUpdateButton(),
          Row(children: <Widget>[
            buildTemp(),
            Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
            buildHum()
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 10)),
          buildBat(),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      )
    ));
  }
}