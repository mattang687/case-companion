import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/bluetooth/inherited_bluetooth.dart';
import 'package:provider/provider.dart';

import 'scan_page_widgets.dart';

// where the user scans for / connects to / disconnects from BLE devices
class ScanPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  Widget connectedDeviceWidget = Container();

  // if a device is connected, it will not advertise, so show a tile for the current device
  // allows the user to disconnect from a device after navigating away from the scan page
  void _buildConnectedDevice() {
    final InheritedBluetooth inheritedBluetooth =
        Provider.of<InheritedBluetooth>(context);
    setState(() {
      if (inheritedBluetooth.isConnected()) {
        connectedDeviceWidget = ConnectedDeviceTile(
          onConnectTap: inheritedBluetooth.connect,
          onDisconnectTap: inheritedBluetooth.disconnect,
        );
      } else {
        connectedDeviceWidget = Container();
      } 
    });
  }

  Future<void> _scan() async {
    final InheritedBluetooth inheritedBluetooth =
        Provider.of<InheritedBluetooth>(context);
    // only build connected device on scan because old ScanResultTile
    // will remain from previous scan results
    _buildConnectedDevice();

    // returns when done to stop the refresh animation
    return inheritedBluetooth.startScan();
  }

  @override
  Widget build(BuildContext context) {
    final InheritedBluetooth inheritedBluetooth =
        Provider.of<InheritedBluetooth>(context);
    return WillPopScope(
      onWillPop: inheritedBluetooth.stopScan,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Connect to a Device"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              inheritedBluetooth.stopScan();
              Navigator.pop(context);
            },
          ),
        ),
        body: RefreshIndicator(
          child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        connectedDeviceWidget,
                        ScanResults(),
                      ],
                    ),
                    height: MediaQuery.of(context).size.height -
                        kToolbarHeight -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                ),
          onRefresh: _scan,
        ),
      ),
    );
  }
}
