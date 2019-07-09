import 'package:flutter/material.dart';
import 'package:myapp/bluetooth/inherited_bluetooth.dart';
import 'package:myapp/local_data/database_helper.dart';
import 'package:myapp/local_data/settings_helper.dart';
import 'package:myapp/screens/scan_page/scan_page.dart';
import 'package:provider/provider.dart';

class ModalBottomSheet extends StatelessWidget {
  // read data and save to SQLite databse, if connected
  Future<void> _updateData(BuildContext context) async {
    InheritedBluetooth inheritedBluetooth =
        Provider.of<InheritedBluetooth>(context);
    if (inheritedBluetooth.isConnected()) {
      await inheritedBluetooth.readAll();

      DatabaseHelper db = Provider.of<DatabaseHelper>(context);
      await db.save(
        temp: inheritedBluetooth.temp.round(),
        hum: inheritedBluetooth.hum,
      );
    }
    return;
  }

  Future<void> _showDatePicker(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2019),
      lastDate: now,
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light(),
          child: child,
        );
      },
    );
    if (selectedDate != null) {
      print(selectedDate.toString());
      DatabaseHelper db = Provider.of<DatabaseHelper>(context);
      db.deleteBefore(selectedDate);
    }
    return;
  }

  // confirmation dialog to clear data
  Future<void> _showDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear data?'),
          content: Text('This will delete all saved data.'),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: Navigator.of(context).pop,
            ),
            FlatButton(
              child: Text('CONFIRM'),
              onPressed: () => _clear(context),
            ),
          ],
        );
      },
    );
    return;
  }

  void _clear(BuildContext context) {
    Provider.of<DatabaseHelper>(context).clearData();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final SettingsHelper settingsHelper = Provider.of<SettingsHelper>(context);
    return Container(
      height: 300,
      child: Column(
        children: <Widget>[
          DeviceInfoTile(),
          ListTile(
            leading: Icon(Icons.refresh),
            title: Text('Refresh Data'),
            onTap: () => _updateData(context),
          ),
          ListTile(
            leading: Icon(Icons.clear),
            title: Text('Clear Before'),
            onTap: () => _showDatePicker(context),
          ),
          ListTile(
            leading: Icon(Icons.clear_all),
            title: Text('Clear All'),
            onTap: () => _showDialog(context),
          ),
          ListTile(
            leading: Icon(Icons.wb_cloudy),
            title: Text('Celsius'),
            onTap: () {},
            trailing: UnitSwitch(
              switchValue: settingsHelper.inCelsius,
              valueChanged: (value) {
                settingsHelper.setUnitSetting(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Displays currently connected device and its battery level
class DeviceInfoTile extends StatelessWidget {
  Widget _buildTitle(InheritedBluetooth inheritedBluetooth) {
    return inheritedBluetooth.isConnected()
        ? Column(
            children: <Widget>[
              Text('${inheritedBluetooth.device.name}'),
              Text(
                '${'Battery: ${inheritedBluetooth.bat}%'}',
                style: TextStyle(color: Colors.grey),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
          )
        : Text('Scan for Devices');
  }

  @override
  Widget build(BuildContext context) {
    final InheritedBluetooth inheritedBluetooth =
        Provider.of<InheritedBluetooth>(context);
    return ListTile(
      leading: Icon(Icons.devices),
      title: _buildTitle(inheritedBluetooth),
      onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ScanPage()),
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
