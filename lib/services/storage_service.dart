import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/client.dart';
import '../models/transaction.dart';
import '../models/note.dart';

class StorageService {
  static const _kClients = 'hmn_clients';
  static const _kMerchantTx = 'hmn_merchant_tx';
  static const _kMerchantName = 'hmn_merchant_name';
  static const _kNotes = 'hmn_notes';
  static const _kMerchantPhone = 'hmn_merchant_phone';
  static const _kMerchantAddress = 'hmn_merchant_address';

  Future<List<Client>> loadClients() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kClients);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Client.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveClients(List<Client> clients) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
        _kClients, jsonEncode(clients.map((e) => e.toJson()).toList()));
  }

  Future<List<Transaction>> loadMerchantTx() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kMerchantTx);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveMerchantTx(List<Transaction> tx) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
        _kMerchantTx, jsonEncode(tx.map((e) => e.toJson()).toList()));
  }

  Future<String> loadMerchantName() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kMerchantName) ?? 'Hamo';
  }

  Future<void> saveMerchantName(String name) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kMerchantName, name);
  }

  Future<String> loadMerchantPhone() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kMerchantPhone) ?? '';
  }

  Future<void> saveMerchantPhone(String phone) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kMerchantPhone, phone);
  }

  Future<String> loadMerchantAddress() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kMerchantAddress) ?? '';
  }

  Future<void> saveMerchantAddress(String address) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kMerchantAddress, address);
  }

  Future<List<Note>> loadNotes() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kNotes);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveNotes(List<Note> notes) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
        _kNotes, jsonEncode(notes.map((e) => e.toJson()).toList()));
  }

  Future<void> clearAll() async {
    final sp = await SharedPreferences.getInstance();
    await sp.clear();
  }
}
