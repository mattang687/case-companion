// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:myapp/ble.dart';

class ScanResultTile extends StatefulWidget {
  ScanResultTile({Key key, @required this.result, 
    @required this.onConnectTap, @required this.onDisconnectTap, 
    @required btInfo}) : super(key: key);
  final ScanResult result;
  final VoidCallback onConnectTap;
  final VoidCallback onDisconnectTap;
  BTInfo btInfo;

  @override
  State<StatefulWidget> createState() {
    return ScanResultTileState(result, onConnectTap, onDisconnectTap, btInfo);
  }
}

class ScanResultTileState extends State<ScanResultTile> {
  ScanResultTileState(this.result, this.onConnectTap, 
    this.onDisconnectTap, this.btInfo);
  final ScanResult result;
  final VoidCallback onConnectTap;
  final VoidCallback onDisconnectTap;
  BTInfo btInfo;

  Widget _buildTitle(BuildContext context) {
    if (result.device.name.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(result.device.name),
          Text(
            result.device.id.toString(),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    } else {
      return Text(result.device.id.toString());
    }
  }

  Widget _buildButton() {
    if (result.device == btInfo.device) {
      return RaisedButton(
        child: Text("DISCONNECT"),
        color: Colors.red,
        textColor: Colors.white,
        onPressed: () => onDisconnectTap
      );
    } else {
      return RaisedButton(
        child: Text('CONNECT'),
        color: Colors.black,
        textColor: Colors.white,
        onPressed: () => (result.advertisementData.connectable) ? onConnectTap : null
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: _buildTitle(context),
      trailing: 
        Text("btInfo exists from scanResultTile:  ${btInfo != null}")
        // _buildButton()
    );
  }
}