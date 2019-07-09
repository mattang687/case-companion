import 'package:flutter/material.dart';
import 'package:myapp/bluetooth/inherited_bluetooth.dart';
import 'package:myapp/local_data/settings_helper.dart';
import 'package:provider/provider.dart';

class DataWidget extends StatelessWidget {
  Widget _buildTemp(InheritedBluetooth inheritedBluetooth, bool inCelsius) {
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
    final InheritedBluetooth inheritedBluetooth =
        Provider.of<InheritedBluetooth>(context);
    final bool inCelsius = Provider.of<SettingsHelper>(context).inCelsius;
    return Column(
      children: inheritedBluetooth.isConnected()
          ? <Widget>[
              _buildTemp(inheritedBluetooth, inCelsius),
              _buildHum(inheritedBluetooth),
            ]
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
