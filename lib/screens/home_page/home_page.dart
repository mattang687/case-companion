import 'package:flutter/material.dart';
import 'package:myapp/local_data/database_helper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/bluetooth/inherited_bluetooth.dart';

import 'home_page_widgets.dart';
import 'chart_helper.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool inCelsius = true;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> _getUnitSetting() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      inCelsius = prefs.getBool('inCelsius') ?? true;
    });
    return;
  }

  Future<void> _setUnitSetting(bool value) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      inCelsius = value;
      prefs.setBool('inCelsius', value).then((bool success) => true);
    });
  }

  @override
  initState() {
    super.initState();
    _getUnitSetting();
  }

  // read data and save to SQLite databse, if connected
  Future<void> _updateData() async {
    InheritedBluetooth inheritedBluetooth =
        Provider.of<InheritedBluetooth>(context);
    if (inheritedBluetooth.btInfo.isConnected) {
      await inheritedBluetooth.readTemp();
      await inheritedBluetooth.readHum();
      await inheritedBluetooth.readBat();

      DatabaseHelper db = Provider.of<DatabaseHelper>(context);
      db.save(
        temp: inheritedBluetooth.temp.round(),
        hum: inheritedBluetooth.hum,
      );
    }

    setState(() {});
    return;
  }

  void _showDatePicker() async {
    DateTime now = DateTime.now();
    DateTime nowRoundDown = DateTime.utc(now.year, now.month, now.day);
    DateTime selectedDate = await showDatePicker(
      context: context,
      initialDate: nowRoundDown,
      firstDate: DateTime(2000),
      lastDate: nowRoundDown,
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
  }

  // confirmation dialog to clear data
  void _showDialog() {
    showDialog(
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
              onPressed: _clear,
            )
          ],
        );
      }
    );
  }

  void _clear() {
    Provider.of<DatabaseHelper>(context).clearData();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    Provider.of<InheritedBluetooth>(context).btInfo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Case Companion"),
      ),
      body: Center(
        child: Container(
          child: Column(
            children: <Widget>[
              DataWidget(inCelsius),
              ChartWidget(inCelsius),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          height: MediaQuery.of(context).size.height -
              kToolbarHeight -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.keyboard_arrow_up),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: 300,
                child: Column(
                  children: <Widget>[
                    DeviceInfoTile(),
                    ListTile(
                      leading: Icon(Icons.refresh),
                      title: Text('Refresh Data'),
                      trailing: RaisedButton(
                        child: Text('REFRESH'),
                        textColor: Colors.white,
                        color: Colors.black,
                        onPressed: _updateData,
                      )
                    ),
                    ListTile(
                      leading: Icon(Icons.clear),
                      title: Text('Clear Before'),
                      trailing: RaisedButton(
                        child: Text('PICK'),
                        textColor: Colors.white,
                        color: Colors.black,
                        onPressed: _showDatePicker,
                      )
                    ),
                    ListTile(
                      leading: Icon(Icons.clear_all),
                      title: Text('Clear All'),
                      trailing: RaisedButton(
                        child: Text('CLEAR'),
                        textColor: Colors.white,
                        color: Colors.red,
                        onPressed: _showDialog,
                      )
                    ),
                    ListTile(
                      leading: Icon(Icons.wb_cloudy),
                      title: Text('Celsius'),
                      trailing: UnitSwitch(
                        switchValue: inCelsius,
                        valueChanged: (value) {
                          _setUnitSetting(value);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
