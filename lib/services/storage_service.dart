import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/client.dart';
import '../models/transaction.dart';

class StorageService {
  static const _kClients = 'hmn_clients';
  static const _kMerchantTx = 'hmn_merchant_tx';
  static const _kMerchantName = 'hmn_merchant_name';

  Future<List<Client>> loadClients() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kClients);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Client.fromJson(e)).toList();
  }

  Future<void> saveClients(List<Client> clients) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kClients, jsonEncode(clients.map((e) => e.toJson()).toList()));
  }

  Future<List<Transaction>> loadMerchantTx() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kMerchantTx);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Transaction.fromJson(e)).toList();
  }

  Future<void> saveMerchantTx(List<Transaction> tx) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kMerchantTx, jsonEncode(tx.map((e) => e.toJson()).toList()));
  }

  Future<String> loadMerchantName() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kMerchantName) ?? 'Hamo';
  }

  Future<void> saveMerchantName(String name) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kMerchantName, name);
  }

  Future<void> clearAll() async {
    final sp = await SharedPreferences.getInstance();
    await sp.clear();
  }
}
