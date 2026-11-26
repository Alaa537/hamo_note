import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/client.dart';
import '../models/transaction.dart';
import '../models/note.dart';

class BackupPayload {
  final String version;
  final DateTime exportedAt;
  final String merchantName;
  final String merchantPhone;
  final String merchantAddress;
  final List<Client> clients;
  final List<Transaction> merchantTx;
  final List<Note> notes;

  BackupPayload({
    required this.version,
    required this.exportedAt,
    required this.merchantName,
    required this.merchantPhone,
    required this.merchantAddress,
    required this.clients,
    required this.merchantTx,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
        'version': version,
        'exportedAt': exportedAt.toIso8601String(),
        'merchantName': merchantName,
        'merchantPhone': merchantPhone,
        'merchantAddress': merchantAddress,
        'clients': clients.map((e) => e.toJson()).toList(),
        'merchantTx': merchantTx.map((e) => e.toJson()).toList(),
        'notes': notes.map((e) => e.toJson()).toList(),
      };

  factory BackupPayload.fromJson(Map<String, dynamic> j) => BackupPayload(
        version: j['version'] as String? ?? '1',
        exportedAt: DateTime.tryParse(j['exportedAt'] as String? ?? '') ??
            DateTime.now(),
        merchantName: j['merchantName'] as String? ?? 'Hamo',
        merchantPhone: j['merchantPhone'] as String? ?? '',
        merchantAddress: j['merchantAddress'] as String? ?? '',
        clients: (j['clients'] as List? ?? [])
            .map((e) => Client.fromJson(e as Map<String, dynamic>))
            .toList(),
        merchantTx: (j['merchantTx'] as List? ?? [])
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList(),
        notes: (j['notes'] as List? ?? [])
            .map((e) => Note.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class BackupService {
  static Future<File> exportToFile({
    required String merchantName,
    required String merchantPhone,
    required String merchantAddress,
    required List<Client> clients,
    required List<Transaction> merchantTx,
    required List<Note> notes,
  }) async {
    final payload = BackupPayload(
      version: '1.1',
      exportedAt: DateTime.now(),
      merchantName: merchantName,
      merchantPhone: merchantPhone,
      merchantAddress: merchantAddress,
      clients: clients,
      merchantTx: merchantTx,
      notes: notes,
    );
    final dir = await getTemporaryDirectory();
    final name =
        'HamoNote_Backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${dir.path}/$name');
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload.toJson()),
    );
    return file;
  }

  static Future<void> shareBackup({
    required String merchantName,
    required String merchantPhone,
    required String merchantAddress,
    required List<Client> clients,
    required List<Transaction> merchantTx,
    required List<Note> notes,
  }) async {
    final file = await exportToFile(
      merchantName: merchantName,
      merchantPhone: merchantPhone,
      merchantAddress: merchantAddress,
      clients: clients,
      merchantTx: merchantTx,
      notes: notes,
    );
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'نسخة احتياطية من Hamo Note',
    );
  }

  static BackupPayload parse(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    return BackupPayload.fromJson(j);
  }
}
