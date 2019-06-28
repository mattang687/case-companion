import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets.dart';
import 'ble.dart';

void main() {
  runApp(MaterialApp(
    title: "Case Companion",
    home: HomePage(new BTInfo()),
  ));
}

class HomePage extends BTWidget {
  HomePage(BTInfo btInfo) : super(btInfo);

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends BTWidgetState {
  _HomePageState() : super();

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
    _updateData();
    _getUnitSetting();
  }

  Future<void> _updateData() async {
    Future<List<int>> _repeatedRead(BluetoothCharacteristic c) async {
      try {
        return await btInfo.device.readCharacteristic(c);
      } on PlatformException {
        return Future.delayed(
            Duration(milliseconds: 200), () async => await _repeatedRead(c));
      }
    }

    Future<double> _readTemp() async {
      // Base UUID: 00000000-0000-1000-8000-00805F9B34FB
      // two bytes, most significant last, two's complement for negative numbers
      BluetoothCharacteristic cTemp = BluetoothCharacteristic(
        descriptors: <BluetoothDescriptor>[],
        properties: null,
        serviceUuid: new Guid("0000181A-0000-1000-8000-00805F9B34FB"),
        uuid: new Guid("00002A6E-0000-1000-8000-00805F9B34FB"),
      );

      List<int> ret = await _repeatedRead(cTemp);
      double tgt;
      int sum = ret[1] * 256 + ret[0];
      if (ret[1] > 127) {
        // negative, find two's complement
        tgt = -(65536 - sum) / 100;
      } else {
        tgt = sum / 100;
      }
      return tgt;
    }

    Future<int> _readHum() async {
      // Base UUID: 00000000-0000-1000-8000-00805F9B34FB
      // two bytes, most significant last, unsigned
      BluetoothCharacteristic cHum = BluetoothCharacteristic(
        descriptors: <BluetoothDescriptor>[],
        properties: null,
        serviceUuid: new Guid("0000181A-0000-1000-8000-00805F9B34FB"),
        uuid: new Guid("00002A6F-0000-1000-8000-00805F9B34FB"),
      );

      List<int> ret = await _repeatedRead(cHum);
      int sum = ret[1] * 256 + ret[0];
      return sum ~/ 100;
    }

    Future<int> _readBat() async {
      // Base UUID: 00000000-0000-1000-8000-00805F9B34FB
      // one byte, unsigned
      BluetoothCharacteristic cBat = BluetoothCharacteristic(
        descriptors: <BluetoothDescriptor>[],
        properties: null,
        serviceUuid: new Guid("0000180F-0000-1000-8000-00805F9B34FB"),
        uuid: new Guid("00002A19-0000-1000-8000-00805F9B34FB"),
      );

      List<int> ret = await _repeatedRead(cBat);
      return ret[0];
    }

    if (btInfo.isConnected) {
      temp = await _readTemp();
      hum = await _readHum();
      bat = await _readBat();
    }

    setState(() {});
    return;
  }

  @override
  void dispose() {
    btInfo.stateSubscription?.cancel();
    btInfo.stateSubscription = null;
    btInfo.scanSubscription?.cancel();
    btInfo.scanSubscription = null;
    btInfo.deviceConnection?.cancel();
    btInfo.deviceConnection = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Case Companion"),
      ),
      body: RefreshIndicator(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: Container(
              child: InfoWidget(temp, hum, inCelsius, btInfo),
              height: MediaQuery.of(context).size.height -
                  kToolbarHeight -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
          ),
        ),
        onRefresh: _updateData,
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
                    DeviceInfoTile(btInfo, bat),
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
