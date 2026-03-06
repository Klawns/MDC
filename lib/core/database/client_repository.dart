
import '../models/client.dart';
import 'database_helper.dart';

class ClientRepository {
  Future<Client> create(Client client) async {
    final db = await DatabaseHelper.instance.database;
    final id = await db.insert('clients', client.toMap());
    return client.copyWith(id: id);
  }

  Future<Client?> getById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Client.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Client>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('clients', orderBy: 'name ASC');
    return result.map((json) => Client.fromMap(json)).toList();
  }

  Future<int> update(Client client) async {
    final db = await DatabaseHelper.instance.database;
    return db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
