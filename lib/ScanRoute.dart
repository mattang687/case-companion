import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:myapp/main.dart';

import 'widgets.dart';

/*
  This is where the user scans for and connects to BLE devices.
  When entering this screen, a BT scan is immediately started.
  Afterwards, the user can pull down to start another scan. As
  the scan detects devices, it will list them out. Each list item
  will have a connect button, which will turn into a red disconnect
  button when connected.
*/
class ScanRoute extends StatefulWidget {
  
  @override
  State<StatefulWidget> createState() => new _ScanRouteState();

}

class _ScanRouteState extends State<ScanRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connect to a device"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // start scan
            },
          ),
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              // disconnect
            },
          )
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text("Scan results go here")
      )
    );
  }
}