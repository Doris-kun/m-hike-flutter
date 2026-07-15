import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/hike.dart';

/// DatabaseHelper - quan ly SQLite database cho app M-Hike Flutter
/// Tuong tu DatabaseHelper.java ben Android, nhung dung async/await.
///
/// Dung Singleton pattern - chi 1 instance duy nhat toan app.
class DatabaseHelper {
  // Singleton - chi tao 1 lan
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Getter database - tao neu chua co
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mhike.db');
    return _database!;
  }

  /// Khoi tao database - tao file .db va bang hikes
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Tao bang hikes khi database duoc tao lan dau
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE hikes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        date TEXT NOT NULL,
        parking INTEGER NOT NULL,
        length REAL NOT NULL,
        difficulty TEXT NOT NULL,
        description TEXT,
        weather TEXT,
        elevation_gain INTEGER
      )
    ''');
  }

  // ==================== CRUD ====================

  /// Them 1 hike moi - tra ve id cua hike vua them
  Future<int> insertHike(Hike hike) async {
    final db = await instance.database;
    return await db.insert('hikes', hike.toMap());
  }

  /// Lay tat ca hike, sap xep theo ngay moi nhat truoc
  Future<List<Hike>> getAllHikes() async {
    final db = await instance.database;
    final result = await db.query('hikes', orderBy: 'date DESC');
    return result.map((map) => Hike.fromMap(map)).toList();
  }

  /// Lay 1 hike theo id
  Future<Hike?> getHikeById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'hikes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Hike.fromMap(result.first);
    }
    return null;
  }

  /// Cap nhat 1 hike
  Future<int> updateHike(Hike hike) async {
    final db = await instance.database;
    return await db.update(
      'hikes',
      hike.toMap(),
      where: 'id = ?',
      whereArgs: [hike.id],
    );
  }

  /// Xoa 1 hike theo id
  Future<int> deleteHike(int id) async {
    final db = await instance.database;
    return await db.delete(
      'hikes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Xoa tat ca hike (reset database)
  Future<int> deleteAllHikes() async {
    final db = await instance.database;
    return await db.delete('hikes');
  }
}