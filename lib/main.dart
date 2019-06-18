import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:myapp/widgets.dart';

import 'ScanRoute.dart';

void main() {
  runApp(MaterialApp(
    title: "Case Companion", 
    home: CaseCompanionApp(),
  ));
}

/*
  This is the main screen of the app. The user will be able to read data from
  the temperature, humidity, and battery characteristics, and they will be shown
  in the upper half of the screen. A button in the top right will allow the user
  to go to the scanning page, where he can connect to a device, which will be
  passed back here.

  Hopefully, a graph showing fluctuations over time will be implemented.

  Things to do:
  Read data
    Requires real-time access to the device and its services
    Must be able to send read requests to the device
  Pretty layout
*/
class CaseCompanionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Case Companion"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScanRoute()),
              );
            },
          )
        ],
      ),
      body: Center(
        child: Text("Data and graphs go here")
      )
    );
  }
}