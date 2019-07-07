import 'package:flutter/material.dart';
import 'package:myapp/bluetooth/bluetooth_info.dart';
import 'package:myapp/bluetooth/inherited_bluetooth.dart';
import 'package:myapp/screens/scan_page/scan_page.dart';
import 'package:provider/provider.dart';

class DataWidget extends StatelessWidget {
  const DataWidget(this.inCelsius);
  final bool inCelsius;

  Widget _buildTemp(InheritedBluetooth inheritedBluetooth) {
    int roundedTemp;
    if (inCelsius) {
      roundedTemp = (inheritedBluetooth.temp ?? 0).round();
    } else {
      roundedTemp = ((inheritedBluetooth.temp ?? 0) * 9 / 5 + 32).round();
    }
    return Text(
      '$roundedTemp\u00b0',
      style: TextStyle(fontSize: 50),
    );
  }

  Widget _buildHum(InheritedBluetooth inheritedBluetooth) {
    return Text(
      '${inheritedBluetooth.hum}%',
      style: TextStyle(fontSize: 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    final InheritedBluetooth inheritedBluetooth = Provider.of<InheritedBluetooth>(context);
    return Column(
      children: inheritedBluetooth.btInfo.isConnected
          ? <Widget>[_buildTemp(inheritedBluetooth), _buildHum(inheritedBluetooth)]
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
  @override
  State<StatefulWidget> createState() {
    return DeviceInfoTileState();
  }
}

class DeviceInfoTileState extends State<DeviceInfoTile> {
  Widget _buildTitle(InheritedBluetooth inheritedBluetooth) {
    return inheritedBluetooth.btInfo.isConnected
        ? Column(
            children: <Widget>[
              Text('${inheritedBluetooth.btInfo.device.name}'),
              Text(
                '${'Battery: ${inheritedBluetooth.bat}%'}',
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
    final InheritedBluetooth inheritedBluetooth = Provider.of<InheritedBluetooth>(context);
    return ListTile(
      leading: Icon(Icons.devices),
      title: _buildTitle(inheritedBluetooth),
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