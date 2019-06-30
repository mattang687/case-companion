import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'database_entry.dart';

class DatabaseHelper {
  static final _databaseName = "LocalDatabase.db";
  static final _databaseVersion = 1;

  static final table = 'graph_data';

  static final columnId = "id";
  static final columnTime = "time";
  static final columnTemp = "temp";
  static final columnHum = "hum";

  // singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async{
    if(_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open database or create if it doesn't exist
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnTime INTEGER NOT NULL UNIQUE
        $columnTemp INTEGER NOT NULL,
        $columnHum INTEGER NOT NULL,
      )
    ''');
  }

  Future<int> insert(Entry e) async {
    Database db = await instance.database;
    return await db.insert(table, e.toMap());
  }

  Future<List<Entry>> queryAllRows() async {
    Database db = await instance.database;
    List<Entry> ret = new List<Entry>();
    List<Map<String, dynamic>> list = await db.query(table);
    list.forEach((map) {
      ret.add(Entry.fromMap(map));
    });

    return ret;
  }

  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  // delete the oldest entry
  Future<int> deleteLast() async {
    Database db = await instance.database;
    return await db.rawDelete('DELETE FROM $table WHERE $columnTime = (SELECT MAX($columnTime) FROM $table)');
  }
}