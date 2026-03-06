import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TursoHttpClient {
  final String url;
  final String token;

  TursoHttpClient({required this.url, required this.token});

  Future<Map<String, dynamic>> execute(String sql, [List<dynamic> args = const []]) async {
    final uri = Uri.parse(url.replaceFirst('libsql://', 'https://') + '/v2/pipeline');
    
    // Formatting args for Turso API
    final formattedArgs = args.map((arg) {
      if (arg is int || arg is double) {
        return {"type": "float", "value": arg.toString()};
      } else if (arg == null) {
        return {"type": "null"};
      }
      return {"type": "text", "value": arg.toString()};
    }).toList();

    final body = {
      "requests": [
        {
          "type": "execute",
          "stmt": {
            "sql": sql,
            "args": formattedArgs,
            "named_args": []
          }
        },
        {
          "type": "close"
        }
      ]
    };

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final results = jsonResponse['results'] as List<dynamic>;
      
      if (results.isNotEmpty && results[0]['type'] == 'ok') {
        final res = results[0]['response']['result'];
        return res;
      } else {
        throw Exception("Turso Error: \${results[0]['error']?['message'] ?? 'Unknown Error'}");
      }
    } else {
      throw Exception("HTTP Error \${response.statusCode}: \${response.body}");
    }
  }

  // Helper method to execute and turn the column-based response into List of maps
  Future<List<Map<String, dynamic>>> query(String sql, [List<dynamic> args = const []]) async {
    final result = await execute(sql, args);
    
    if (result == null || result['cols'] == null || result['rows'] == null) {
      return [];
    }

    final cols = (result['cols'] as List<dynamic>).map((c) => c['name']).toList();
    final rows = result['rows'] as List<dynamic>;

    final List<Map<String, dynamic>> mappedRows = [];
    for (var row in rows) {
      final map = <String, dynamic>{};
      for (int i = 0; i < cols.length; i++) {
        final valNode = row[i];
        var val = valNode['value'];
        
        // Handle Turso's JSON format ({ "type": "...", "value": ... })
        if (valNode['type'] == 'float' || valNode['type'] == 'integer') {
          // Both returned as strings from turso sometimes, parse it
          val = num.tryParse(val.toString());
          if (val != null && val % 1 == 0) {
             val = val.toInt();
          }
        }
        
        map[cols[i] as String] = val;
      }
      mappedRows.add(map);
    }
    return mappedRows;
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static TursoHttpClient? _client;

  DatabaseHelper._init();

  Future<TursoHttpClient> get client async {
    if (_client != null) return _client!;
    _client = await _initDB();
    return _client!;
  }

  Future<TursoHttpClient> _initDB() async {
    final url = dotenv.env['TURSO_URL'] ?? '';
    final token = dotenv.env['TURSO_AUTH_TOKEN'] ?? '';
    
    final dbClient = TursoHttpClient(url: url, token: token);
    
    await _createDB(dbClient);
    
    return dbClient;
  }

  Future<void> _createDB(TursoHttpClient db) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNull = 'TEXT';
    const realType = 'REAL NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';

    await db.execute('''
    CREATE TABLE IF NOT EXISTS clients (
      id $idType,
      name $textType,
      phone $textTypeNull,
      notes $textTypeNull
    )
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS rides (
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
    CREATE TABLE IF NOT EXISTS config (
      id $idType,
      value1 $realType,
      value2 $realType,
      value3 $realType,
      value4 $realType
    )
    ''');

    final configRes = await db.query('SELECT count(*) as count FROM config');
    int count = 0;
    if (configRes.isNotEmpty) {
        count = configRes.first['count'] as int? ?? 0;
    }
    
    if (count == 0) {
      await db.execute(
        "INSERT INTO config (value1, value2, value3, value4) VALUES (?, ?, ?, ?)", 
        [10.0, 15.0, 20.0, 25.0]
      );
    }
  }

  Future<void> close() async {
    // No-op for HTTP client
  }
}
