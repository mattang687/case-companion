import 'package:flutter/material.dart';
import 'package:myapp/bluetooth/bluetooth_info.dart';
import 'package:myapp/bluetooth/inherited_bluetooth.dart';
import 'package:myapp/screens/scan_page/scan_page.dart';
import 'package:provider/provider.dart';

class DataWidget extends StatelessWidget {
  const DataWidget(this.temp, this.hum, this.inCelsius);
  final double temp;
  final bool inCelsius;
  final int hum;

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
    final BTInfo btInfo = Provider.of<InheritedBluetooth>(context).btInfo;
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

// Displays currently connected device and its battery level
class DeviceInfoTile extends StatefulWidget {
  const DeviceInfoTile(this.bat);
  final int bat;

  @override
  State<StatefulWidget> createState() {
    return DeviceInfoTileState();
  }
}

class DeviceInfoTileState extends State<DeviceInfoTile> {
  Widget _buildTitle(BTInfo btInfo) {
    return btInfo.isConnected
        ? Column(
            children: <Widget>[
              Text('${btInfo.device.name}'),
              Text(
                '${'Battery: ${widget.bat}%'}',
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
    final BTInfo btInfo = Provider.of<InheritedBluetooth>(context).btInfo;
    return ListTile(
      leading: Icon(Icons.devices),
      title: _buildTitle(btInfo),
      trailing: RaisedButton(
        child: Text('DEVICES'),
        color: Colors.black,
        textColor: Colors.white,
        onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ScanPage()),
            ),
      ),
    );
  }
}

class UnitSwitch extends StatefulWidget {
  UnitSwitch({@required this.switchValue, @required this.valueChanged});
  final bool switchValue;
  final ValueChanged valueChanged;

  @override
  State<StatefulWidget> createState() {
    return UnitSwitchState();
  }
}

class UnitSwitchState extends State<UnitSwitch> {
  bool _inCelsius;

  @override
  void initState() {
    _inCelsius = widget.switchValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _inCelsius,
      onChanged: (bool value) {
        setState(() {
          _inCelsius = value;
          widget.valueChanged(value);
        });
      },
    );
  }
}