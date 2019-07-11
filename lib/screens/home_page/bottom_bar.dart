import 'package:flutter/material.dart';
import 'package:myapp/bluetooth/inherited_bluetooth.dart';
import 'package:myapp/local_data/database_helper.dart';
import 'package:myapp/screens/scan_page/scan_page.dart';
import 'package:myapp/screens/settings_page/settings_page.dart';
import 'package:provider/provider.dart';

class DeviceInfoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final InheritedBluetooth inheritedBluetooth =
        Provider.of<InheritedBluetooth>(context);
    return FlatButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.only(bottomEnd: Radius.circular(15), topEnd: Radius.circular(15),)),
      child: Row(
        children: <Widget>[
          SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width / 3,
            child: Column(
              children: inheritedBluetooth.isConnected()
                  ? <Widget>[
                      Text(
                        '${inheritedBluetooth.device.name}',
                        style: TextStyle(color: Theme.of(context).accentColor),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        'Battery: ${inheritedBluetooth.bat?? 0}%',
                        style: TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ]
                  : <Widget>[
                      Text(
                        'Look for Devices',
                        style: TextStyle(color: Theme.of(context).accentColor),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
        ],
      ),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ScanPage()),
      ),
    );
  }
}

class ClearButton extends StatelessWidget {
  Future<void> _showDatePicker(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2019),
      lastDate: now,
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: Theme.of(context),
          child: child,
        );
      },
    );
    if (selectedDate != null) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Clear Data?'),
            content: Text(
                'This will delete all saved data up to, and including, the selected date.'),
            actions: <Widget>[
              FlatButton(
                child: Text('CANCEL'),
                onPressed: Navigator.of(context).pop,
              ),
              FlatButton(
                child: Text('CONFIRM'),
                onPressed: () {
                  DatabaseHelper db = Provider.of<DatabaseHelper>(context);
                  db.deleteBefore(selectedDate);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.clear_all,
        color: Colors.white,
      ),
      onPressed: () => _showDatePicker(context),
    );
  }
}

class SettingsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.more_vert, color: Colors.white,),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      ),
    );
  }
}

class ButtonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ClearButton(),
        SettingsButton(),
      ],
    );
  }
}

class FloatingRefreshButton extends StatelessWidget {
  Future<void> _updateData(BuildContext context) async {
    InheritedBluetooth inheritedBluetooth =
        Provider.of<InheritedBluetooth>(context);
    if (inheritedBluetooth.isConnected()) {
      if (await inheritedBluetooth.readAll()) {
        DatabaseHelper db = Provider.of<DatabaseHelper>(context);
        await db.save(
          temp: inheritedBluetooth.temp,
          hum: inheritedBluetooth.hum,
        );
      }
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.refresh),
      onPressed: () => _updateData(context),
    );
  }
}
