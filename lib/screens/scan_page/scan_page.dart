import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/bluetooth/inherited_bluetooth.dart';
import 'package:provider/provider.dart';

import 'scan_page_widgets.dart';

class ScanPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  Widget connectedDeviceWidget = Container();

  List<Widget> _buildScanResultTiles() {
    final InheritedBluetooth inheritedBluetooth = Provider.of<InheritedBluetooth>(context);
    List<Widget> widgetList = new List<Widget>();
    widgetList.add(connectedDeviceWidget);
    widgetList.addAll(inheritedBluetooth.btInfo.scanResults.values
        .map((r) => ScanResultTile(
              result: r,
              onConnectTap: () => inheritedBluetooth.connect(r.device),
              onDisconnectTap: () => inheritedBluetooth.disconnect(),
            ))
        .toList());
    return widgetList;
  }

  void _buildConnectedDevice() {
    final InheritedBluetooth inheritedBluetooth = Provider.of<InheritedBluetooth>(context);
    if (inheritedBluetooth.btInfo.isConnected) {
      connectedDeviceWidget = ConnectedDeviceTile(
        onConnectTap: inheritedBluetooth.connect, 
        onDisconnectTap: inheritedBluetooth.disconnect,
      );
    } else {
      connectedDeviceWidget = Container();
    }
  }

  // return when done
  Future<void> _scan() async {
    final InheritedBluetooth inheritedBluetooth = Provider.of<InheritedBluetooth>(context);
    _buildConnectedDevice();
    inheritedBluetooth.startScan();
    while (inheritedBluetooth.btInfo.isScanning) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    final InheritedBluetooth inheritedBluetooth = Provider.of<InheritedBluetooth>(context);
    return WillPopScope(
      onWillPop: inheritedBluetooth.stopScan,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Connect to a device"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              inheritedBluetooth.stopScan();
              Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
          children: <Widget>[
            RefreshIndicator(
              child: inheritedBluetooth.btInfo.scanResults.length != 0
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: _buildScanResultTiles(),
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        child: Center(
                          child: !inheritedBluetooth.btInfo.isScanning
                              ? PullToScanWidget()
                              : Container(),
                        ),
                        height: MediaQuery.of(context).size.height -
                            kToolbarHeight -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom,
                      ),
                    ),
              onRefresh: _scan,
            ),
          ],
        ),
      ),
    );
  }
}
