import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/client.dart';
import '../models/transaction.dart';
import '../models/note.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  final _storage = StorageService();

  List<Client> clients = [];
  List<Transaction> merchantTx = [];
  List<Note> notes = [];
  String merchantName = 'Hamo';
  String merchantPhone = '';
  String merchantAddress = '';
  String? pinCode;
  bool pinEnabled = false;
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
    for (final t in merchantTx) {
      b += t.signedAmount;
    }
    return b;
  }

  int get pinnedNotesCount => notes.where((n) => n.pinned).length;

  Future<void> init() async {
    clients = await _storage.loadClients();
    merchantTx = await _storage.loadMerchantTx();
    notes = await _storage.loadNotes();
    merchantName = await _storage.loadMerchantName();
    merchantPhone = await _storage.loadMerchantPhone();
    merchantAddress = await _storage.loadMerchantAddress();
    final sp = await SharedPreferences.getInstance();
    final modeStr = sp.getString('hmn_theme_mode') ?? 'dark';
    themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == modeStr,
      orElse: () => ThemeMode.dark,
    );
    onboardingShown = sp.getBool('hmn_onboarding_shown') ?? false;
    pinEnabled = sp.getBool('hmn_pin_enabled') ?? false;
    pinCode = sp.getString('hmn_pin');
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

  Future<void> setMerchantPhone(String phone) async {
    merchantPhone = phone;
    await _storage.saveMerchantPhone(phone);
    notifyListeners();
  }

  Future<void> setMerchantAddress(String address) async {
    merchantAddress = address;
    await _storage.saveMerchantAddress(address);
    notifyListeners();
  }

  // ─── Notes ───────────────────────────────────────────────
  Future<void> addNote({
    required String title,
    required String content,
    int colorIndex = 0,
  }) async {
    notes.insert(
      0,
      Note(
        id: _uid(),
        title: title,
        content: content,
        createdAt: DateTime.now(),
        colorIndex: colorIndex,
      ),
    );
    await _storage.saveNotes(notes);
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    final i = notes.indexWhere((n) => n.id == note.id);
    if (i != -1) {
      note.updatedAt = DateTime.now();
      notes[i] = note;
      await _storage.saveNotes(notes);
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    notes.removeWhere((n) => n.id == id);
    await _storage.saveNotes(notes);
    notifyListeners();
  }

  Future<void> togglePinNote(String id) async {
    final i = notes.indexWhere((n) => n.id == id);
    if (i != -1) {
      notes[i].pinned = !notes[i].pinned;
      notes[i].updatedAt = DateTime.now();
      notes.sort((a, b) {
        if (a.pinned == b.pinned) {
          return b.updatedAt.compareTo(a.updatedAt);
        }
        return a.pinned ? -1 : 1;
      });
      await _storage.saveNotes(notes);
      notifyListeners();
    }
  }


  Future<void> setPin(String? pin, {bool enabled = false}) async {
    final sp = await SharedPreferences.getInstance();
    if (pin == null || pin.isEmpty) {
      pinEnabled = false;
      pinCode = null;
      await sp.setBool('hmn_pin_enabled', false);
      await sp.remove('hmn_pin');
    } else {
      pinCode = pin;
      pinEnabled = enabled;
      await sp.setString('hmn_pin', pin);
      await sp.setBool('hmn_pin_enabled', enabled);
    }
    notifyListeners();
  }

  bool verifyPin(String input) => pinCode != null && pinCode == input;

  Future<void> restoreBackup({
    required String merchantName,
    required String merchantPhone,
    required String merchantAddress,
    required List<Client> clients,
    required List<Transaction> merchantTx,
    required List<Note> notes,
  }) async {
    this.merchantName = merchantName;
    this.merchantPhone = merchantPhone;
    this.merchantAddress = merchantAddress;
    this.clients = List<Client>.from(clients);
    this.merchantTx = List<Transaction>.from(merchantTx);
    this.notes = List<Note>.from(notes);
    await _storage.saveMerchantName(merchantName);
    await _storage.saveMerchantPhone(merchantPhone);
    await _storage.saveMerchantAddress(merchantAddress);
    await _storage.saveClients(this.clients);
    await _storage.saveMerchantTx(this.merchantTx);
    await _storage.saveNotes(this.notes);
    notifyListeners();
  }

  String newTxId() => _uid();

  Future<void> reset() async {
    await _storage.clearAll();
    clients = [];
    merchantTx = [];
    notes = [];
    merchantName = 'Hamo';
    merchantPhone = '';
    merchantAddress = '';
    // keep PIN settings
    themeMode = ThemeMode.dark;
    onboardingShown = false;
    notifyListeners();
  }
}
