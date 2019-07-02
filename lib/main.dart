import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bluetooth/inherited_bluetooth.dart';
import 'screens/home_page/home_page.dart';

void main() {
  runApp(ChangeNotifierProvider<InheritedBluetooth> (
    builder: (BuildContext context) => InheritedBluetooth(),
    child: MaterialApp(
      title: "Case Companion",
      home: HomePage(),
    ),
  ));
}