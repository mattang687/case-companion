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
  double temp;
  int hum;
  int bat;

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
      temp = await inheritedBluetooth.readTemp();
      hum = await inheritedBluetooth.readHum();
      bat = await inheritedBluetooth.readBat();

      DatabaseHelper db = Provider.of<DatabaseHelper>(context);
      db.save(
        temp: temp.round(),
        hum: hum,
      );
    }

    setState(() {});
    return;
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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async => _updateData(),
          ),
        ],
      ),
      body: Center(
        child: Container(
          child: Column(
            children: <Widget>[
              DataWidget(temp, hum, inCelsius),
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
                height: 120,
                child: Column(
                  children: <Widget>[
                    DeviceInfoTile(bat),
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
