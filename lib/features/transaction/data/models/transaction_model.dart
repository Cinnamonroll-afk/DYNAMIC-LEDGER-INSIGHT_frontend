class TransactionModel {
  final String id;
  final String userId;
  final String type;
  final double amount;
  final String category;
  final String note;
  final DateTime date;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel(
      id: id,
      userId: map['user_id'] as String? ?? '',
      type: map['type'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] as String? ?? '',
      note: map['note'] as String? ?? '',
      date: map['date'] != null ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'type': type,
      'amount': amount,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),
    };
  }
}
