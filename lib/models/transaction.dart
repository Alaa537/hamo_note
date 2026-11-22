enum TxType { credit, debit }

extension TxTypeX on TxType {
  String get arName => this == TxType.credit ? 'له' : 'عليه';
  String get arVerb => this == TxType.credit ? 'دفع لك' : 'أخذ منك';
}

class Transaction {
  final String id;
  final TxType type;
  final double amount;
  final String note;
  final DateTime date;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    this.note = '',
    required this.date,
  });

  double get signedAmount => type == TxType.credit ? amount : -amount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'amount': amount,
    'note': note,
    'date': date.toIso8601String(),
  };

  factory Transaction.fromJson(Map<String, dynamic> j) => Transaction(
    id: j['id'],
    type: TxType.values[j['type'] ?? 0],
    amount: (j['amount'] as num).toDouble(),
    note: j['note'] ?? '',
    date: DateTime.parse(j['date']),
  );
}
