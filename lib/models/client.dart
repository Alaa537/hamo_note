import 'transaction.dart';

enum ClientCategory { vodafone, orange, etisalat, we, other }

extension ClientCategoryX on ClientCategory {
  String get arName {
    switch (this) {
      case ClientCategory.vodafone: return 'فودافون';
      case ClientCategory.orange: return 'أورنج';
      case ClientCategory.etisalat: return 'اتصالات';
      case ClientCategory.we: return 'WE';
      case ClientCategory.other: return 'أخرى';
    }
  }
  String get emoji {
    switch (this) {
      case ClientCategory.vodafone: return '🔴';
      case ClientCategory.orange: return '🟠';
      case ClientCategory.etisalat: return '🟢';
      case ClientCategory.we: return '🟣';
      case ClientCategory.other: return '⚪';
    }
  }
}

class Client {
  final String id;
  String name;
  String phone;
  ClientCategory category;
  String? note;
  final DateTime createdAt;
  List<Transaction> transactions;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.category,
    this.note,
    required this.createdAt,
    List<Transaction>? transactions,
  }) : transactions = transactions ?? [];

  double get balance {
    double b = 0;
    for (final t in transactions) {
      b += t.signedAmount;
    }
    return b;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'category': category.index,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
    'transactions': transactions.map((e) => e.toJson()).toList(),
  };

  factory Client.fromJson(Map<String, dynamic> j) => Client(
    id: j['id'],
    name: j['name'],
    phone: j['phone'],
    category: ClientCategory.values[j['category'] ?? 0],
    note: j['note'],
    createdAt: DateTime.parse(j['createdAt']),
    transactions: (j['transactions'] as List? ?? [])
        .map((e) => Transaction.fromJson(e))
        .toList(),
  );
}
