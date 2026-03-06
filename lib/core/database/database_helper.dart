import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mdc.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNull = 'TEXT';
    const realType = 'REAL NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';

    await db.execute('''
CREATE TABLE clients (
  id $idType,
  name $textType,
  phone $textTypeNull,
  notes $textTypeNull
)
''');

    await db.execute('''
CREATE TABLE rides (
  id $idType,
  client_id INTEGER NOT NULL,
  value $realType,
  note $textTypeNull,
  date $textType,
  is_paid $boolType,
  is_completed $boolType,
  FOREIGN KEY (client_id) REFERENCES clients (id) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE config (
  id $idType,
  value1 $realType,
  value2 $realType,
  value3 $realType,
  value4 $realType
)
''');

    // Insert default values into config
    await db.insert('config', {
      'value1': 10.0,
      'value2': 15.0,
      'value3': 20.0,
      'value4': 25.0,
    });
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
