import 'package:flutter/material.dart';

class ScanRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _ScanRouteState();

}

class _ScanRouteState extends State<ScanRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connect to a Device")
      ),
      body: Text("scan results here")
    );
    // var tiles = new List<Widget>();
    //   if (state != BluetoothState.on) {
    //     tiles.add(_buildAlertTile());
    //   }
    //   if (isConnected) {
    //     tiles.add(_buildDeviceStateTile());
    //     tiles.addAll(_buildServiceTiles());
    //   } else {
    //     tiles.addAll(_buildScanResultTiles());
    //   }
    // return Scaffold(
    //   appBar: AppBar(
    //     leading: IconButton(
    //       icon: Icon(Icons.arrow_back),
    //       onPressed: () => Navigator.pop(context),
    //     ),
    //     title: Text("Connect to a Device"),
    //     actions: <Widget>[
    //       IconButton(
    //         icon: Icon(Icons.search),
    //         onPressed: () => _startScan(),
    //       )
    //     ],
    //   ),
    //   body: Stack(
    //     children: <Widget>[
    //       (isScanning) ? _buildProgressBarTile() : new Container(),
    //       ListView(
    //         children: tiles,
    //       )
    //     ],
    //   ),
    // );
  }
  
}