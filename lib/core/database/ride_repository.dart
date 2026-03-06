import '../models/ride.dart';
import 'database_helper.dart';

class RideRepository {
  Future<Ride> create(Ride ride) async {
    final db = await DatabaseHelper.instance.client;
    await db.execute(
      "INSERT INTO rides (client_id, value, note, date, is_paid, is_completed) VALUES (?, ?, ?, ?, ?, ?)",
      [ride.clientId, ride.value, ride.note, ride.date.toIso8601String(), ride.isPaid ? 1 : 0, ride.isCompleted ? 1 : 0]
    );
    
    final res = await db.query("SELECT * FROM rides ORDER BY id DESC LIMIT 1");
    if (res.isNotEmpty) {
      return Ride.fromMap(res.first);
    }
    return ride;
  }

  Future<Ride?> getById(int id) async {
    final db = await DatabaseHelper.instance.client;
    final res = await db.query(
      "SELECT * FROM rides WHERE id = ?",
      [id],
    );

    if (res.isNotEmpty) {
      return Ride.fromMap(res.first);
    }
    return null;
  }

  Future<List<Ride>> getAll() async {
    final db = await DatabaseHelper.instance.client;
    final res = await db.query("SELECT * FROM rides ORDER BY date DESC");
    return res.map((row) => Ride.fromMap(row)).toList();
  }

  Future<List<Ride>> getByDateRange(DateTime start, DateTime end) async {
    final db = await DatabaseHelper.instance.client;
    final res = await db.query(
      "SELECT * FROM rides WHERE date >= ? AND date <= ? ORDER BY date DESC",
      [start.toIso8601String(), end.toIso8601String()],
    );
    return res.map((row) => Ride.fromMap(row)).toList();
  }

  Future<List<Ride>> getByClientId(int clientId) async {
    final db = await DatabaseHelper.instance.client;
    final res = await db.query(
      "SELECT * FROM rides WHERE client_id = ? ORDER BY date DESC",
      [clientId],
    );
    return res.map((row) => Ride.fromMap(row)).toList();
  }

  Future<int> update(Ride ride) async {
    final db = await DatabaseHelper.instance.client;
    await db.execute(
      "UPDATE rides SET client_id = ?, value = ?, note = ?, date = ?, is_paid = ?, is_completed = ? WHERE id = ?",
      [ride.clientId, ride.value, ride.note, ride.date.toIso8601String(), ride.isPaid ? 1 : 0, ride.isCompleted ? 1 : 0, ride.id],
    );
    return 1;
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.client;
    await db.execute(
      "DELETE FROM rides WHERE id = ?",
      [id],
    );
    return 1;
  }
}
