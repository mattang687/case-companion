import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'ble.dart';
import 'main.dart';
import 'widgets.dart';

/*
  This is where the user scans for and connects to BLE devices.
  When entering this route, a BT scan is immediately started.
  Afterwards, the user can pull down to start another scan. As
  the scan detects devices, it will list them out. Each list item
  will have a connect button, which will turn into a red disconnect
  button when connected.
*/
class ScanRoute extends BTWidget {
  ScanRoute(BTInfo btInfo) : super(btInfo);

  @override
  State<StatefulWidget> createState() => new _ScanRouteState();
}

class _ScanRouteState extends BTWidgetState {

  _buildScanResultTiles() {
    return btInfo.scanResults.values
        .map((r) => ScanResultTile(
          result: r,
          onConnectTap: () {
            disconnect(); 
            connect(r.device);
          },
          onDisconnectTap: () => disconnect(),
          btInfo: btInfo,
        ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connect to a device"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              startScan();
            }
          ),
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              disconnect();
            }
          ),
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              stopScan();
            }
          )
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            stopScan();
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(children: <Widget>[
        (btInfo.isScanning) ? LinearProgressIndicator() : Container(),
        ListView(children: _buildScanResultTiles())
      ],)
    );
  }
}