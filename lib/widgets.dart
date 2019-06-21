import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'ble.dart';
import 'main.dart';

class ScanResultTile extends StatefulWidget {
  const ScanResultTile({this.result, this.onConnectTap, this.onDisconnectTap, this.btInfo});
  final ScanResult result;
  final VoidCallback onConnectTap;
  final VoidCallback onDisconnectTap;
  final BTInfo btInfo;

  @override
  State<StatefulWidget> createState() => ScanResultTileState();
}

class ScanResultTileState extends State<ScanResultTile> {
  ScanResult result;
  VoidCallback onConnectTap;
  VoidCallback onDisconnectTap;
  BTInfo btInfo;

  @override
  void initState() {
    super.initState();
    btInfo = widget.btInfo;
    result = widget.result;
    onConnectTap = widget.onConnectTap;
    onDisconnectTap = widget.onDisconnectTap;
    // Immediately get the state of FlutterBlue
    btInfo.flutterBlue.state.then((s) {
      setState(() {
        btInfo.state = s;
      });
    });
    // Subscribe to state changes
    btInfo.stateSubscription = btInfo.flutterBlue.onStateChanged().listen((s) {
      setState(() {
        btInfo.state = s;
      });
    });
  }

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
    if (btInfo.device != null && result.device.id == btInfo.device.id) {
      return RaisedButton(
        child: Text("DISCONNECT"),
        color: Colors.red,
        textColor: Colors.white,
        onPressed: () => onDisconnectTap()
      );
    } else {
      return RaisedButton(
        child: Text('CONNECT'),
        color: (result.advertisementData.connectable) ? Colors.black : Colors.grey,
        textColor: Colors.white,
        onPressed: () => (result.advertisementData.connectable) ? onConnectTap() : null
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: _buildTitle(context),
      trailing: _buildButton()
    );
  }
}

abstract class DataWidget extends BTWidget {
  const DataWidget(btInfo) : super(btInfo);
}

abstract class DataWidgetState extends BTWidgetState {
  Future<List<int>> _repeatedRead(BluetoothCharacteristic c) async {
    try {
      return await btInfo.device.readCharacteristic(c);
    } on PlatformException {
      return Future.delayed(Duration(milliseconds: 200), 
        () async => await _repeatedRead(c));
    }
  }
}

class TempDataWidget extends DataWidget {
  TempDataWidget(btInfo) : super(btInfo);

  @override
  State<StatefulWidget> createState() => TempDataWidgetState();
}

class TempDataWidgetState extends DataWidgetState {
  Future<int> _readTemp() async {
    // Base UUID: 00000000-0000-1000-8000-00805F9B34FB
    // two bytes, most significant last, two's complement for negative numbers
    BluetoothCharacteristic temp = BluetoothCharacteristic(
      descriptors: <BluetoothDescriptor>[], 
      properties: null, 
      serviceUuid: new Guid("0000181A-0000-1000-8000-00805F9B34FB"), 
      uuid: new Guid("00002A6E-0000-1000-8000-00805F9B34FB")
    );

    List<int> ret = await _repeatedRead(temp);
    double tgt;
    int sum = ret[1] * 256 + ret[0];
    if (ret[1] > 127) {
      // negative, find two's complement
      tgt = -(65536 - sum) / 100;
    } else {
      tgt = sum / 100;
    }
    return tgt.round();
    // if (inCelsius) {
    //   return tgt.round();
    // } else {
    //   return (tgt * 9 / 5 + 32).round();
    // }
  }
  @override
  Widget build(BuildContext context) => btInfo.isConnected ? FutureBuilder (
    future: _readTemp(),
    builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Icon(Icons.bluetooth_disabled);
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Icon(Icons.bluetooth_searching);
          case ConnectionState.done:
            if (snapshot.hasError)
              return Icon(Icons.close);
            return Column(children: <Widget>[
              Text('Temperature: ${snapshot.data.toString()}\u00b0 C'),
            ]);
          }
        return null; // unreachable
        }
  ) : Icon(Icons.bluetooth_disabled);
}

class HumDataWidget extends DataWidget {
  HumDataWidget(btInfo) : super(btInfo);

  @override
  State<StatefulWidget> createState() => HumDataWidgetState();
}

class HumDataWidgetState extends DataWidgetState {
  Future<int> _readHum() async {
    // Base UUID: 00000000-0000-1000-8000-00805F9B34FB
    // two bytes, most significant last, unsigned
    BluetoothCharacteristic temp = BluetoothCharacteristic(
      descriptors: <BluetoothDescriptor>[], 
      properties: null, 
      serviceUuid: new Guid("0000181A-0000-1000-8000-00805F9B34FB"), 
      uuid: new Guid("00002A6F-0000-1000-8000-00805F9B34FB")
    );

    List<int> ret = await _repeatedRead(temp);
    int sum = ret[1] * 256 + ret[0];
    return sum ~/ 100;
  }

  @override
  Widget build(BuildContext context) => btInfo.isConnected ? FutureBuilder (
    future: _readHum(),
    builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Icon(Icons.bluetooth_disabled);
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Icon(Icons.bluetooth_searching);
          case ConnectionState.done:
            if (snapshot.hasError)
              return Icon(Icons.close);
            return Column(children: <Widget>[
              Text('Humidity: ${snapshot.data.toString()}%'),
            ]);
          }
        return null; // unreachable
        }
  ) : Icon(Icons.bluetooth_disabled);
}

class BatDataWidget extends DataWidget {
  BatDataWidget(btInfo) : super(btInfo);

  @override
  State<StatefulWidget> createState() => BatDataWidgetState();
}

class BatDataWidgetState extends DataWidgetState {
  Future<int> _readBat() async {
    // Base UUID: 00000000-0000-1000-8000-00805F9B34FB
    // one byte, unsigned
    BluetoothCharacteristic temp = BluetoothCharacteristic(
      descriptors: <BluetoothDescriptor>[], 
      properties: null, 
      serviceUuid: new Guid("0000180F-0000-1000-8000-00805F9B34FB"), 
      uuid: new Guid("00002A19-0000-1000-8000-00805F9B34FB")
    );

    List<int> ret = await _repeatedRead(temp);
    return ret[0];
  }

  @override
  Widget build(BuildContext context) => btInfo.isConnected ? FutureBuilder (
    future: _readBat(),
    builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Icon(Icons.bluetooth_disabled);
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Icon(Icons.bluetooth_searching);
          case ConnectionState.done:
            if (snapshot.hasError)
              return Icon(Icons.close);
            return Column(children: <Widget>[
              Text('Battery: ${snapshot.data.toString()}%'),
            ]);
          }
        return null; // unreachable
        }
  ) : Icon(Icons.bluetooth_disabled);
}