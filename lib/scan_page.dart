import 'dart:async';
import 'package:flutter/material.dart';

import 'ble.dart';
import 'widgets.dart';

class ScanPage extends BTWidget {
  ScanPage(BTInfo btInfo) : super(btInfo);

  @override
  State<StatefulWidget> createState() => new _ScanPageState();
}

class _ScanPageState extends BTWidgetState {

  _buildScanResultTiles() {
    return btInfo.scanResults.values
        .map((r) => ScanResultTile(
          result: r,
          onConnectTap: () {
            stopScan();
            disconnect(); 
            connect(r.device);
          },
          onDisconnectTap: () => disconnect(),
          btInfo: btInfo,
        ))
        .toList();
  }

  Future<bool> _scan() async {
    // return true when done
    startScan();
    while (btInfo.isScanning) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    return true;
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
        RefreshIndicator(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(), 
            children: _buildScanResultTiles()
          ),
          onRefresh: _scan,
       )
      ],)
    );
  }
}