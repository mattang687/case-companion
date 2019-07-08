import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/local_data/database_entry.dart';
import 'package:myapp/local_data/database_utils.dart';

// to be run through an emulator/device with "flutter run test/database_test.dart"
void main() {
  test('Insert single, delete', () async {
    final DatabaseUtils db = DatabaseUtils.instance;
    db.clear();

    Entry e = new Entry(
      time: 100,
      temp: 99,
      hum: 90,
    );

    db.insert(e);
    db.deleteBefore(DateTime.now());
    List<Entry> l = await db.queryAllRows();
    expect(l.length, 0);
  });

  test('Insert single', () async {
    final DatabaseUtils db = DatabaseUtils.instance;
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

  test('Insert multiple', () async {
    final DatabaseUtils db = DatabaseUtils.instance;
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
    List<Entry> l = await db.queryAllRows();
    expect(l.length, 3);
  });

  test('Insert multiple, delete mutliple', () async {
    final DatabaseUtils db = DatabaseUtils.instance;
    db.clear();

    Entry e1 = new Entry(
      time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
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

    db.deleteBefore(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch - 1000)); // should delete e2 and e3
    List<Entry> l = await db.queryAllRows();
    expect(l.length, 1);
    
    expect(l[0].id, 1);
    expect(l[0].temp, 99);
    expect(l[0].hum, 90);
  });
  
  test('Insert double', () async {
    final DatabaseUtils db = DatabaseUtils.instance;
    db.clear();

    Entry e = new Entry(
      time: 100,
      temp: 99.9,
      hum: 90,
    );

    db.insert(e);
    List<Entry> l = await db.queryAllRows();
    expect(l.length, 1);

    expect(l[0].id, 1);
    expect(l[0].time, 100);
    expect(l[0].temp, 99.9);
    expect(l[0].hum, 90);
  });
}