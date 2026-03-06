import '../models/client.dart';
import 'database_helper.dart';

class ClientRepository {
  Future<Client> create(Client client) async {
    final db = await DatabaseHelper.instance.client;
    await db.execute(
      "INSERT INTO clients (name, phone, notes) VALUES (?, ?, ?)",
      [client.name, client.phone, client.notes],
    );
    
    final res = await db.query("SELECT * FROM clients ORDER BY id DESC LIMIT 1");
    if (res.isNotEmpty) {
      return Client.fromMap(res.first);
    }
    return client; // Fallback if insert selection fails (shouldn't happen)
  }

  Future<Client?> getById(int id) async {
    final db = await DatabaseHelper.instance.client;
    final res = await db.query(
      "SELECT * FROM clients WHERE id = ?",
       [id],
    );

    if (res.isNotEmpty) {
      return Client.fromMap(res.first);
    }
    return null;
  }

  Future<List<Client>> getAll() async {
    final db = await DatabaseHelper.instance.client;
    final res = await db.query("SELECT * FROM clients ORDER BY name ASC");
    return res.map((row) => Client.fromMap(row)).toList();
  }

  Future<int> update(Client client) async {
    final db = await DatabaseHelper.instance.client;
    await db.execute(
      "UPDATE clients SET name = ?, phone = ?, notes = ? WHERE id = ?",
      [client.name, client.phone, client.notes, client.id],
    );
    return 1;
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.client;
    await db.execute(
      "DELETE FROM clients WHERE id = ?",
      [id],
    );
    return 1;
  }
}
