import 'package:flutter/widgets.dart';

class SelectionHelper with ChangeNotifier {
  // time in UNIX time, temp in Celsius
  int time;
  int temp;
  int hum;

  DateTime getDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(time * 1000);
  }
}