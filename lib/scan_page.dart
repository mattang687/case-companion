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

  Widget connectedDeviceWidget = Container();

  @override
  initState() {
    super.initState();
    _buildConnectedDevice();
    btInfo.scanResults = new Map();
  }

  List<Widget> _buildScanResultTiles() {
    List<Widget> widgetList = new List<Widget>();
    widgetList.add(connectedDeviceWidget);
    widgetList.addAll(btInfo.scanResults.values
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
      .toList()
    );
    return widgetList;
  }

  void _buildConnectedDevice() {
    if (btInfo.isConnected) {
      connectedDeviceWidget = ConnectedDeviceTile(
        onConnectTap: connect,
        onDisconnectTap: disconnect,
        btInfo: btInfo
      );
    } else {
      connectedDeviceWidget = Container();
    }
  }

  Future<bool> _scan() async {
    // return true when done
    _buildConnectedDevice();
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
          child: btInfo.scanResults.length != 0 ? ListView(
            physics: const AlwaysScrollableScrollPhysics(), 
            children: _buildScanResultTiles()
          ) : SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                child: Center(
                  child: !btInfo.isScanning ? PullToScanWidget() : Container()
                  ),
                height: MediaQuery.of(context).size.height - kToolbarHeight
              ),
          ),
          onRefresh: _scan,
       ),
      ],)
    );
  }
}