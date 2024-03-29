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
        // must provide database and settings to entire app because navigator.push() does not
        // add the new screen as a child of the parent
        providers: [
          ChangeNotifierProvider<InheritedBluetooth>.value(
              value: InheritedBluetooth()),
          ChangeNotifierProvider<DatabaseHelper>.value(value: DatabaseHelper()),
          ChangeNotifierProvider<SettingsHelper>.value(value: SettingsHelper())
        ],
        child: MaterialApp(
          title: "Case Companion",
          theme: ThemeData(
            primaryColor: Color.fromARGB(255, 20, 33, 61), // navy
            highlightColor: Color.fromARGB(255, 194, 1, 20), // red
            accentColor: Color.fromARGB(255, 252, 163, 17), // yellow
            primaryColorDark: Color.fromARGB(255, 60, 60, 60), // dark grey
            fontFamily: 'Oswald',
          ),
          home: HomePage(),
        ),
      ),
    );
  });
}
