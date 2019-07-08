import 'dart:math';

import 'package:myapp/local_data/database_entry.dart';
import 'package:myapp/local_data/database_utils.dart';

void main() {
  DatabaseUtils db = DatabaseUtils.instance;
  Random rand = Random(12345);

  for (int i = 0; i < 200; i++) {
    Entry e = new Entry(
      time: rand.nextInt(100000000),
      temp: rand.nextInt(200) - 100,
      hum: rand.nextInt(100),
    );
    db.insert(e);
  }
}