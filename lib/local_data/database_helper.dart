import 'package:flutter/material.dart';
import 'package:myapp/local_data/database_entry.dart';
import 'package:myapp/local_data/database_utils.dart';

// wraps database interaction and provides list of data for simple graphing
class DatabaseHelper with ChangeNotifier {
  DatabaseHelper() {
    updateData();
  }

  DatabaseUtils db = DatabaseUtils.instance;
  List<Entry> data = new List<Entry>();

  // gets all data from database
  Future<void> updateData() async {
    DatabaseUtils db = DatabaseUtils.instance;
    data = await db.queryAllRows();
    notifyListeners();
    return;
  }

  // inserts given data at current time
  Future<void> save({int temp, int hum}) async {
    DatabaseUtils db = DatabaseUtils.instance;
    Entry e = new Entry(
      time: (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).round(),
      temp: temp,
      hum: hum,
    );
    await db.insert(e);
    await updateData();
    return;
  }

  // clears the database
  Future<void> clearData() async {
    DatabaseUtils db = DatabaseUtils.instance;
    await db.clear();
    await updateData();
    return;
  }

  // clears all entries before the specified date
  // rounds time down to 00:00
  Future<void> deleteBefore(DateTime dateTime) async {
    DatabaseUtils db = DatabaseUtils.instance;
    DateTime roundDown = DateTime.utc(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );
    await db.deleteBefore(roundDown);
    await updateData();
    return;
  }
}
