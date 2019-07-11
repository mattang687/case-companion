import 'package:flutter/material.dart';
import 'package:myapp/local_data/settings_helper.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SettingsHelper settingsHelper = Provider.of<SettingsHelper>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          UnitSettingTile(settingsHelper.inCelsius),
        ],
      ),
    );
  }
}

class UnitSettingTile extends StatefulWidget {
  const UnitSettingTile(this.initialValue);
  final bool initialValue;

  @override
  State<StatefulWidget> createState() {
    return _UnitSettingTileState();
  }
}

class _UnitSettingTileState extends State<UnitSettingTile> {
  bool _inCelsius;
  final List<DropdownMenuItem<bool>> _menuItems = [
    DropdownMenuItem(value: true, child: Text('Celsius')),
    DropdownMenuItem(value: false, child: Text('Fahrenheit'))
  ];

  @override
  void initState() {
    _inCelsius = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SettingsHelper settingsHelper = Provider.of<SettingsHelper>(context);
    return ListTile(
      title: Text('Units'),
      trailing: DropdownButton(
        value: _inCelsius,
        items: _menuItems,
        onChanged: (bool value) {
          settingsHelper.setUnitSetting(value);
          _inCelsius = value;
        },
      ),
    );
  }
}
