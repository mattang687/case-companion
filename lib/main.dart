import 'package:flutter/material.dart';
import 'package:myapp/local_data/database_helper.dart';
import 'package:provider/provider.dart';

import 'bluetooth/inherited_bluetooth.dart';
import 'screens/home_page/home_page.dart';

// provide bluetooth functionality to the whole app and database
// access to just the homepage
void main() {
  runApp(ChangeNotifierProvider<InheritedBluetooth> (
    builder: (BuildContext context) => InheritedBluetooth(),
    child: MaterialApp(
      title: "Case Companion",
      home: ChangeNotifierProvider<DatabaseHelper> (
        builder: (_) => DatabaseHelper(),
        child: HomePage(),
      ),
  ),
  ));
}