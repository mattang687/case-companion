// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:myapp/widgets.dart';

import 'ScanRoute.dart';

void main() {
  runApp(MaterialApp(
    title: "nav", 
    home: FlutterBlueApp(),
  ));
}

class FlutterBlueApp extends StatefulWidget {
  FlutterBlueApp({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _FlutterBlueAppState createState() => new _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  FlutterBlue _flutterBlue = FlutterBlue.instance;

  /// State
  StreamSubscription _stateSubscription;
  BluetoothState state = BluetoothState.unknown;

  /// Device
  BluetoothDevice device;
  bool get isConnected => (device != null);
  StreamSubscription deviceConnection;
  StreamSubscription deviceStateSubscription;
  List<BluetoothService> services = new List();
  Map<Guid, StreamSubscription> valueChangedSubscriptions = {};
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;

  @override
  void initState() {
    super.initState();
    // Immediately get the state of FlutterBlue
    _flutterBlue.state.then((s) {
      setState(() {
        state = s;
      });
    });
    // Subscribe to state changes
    _stateSubscription = _flutterBlue.onStateChanged().listen((s) {
      setState(() {
        state = s;
      });
    });
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _scanSubscription?.cancel();
    _scanSubscription = null;
    deviceConnection?.cancel();
    deviceConnection = null;
    super.dispose();
  }

  _readCharacteristic(BluetoothCharacteristic c) async {
    _parseRead(c, await device.readCharacteristic(c));
    setState(() {});
  }

  _parseRead(BluetoothCharacteristic c, List<int> dataList) {
    // battery value is exactly the single value in the list
    // humidity and temperature are doubles, where the most significant byte is second, and the least is first
    // temp uses two's complement for negative numbers, so check the most significant bit for sign
    // check service uuid, and do math if it matches one of the above
    Guid batGuid = new Guid("00002A19-0000-1000-8000-00805F9B34FB");
    Guid tempGuid = new Guid("00002A6E-0000-1000-8000-00805F9B34FB");
    Guid humGuid = new Guid("00002A6F-0000-1000-8000-00805F9B34FB");
    if (c.uuid == batGuid) {
      return dataList[0];
    } else if (c.uuid == tempGuid) {
      if (dataList[1] >= 128) {
        // negative - find two's complement
        int nonInverted = dataList[1] * 256 + dataList[0];
        return nonInverted - 65536;
      } else {
        return dataList[1] * 256 + dataList[0];
      }
    } else if (c.uuid == humGuid) {

    } else {
      return dataList;
    }
  }

  _refreshDeviceState(BluetoothDevice d) async {
    var state = await d.state;
    setState(() {
      deviceState = state;
      print('State refreshed: $deviceState');
    });
  }

  // List<Widget> _buildServiceTiles() {
  //   return services
  //       .map(
  //         (s) => new ServiceTile(
  //               service: s,
  //               characteristicTiles: s.characteristics
  //                   .map(
  //                     (c) => new CharacteristicTile(
  //                           characteristic: c,
  //                           onReadPressed: () => _readCharacteristic(c),
  //                           onWritePressed: () => _writeCharacteristic(c),
  //                           onNotificationPressed: () => _setNotification(c),
  //                           descriptorTiles: c.descriptors
  //                               .map(
  //                                 (d) => new DescriptorTile(
  //                                       descriptor: d,
  //                                       onReadPressed: () => _readDescriptor(d),
  //                                       onWritePressed: () =>
  //                                           _writeDescriptor(d),
  //                                     ),
  //                               )
  //                               .toList(),
  //                         ),
  //                   )
  //                   .toList(),
  //             ),
  //       )
  //       .toList();
  // }

  _buildDeviceStateTile() {
    return new ListTile(
        leading: (deviceState == BluetoothDeviceState.connected)
            ? const Icon(Icons.bluetooth_connected)
            : const Icon(Icons.bluetooth_disabled),
        title: new Text('Device is ${deviceState.toString().split('.')[1]}.'),
        subtitle: new Text('${device.id}'),
        trailing: new IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _refreshDeviceState(device),
          color: Theme.of(context).iconTheme.color.withOpacity(0.5),
        ));
  }

  _buildScanButton() {
    if (state != BluetoothState.on) {
      return  <Widget>[new Container()];
    } else {
      return <Widget>[
        new IconButton(
          icon: const Icon(Icons.search), 
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ScanRoute()));
          },
        )
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: const Text('FlutterBlue'),
          actions: _buildScanButton(),
        ),
        body: new Text("display temp hum and graph here")
      );
  }
}

// class FirstRoute extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('First Route'),
//       ),
//       body: Center(
//         child: RaisedButton(
//           child: Text('Open route'),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => SecondRoute()),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

/*
var tiles = new List<Widget>();
                  if (state != BluetoothState.on) {
                    tiles.add(_buildAlertTile());
                  }
                  if (isConnected) {
                    tiles.add(_buildDeviceStateTile());
                    tiles.addAll(_buildServiceTiles());
                  } else {
                    tiles.addAll(_buildScanResultTiles());
                  }
                return Scaffold(
                  appBar: AppBar(
                    leading: new IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text("Connect to a Device"),
                  ),
                  body: new Stack(
                      children: <Widget>[
                        (isScanning) ? _buildProgressBarTile() : new Container(),
                        new ListView(
                          children: tiles,
                        )
                      ],
                    ),
                  );
*/


class BluetoothInfo {
  FlutterBlue flutterBlue;

  /// State
  StreamSubscription stateSubscription;
  BluetoothState state;

  /// Device
  BluetoothDevice device;
  StreamSubscription deviceConnection;
  StreamSubscription deviceStateSubscription;
  List<BluetoothService> services;
  Map<Guid, StreamSubscription> valueChangedSubscriptions;
  BluetoothDeviceState deviceState;

  BluetoothInfo (
    this.flutterBlue,
    this.stateSubscription,
    this.state,
    this.device,
    this.deviceConnection,
    this.deviceStateSubscription,
    this.services,
    this.valueChangedSubscriptions,
    this.deviceState
  );
}

class DeviceInfo {

}

// want to get device back
// pass necessary info to get device