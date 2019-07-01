import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

import 'inherited_bluetooth.dart';

class ConnectedDeviceTile extends StatelessWidget {
  const ConnectedDeviceTile(
      {this.onConnectTap, this.onDisconnectTap});
  final Function(BluetoothDevice d) onConnectTap;
  final VoidCallback onDisconnectTap;

  Widget _buildTitle(BuildContext context, BluetoothDevice device) {
    if (device.name.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(device.name),
          Text(
            device.id.toString(),
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      );
    } else {
      return Text(device.id.toString());
    }
  }

  Widget _buildButton(BTInfo btInfo, BluetoothDevice device) {
    if (btInfo.isConnected) {
      return RaisedButton(
        child: Text("DISCONNECT"),
        color: Colors.red,
        textColor: Colors.white,
        onPressed: () {
          onDisconnectTap();
        },
      );
    } else {
      return RaisedButton(
        child: Text('CONNECT'),
        color: Colors.black,
        textColor: Colors.white,
        onPressed: () {
          onConnectTap(device);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final BTInfo btInfo = Provider.of<InheritedBluetooth>(context).btInfo;
    return ListTile(
      title: _buildTitle(context, btInfo.previousDevice), 
      trailing: _buildButton(btInfo, btInfo.previousDevice),
    );
  }
}

class ScanResultTile extends StatelessWidget {
  const ScanResultTile(
      {this.result, this.onConnectTap, this.onDisconnectTap});
  final ScanResult result;
  final VoidCallback onConnectTap;
  final VoidCallback onDisconnectTap;

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

  Widget _buildButton(BTInfo btInfo) {
    if (btInfo.device != null && result.device.id == btInfo.device.id) {
      return RaisedButton(
        child: Text("DISCONNECT"),
        color: Colors.red,
        textColor: Colors.white,
        onPressed: () => onDisconnectTap(),
      );
    } else {
      return RaisedButton(
        child: Text('CONNECT'),
        color:
            (result.advertisementData.connectable) ? Colors.black : Colors.grey,
        textColor: Colors.white,
        onPressed: () =>
            (result.advertisementData.connectable) ? onConnectTap() : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final BTInfo btInfo = Provider.of<InheritedBluetooth>(context).btInfo;
    return ListTile(title: _buildTitle(context), trailing: _buildButton(btInfo));
  }
}

class PullToScanWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 5),
        ),
        Text(
          'Pull to Scan',
          style: TextStyle(color: Colors.grey),
        ),
        Icon(
          Icons.keyboard_arrow_down,
          color: Colors.grey,
        ),
      ],
    );
  }
}
