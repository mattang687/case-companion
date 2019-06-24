import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'ble.dart';

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

class TempWidget extends StatelessWidget {
  const TempWidget(this.temp);
  final int temp;

  @override
  Widget build(BuildContext context) {
    return Text('$temp\u00b0 C');
  }
}

class HumWidget extends StatelessWidget {
  const HumWidget(this.hum);
  final int hum;

  @override
  Widget build(BuildContext context) {
    return Text('$hum\u00b0 C');
  }
}

class BatWidget extends StatelessWidget {
  const BatWidget(this.bat);
  final int bat;

  @override
  Widget build(BuildContext context) {
    return Text('$bat\u00b0 C');
  }
}