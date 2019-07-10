import 'package:flutter/material.dart';
import 'package:myapp/bluetooth/inherited_bluetooth.dart';
import 'package:myapp/local_data/settings_helper.dart';
import 'package:provider/provider.dart';

class DataWidget extends StatelessWidget {
  Widget _buildTemp(InheritedBluetooth inheritedBluetooth, bool inCelsius,
      BuildContext context) {
    String roundedTemp;
    if (inCelsius) {
      roundedTemp = (inheritedBluetooth.temp ?? 0).toStringAsFixed(1);
    } else {
      roundedTemp =
          ((inheritedBluetooth.temp ?? 0) * 9 / 5 + 32).toStringAsFixed(1);
    }
    return Text(
      '$roundedTemp\u00b0',
      style: TextStyle(
        fontSize: 70,
        fontFamily: 'Raleway',
        color: Theme.of(context).accentColor,
      ),
    );
  }

  Widget _buildHum(InheritedBluetooth inheritedBluetooth) {
    return Text(
      '${inheritedBluetooth.hum?? 0}%',
      style:
          TextStyle(fontSize: 50, fontFamily: 'Raleway', color: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    final InheritedBluetooth inheritedBluetooth =
        Provider.of<InheritedBluetooth>(context);
    final bool inCelsius = Provider.of<SettingsHelper>(context).inCelsius;
    return FittedBox(
      fit: BoxFit.fitHeight,
      child: Column(
        children: inheritedBluetooth.isConnected()
            ? <Widget>[
                _buildTemp(inheritedBluetooth, inCelsius, context),
                _buildHum(inheritedBluetooth),
              ]
            : <Widget>[
                Text(
                  'Connect to a device to show data',
                  style: TextStyle(color: Colors.grey),
                )
              ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }
}
