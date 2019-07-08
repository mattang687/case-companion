import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'database_entry.dart';

class DatabaseUtils {
  static final _databaseName = "LocalDatabase.db";
  static final _databaseVersion = 1;

  static final table = 'graph_data';

  static final columnId = "id";
  static final columnTime = "time";
  static final columnTemp = "temp";
  static final columnHum = "hum";

  // singleton class
  DatabaseUtils._privateConstructor();
  static final DatabaseUtils instance = DatabaseUtils._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open database or create if it doesn't exist
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    if (documentsDirectory == null) print("DOC DIR NULL");
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnTime INTEGER NOT NULL UNIQUE,
        $columnTemp REAL NOT NULL,
        $columnHum INTEGER NOT NULL
      )
    ''');
  }

  // insert an entry
  Future<int> insert(Entry e) async {
    Database db = await instance.database;
    try {
      return await db.insert(table, e.toMap());
    } catch (e) {
      return null;
    }
  }

  // query all rows
  Future<List<Entry>> queryAllRows() async {
    Database db = await instance.database;
    List<Entry> ret = new List<Entry>();
    List<Map<String, dynamic>> list = await db.query(table);
    list.forEach((map) {
      ret.add(Entry.fromMap(map));
    });

    return ret;
  }

  // delete before a specified dateTime
  Future<int> deleteBefore(DateTime dateTime) async {
    Database db = await instance.database;
    int unixTime = dateTime.millisecondsSinceEpoch ~/ 1000;
    return await db
        .delete(table, where: '$columnTime < ?', whereArgs: [unixTime]);
  }

  // clears all data by deleting the table
  clear() async {
    Database db = await instance.database;
    db.delete(table);
  }
}
