import 'package:flutter/material.dart';
import 'package:myapp/local_data/database_entry.dart';
import 'package:myapp/local_data/database_utils.dart';

class DatabaseHelper with ChangeNotifier {
  DatabaseUtils db = DatabaseUtils.instance;
  List<Entry> data = new List<Entry>();

  DatabaseHelper() {
    updateData();
  }

  Future<void> updateData() async {
    DatabaseUtils db = DatabaseUtils.instance;
      data = await db.queryAllRows();
    notifyListeners();
    return;
  }

  Future<void> save({int temp, int hum}) async {
    DatabaseUtils db = DatabaseUtils.instance;
    Entry e = new Entry(
      time: (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).round(),
      temp: temp,
      hum: hum,
    );
    await db.insert(e);
    await updateData();
    print("SAVE" + (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).round().toString());
    return;
  }
  
  Future<void> clearData() async {
    DatabaseUtils db = DatabaseUtils.instance;
    await db.clear();
    await updateData();
    return;
  }

  Future<void> deleteOldest() async {
    DatabaseUtils db = DatabaseUtils.instance;
    await db.deleteOldest();
    await updateData();
    return;
  }
}