import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:myapp/scan_page.dart';
import 'ble.dart';

class ConnectedDeviceTile extends StatefulWidget {
  const ConnectedDeviceTile(
      {this.onConnectTap, this.onDisconnectTap, this.btInfo});
  final Function(BluetoothDevice d) onConnectTap;
  final VoidCallback onDisconnectTap;
  final BTInfo btInfo;

  @override
  State<StatefulWidget> createState() {
    return ConnectedDeviceTileState();
  }
}

class ConnectedDeviceTileState extends State<ConnectedDeviceTile> {
  BluetoothDevice cachedDevice;

  @override
  initState() {
    super.initState();
    cachedDevice = widget.btInfo.device;
  }

  Widget _buildTitle(BuildContext context) {
    if (cachedDevice.name.length > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(cachedDevice.name),
          Text(
            cachedDevice.id.toString(),
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      );
    } else {
      return Text(cachedDevice.id.toString());
    }
  }

  Widget _buildButton() {
    if (widget.btInfo.isConnected) {
      return RaisedButton(
        child: Text("DISCONNECT"),
        color: Colors.red,
        textColor: Colors.white,
        onPressed: () {
          setState(() {
            widget.onDisconnectTap();
          });
        },
      );
    } else {
      return RaisedButton(
        child: Text('CONNECT'),
        color: Colors.black,
        textColor: Colors.white,
        onPressed: () {
          setState(() {
            widget.onConnectTap(cachedDevice);
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(title: _buildTitle(context), trailing: _buildButton());
  }
}

class ScanResultTile extends StatefulWidget {
  const ScanResultTile(
      {this.result, this.onConnectTap, this.onDisconnectTap, this.btInfo});
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
    return ListTile(title: _buildTitle(context), trailing: _buildButton());
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

class InfoWidget extends StatelessWidget {
  const InfoWidget(this.temp, this.hum, this.inCelsius, this.btInfo);
  final double temp;
  final bool inCelsius;
  final int hum;
  final BTInfo btInfo;

  Widget _buildTemp() {
    int roundedTemp;
    if (inCelsius) {
      roundedTemp = (temp ?? 0).round();
    } else {
      roundedTemp = ((temp ?? 0) * 9 / 5 + 32).round();
    }
    return Text(
      '$roundedTemp\u00b0',
      style: TextStyle(fontSize: 50),
    );
  }

  Widget _buildHum() {
    return Text(
      '$hum%',
      style: TextStyle(fontSize: 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: btInfo.isConnected
          ? <Widget>[_buildTemp(), _buildHum()]
          : <Widget>[
              Text(
                'Connect to a device to show data',
                style: TextStyle(color: Colors.grey),
              )
            ],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }
}

class DeviceInfoTile extends StatelessWidget {
  const DeviceInfoTile(this.btInfo, this.bat);
  final BTInfo btInfo;
  final int bat;

  Widget _buildTitle() {
    return btInfo.isConnected
        ? Column(
            children: <Widget>[
              Text('${btInfo.device.name}'),
              Text(
                '${'Battery: $bat%'}',
                style: TextStyle(color: Colors.grey),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
          )
        : Text('Not Connected');
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.devices),
      title: _buildTitle(),
      trailing: RaisedButton(
        child: Text('DEVICES'),
        color: Colors.black,
        textColor: Colors.white,
        onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ScanPage(btInfo)),
            ),
      ),
    );
  }
}
