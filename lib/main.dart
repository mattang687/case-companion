import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/local_data/database_helper.dart';
import 'package:myapp/local_data/settings_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter/painting.dart';

import 'bluetooth/inherited_bluetooth.dart';
import 'screens/home_page/home_page.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<InheritedBluetooth>.value(
              value: InheritedBluetooth()),
          ChangeNotifierProvider<SettingsHelper>.value(value: SettingsHelper()),
          ChangeNotifierProvider<DatabaseHelper>.value(value: DatabaseHelper()),
        ],
        child: MaterialApp(
          title: "Case Companion",
          theme: ThemeData(
            primaryColor: Color.fromARGB(255, 20, 33, 61),
            highlightColor: Color.fromARGB(255, 194, 1, 20),
            accentColor: Color.fromARGB(255, 252, 163, 17),
            primaryColorDark: Color.fromARGB(255, 40, 40, 40),
            fontFamily: 'Oswald',
          ),
          home: HomePage()
        ),
      ),
    );
  });
}
