class Ride {
  final int? id;
  final int clientId;
  final double value;
  final String? note;
  final DateTime date;
  final bool isPaid;
  final bool isCompleted;

  Ride({
    this.id,
    required this.clientId,
    required this.value,
    this.note,
    required this.date,
    required this.isPaid,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'client_id': clientId,
      'value': value,
      'note': note,
      'date': date.toIso8601String(),
      'is_paid': isPaid ? 1 : 0,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory Ride.fromMap(Map<String, dynamic> map) {
    return Ride(
      id: map['id'],
      clientId: map['client_id'],
      value: map['value'],
      note: map['note'],
      date: DateTime.parse(map['date']),
      isPaid: map['is_paid'] == 1,
      isCompleted: map['is_completed'] == 1,
    );
  }

  Ride copyWith({
    int? id,
    int? clientId,
    double? value,
    String? note,
    DateTime? date,
    bool? isPaid,
    bool? isCompleted,
  }) {
    return Ride(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      value: value ?? this.value,
      note: note ?? this.note,
      date: date ?? this.date,
      isPaid: isPaid ?? this.isPaid,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
