class Client {
  final int? id;
  final String name;
  final String? phone;
  final String? notes;

  Client({
    this.id,
    required this.name,
    this.phone,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'notes': notes,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      notes: map['notes'],
    );
  }

  Client copyWith({
    int? id,
    String? name,
    String? phone,
    String? notes,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
    );
  }
}
