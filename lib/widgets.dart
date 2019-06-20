import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:myapp/ble.dart';
import 'package:myapp/main.dart';

class ScanResultTile extends StatefulWidget {
  ScanResultTile({this.result, this.onConnectTap, this.onDisconnectTap, this.btInfo});
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

class TempWidget extends StatefulWidget {
  TempWidget(this.btInfo);
  BTInfo btInfo;

  @override
  State<StatefulWidget> createState() {
    return TempWidgetState(btInfo);
  }
}

class TempWidgetState extends State<TempWidget> {
  TempWidgetState(this.btInfo);
  BTInfo btInfo;
  double temperature;

  Future<int> readTemp() async {
    // Base UUID: 00000000-0000-1000-8000-00805F9B34FB
    // two bytes, most significant last, two's complement for negative numbers
    BluetoothCharacteristic temp = BluetoothCharacteristic(
      descriptors: <BluetoothDescriptor>[], 
      properties: null, 
      serviceUuid: new Guid("0000181A-0000-1000-8000-00805F9B34FB"), 
      uuid: new Guid("00002A6E-0000-1000-8000-00805F9B34FB")
    );

    List<int> ret = await btInfo.device.readCharacteristic(temp);
    int sum = ret[1] * 256 + ret[0];
    if (ret[1] > 127) {
      // negative, find two's complement
      return -(65536 - sum) ~/ 100;
    } else {
      return sum ~/ 100;
    }
  }

  Future<int> readHum() async {
    // Base UUID: 00000000-0000-1000-8000-00805F9B34FB
    // two bytes, most significant last, unsigned
    BluetoothCharacteristic temp = BluetoothCharacteristic(
      descriptors: <BluetoothDescriptor>[], 
      properties: null, 
      serviceUuid: new Guid("0000181A-0000-1000-8000-00805F9B34FB"), 
      uuid: new Guid("00002A6F-0000-1000-8000-00805F9B34FB")
    );

    List<int> ret = await btInfo.device.readCharacteristic(temp);
    int sum = ret[1] * 256 + ret[0];
    return sum ~/ 100;
  }

  Future<int> readBat() async {
    // Base UUID: 00000000-0000-1000-8000-00805F9B34FB
    // one byte, unsigned
    BluetoothCharacteristic temp = BluetoothCharacteristic(
      descriptors: <BluetoothDescriptor>[], 
      properties: null, 
      serviceUuid: new Guid("0000180F-0000-1000-8000-00805F9B34FB"), 
      uuid: new Guid("00002A19-0000-1000-8000-00805F9B34FB")
    );

    List<int> ret = await btInfo.device.readCharacteristic(temp);
    return ret[0];
  }

  Future<List<int>> readData() async {
    List<int> ret = new List<int>(3);
    ret[0] = await readTemp();
    ret[1] = await readHum();
    ret[2] = await readBat();
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return btInfo.isConnected ? FutureBuilder<List<int>>(
      future: readData(),
      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('Connect to a device.');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Text('Awaiting result...');
          case ConnectionState.done:
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');
            return Text('Temperature: ${snapshot.data.toString()}');
        }
        return null; // unreachable
      },
    ) : Text('Data: device not connected');
  }
}