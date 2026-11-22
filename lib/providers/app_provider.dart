import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/client.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  final _storage = StorageService();

  List<Client> clients = [];
  List<Transaction> merchantTx = [];
  String merchantName = 'Hamo';
  ThemeMode themeMode = ThemeMode.dark;
  bool onboardingShown = false;
  bool loading = true;

  double get totalCredit => clients
      .where((c) => c.balance > 0)
      .fold(0.0, (s, c) => s + c.balance);

  double get totalDebit => clients
      .where((c) => c.balance < 0)
      .fold(0.0, (s, c) => s + c.balance.abs());

  double get netBalance => totalCredit - totalDebit;

  double get merchantBalance {
    double b = 0;
    for (final t in merchantTx) b += t.signedAmount;
    return b;
  }

  Future<void> init() async {
    clients = await _storage.loadClients();
    merchantTx = await _storage.loadMerchantTx();
    merchantName = await _storage.loadMerchantName();
    final sp = await SharedPreferences.getInstance();
    final modeStr = sp.getString('hmn_theme_mode') ?? 'dark';
    themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == modeStr,
      orElse: () => ThemeMode.dark,
    );
    onboardingShown = sp.getBool('hmn_onboarding_shown') ?? false;
    loading = false;
    notifyListeners();
  }

  String _uid() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('hmn_theme_mode', mode.name);
    notifyListeners();
  }

  Future<void> setOnboardingShown(bool v) async {
    onboardingShown = v;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('hmn_onboarding_shown', v);
    notifyListeners();
  }

  Future<void> addClient({
    required String name,
    required String phone,
    required ClientCategory category,
    String? note,
  }) async {
    clients.add(Client(
      id: _uid(),
      name: name,
      phone: phone,
      category: category,
      note: note,
      createdAt: DateTime.now(),
    ));
    await _storage.saveClients(clients);
    notifyListeners();
  }

  Future<void> updateClient(Client client) async {
    final i = clients.indexWhere((c) => c.id == client.id);
    if (i != -1) {
      clients[i] = client;
      await _storage.saveClients(clients);
      notifyListeners();
    }
  }

  Future<void> deleteClient(String id) async {
    clients.removeWhere((c) => c.id == id);
    await _storage.saveClients(clients);
    notifyListeners();
  }

  Future<void> addTransaction(String clientId, Transaction tx) async {
    final c = clients.firstWhere((e) => e.id == clientId);
    c.transactions.add(tx);
    await _storage.saveClients(clients);
    notifyListeners();
  }

  Future<void> deleteTransaction(String clientId, String txId) async {
    final c = clients.firstWhere((e) => e.id == clientId);
    c.transactions.removeWhere((t) => t.id == txId);
    await _storage.saveClients(clients);
    notifyListeners();
  }

  Future<void> addMerchantTx(Transaction tx) async {
    merchantTx.add(tx);
    await _storage.saveMerchantTx(merchantTx);
    notifyListeners();
  }

  Future<void> deleteMerchantTx(String id) async {
    merchantTx.removeWhere((t) => t.id == id);
    await _storage.saveMerchantTx(merchantTx);
    notifyListeners();
  }

  Future<void> setMerchantName(String name) async {
    merchantName = name;
    await _storage.saveMerchantName(name);
    notifyListeners();
  }

  String newTxId() => _uid();

  Future<void> reset() async {
    await _storage.clearAll();
    clients = [];
    merchantTx = [];
    merchantName = 'Hamo';
    themeMode = ThemeMode.dark;
    onboardingShown = false;
    notifyListeners();
  }
}
