import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'images_cache.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE images(id INTEGER PRIMARY KEY, url TEXT, image BLOB)',
    );
  }

  Future<int> insertImage(String url, Uint8List image) async {
    final db = await database;
    var res = await db.insert(
      'images',
      {'url': url, 'image': image},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return res;
  }

  Future<Uint8List?> getImage(String url) async {
    final db = await database;
    var res = await db.query(
      'images',
      where: 'url = ?',
      whereArgs: [url],
    );
    if (res.isNotEmpty) {
      return res.first['image'] as Uint8List?;
    }
    return null;
  }
}
