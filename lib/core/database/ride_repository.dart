
import '../models/ride.dart';
import 'database_helper.dart';

class RideRepository {
  Future<Ride> create(Ride ride) async {
    final db = await DatabaseHelper.instance.database;
    final id = await db.insert('rides', ride.toMap());
    return ride.copyWith(id: id);
  }

  Future<Ride?> getById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'rides',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Ride.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Ride>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('rides', orderBy: 'date DESC');
    return result.map((json) => Ride.fromMap(json)).toList();
  }

  Future<List<Ride>> getByDateRange(DateTime start, DateTime end) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'rides',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return result.map((json) => Ride.fromMap(json)).toList();
  }

  Future<List<Ride>> getByClientId(int clientId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'rides',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'date DESC',
    );
    return result.map((json) => Ride.fromMap(json)).toList();
  }

  Future<int> update(Ride ride) async {
    final db = await DatabaseHelper.instance.database;
    return db.update(
      'rides',
      ride.toMap(),
      where: 'id = ?',
      whereArgs: [ride.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      'rides',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
