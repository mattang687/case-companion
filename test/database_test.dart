import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/database_entry.dart';
import 'package:myapp/database_helper.dart';

// to be run through an emulator/device with "flutter run test/database_test.dart"
void main() {
  test('Insert single, query row count', () async {
    final DatabaseHelper db = DatabaseHelper.instance;
    db.clear();

    Entry e = new Entry(
      time: 100,
      temp: 99,
      hum: 90,
    );

    db.insert(e);
    expect(await db.queryRowCount(), 1);
  });

  test('Insert single, delete last', () async {
    final DatabaseHelper db = DatabaseHelper.instance;
    db.clear();

    Entry e = new Entry(
      time: 100,
      temp: 99,
      hum: 90,
    );

    db.insert(e);
    db.deleteLast();
    expect(await db.queryRowCount(), 0);
  });

  test('Insert single, query all rows', () async {
    final DatabaseHelper db = DatabaseHelper.instance;
    db.clear();

    Entry e = new Entry(
      time: 100,
      temp: 99,
      hum: 90,
    );

    db.insert(e);
    List<Entry> l = await db.queryAllRows();
    expect(l.length, 1);

    expect(l[0].id, 1);
    expect(l[0].time, 100);
    expect(l[0].temp, 99);
    expect(l[0].hum, 90);
  });

  test('Insert multiple, query row count', () async {
    final DatabaseHelper db = DatabaseHelper.instance;
    db.clear();

    Entry e1 = new Entry(
      time: 100,
      temp: 99,
      hum: 90,
    );

    Entry e2 = new Entry(
      time: 101,
      temp: 99,
      hum: 90,
    );

    Entry e3 = new Entry(
      time: 12,
      temp: 99,
      hum: 90,
    );

    db.insert(e1);
    db.insert(e2);
    db.insert(e3);
    expect(await db.queryRowCount(), 3);
  });

  test('Insert multiple, delete last', () async {
    final DatabaseHelper db = DatabaseHelper.instance;
    db.clear();

    Entry e1 = new Entry(
      time: 100,
      temp: 99,
      hum: 90,
    );

    Entry e2 = new Entry(
      time: 101,
      temp: 991,
      hum: 901,
    );

    Entry e3 = new Entry(
      time: 12,
      temp: 992,
      hum: 902,
    );

    db.insert(e1);
    db.insert(e2);
    db.insert(e3);

    db.deleteLast(); // should delete e2

    expect(await db.queryRowCount(), 2);

    List<Entry> l = await db.queryAllRows();
    expect(l.length, 2);
    
    expect(l[0].id, 1);
    expect(l[0].time, 100);
    expect(l[0].temp, 99);
    expect(l[0].hum, 90);

    expect(l[1].id, 3);
    expect(l[1].time, 12);
    expect(l[1].temp, 992);
    expect(l[1].hum, 902);
  });
}