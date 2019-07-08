import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/local_data/database_helper.dart';
import 'package:myapp/local_data/settings_helper.dart';
import 'package:myapp/screens/home_page/selection_helper.dart';
import 'package:provider/provider.dart';

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
          home: ChangeNotifierProvider.value(
            value: SelectionHelper(),
            child: HomePage(),
          ),
        ),
      ),
    );
  });
}
