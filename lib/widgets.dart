import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:myapp/ble.dart';

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
        onPressed: () => (result.advertisementData.connectable) ? onConnectTap : null
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