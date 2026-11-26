import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/client.dart';
import '../models/transaction.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/signature_pad.dart';
import '../widgets/receipt_preview.dart';
import 'add_transaction_screen.dart';
import 'edit_client_screen.dart';

class ClientDetailsScreen extends StatelessWidget {
  final String clientId;
  const ClientDetailsScreen({super.key, required this.clientId});

  String _fmt(double v) => NumberFormat('#,##0.00').format(v);
  String _date(DateTime d) => DateFormat('dd/MM/yyyy  hh:mm a').format(d);

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final client = p.clients.firstWhere((c) => c.id == clientId);
    final txs = client.transactions.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(client.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditClientScreen(clientId: client.id),
              ),
            ),
          ),
          IconButton(
            tooltip: 'مشاركة كشف الحساب',
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () async {
              final buf = StringBuffer();
              buf.writeln('كشف حساب — ${client.name}');
              buf.writeln('التاجر: ${p.merchantName}');
              buf.writeln('الهاتف: ${client.phone}');
              buf.writeln('الرصيد: ${client.balance.abs().toStringAsFixed(2)} ج.م (${client.balance >= 0 ? "له" : "عليه"})');
              buf.writeln('────────────────');
              for (final t in client.transactions.reversed) {
                buf.writeln('${DateFormat('dd/MM/yyyy HH:mm').format(t.date)} | ${t.type.arName} | ${t.amount.toStringAsFixed(2)} ج.م${t.note.isNotEmpty ? " | ${t.note}" : ""}');
              }
              buf.writeln('────────────────');
              buf.writeln('التوقيع: Mohamed Rabea');
              buf.writeln('Hamo Note');
              await Share.share(buf.toString());
            },
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'delete') {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: context.appCard,
                    title: Text('حذف العميل؟',
                        style: TextStyle(color: context.appText)),
                    content: Text('سيتم حذف كل معاملاته نهائياً.',
                        style: TextStyle(color: context.appTextDim)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('إلغاء')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('حذف',
                              style: TextStyle(color: context.appRed))),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  await context.read<AppProvider>().deleteClient(client.id);
                  if (context.mounted) Navigator.pop(context);
                }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'delete',
                child: Text('حذف العميل',
                    style: TextStyle(color: context.appRed)),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            gradient: LinearGradient(
              colors: [
                (client.balance >= 0 ? context.appGreen : context.appRed)
                    .withOpacity(0.25),
                context.appCard,
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(client.category.emoji,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(client.category.arName,
                          style: TextStyle(
                              color: context.appTextDim, fontSize: 13)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            (client.balance >= 0 ? context.appGreen : context.appRed)
                                .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        client.balance == 0
                            ? '✅ متساوي'
                            : (client.balance >= 0 ? 'له' : 'عليه'),
                        style: TextStyle(
                          color: client.balance == 0
                              ? context.appTextDim
                              : (client.balance >= 0
                                  ? context.appGreen
                                  : context.appRed),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${_fmt(client.balance.abs())} ج.م',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: client.balance >= 0
                        ? context.appGreen
                        : context.appRed,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone_rounded,
                        size: 14, color: context.appTextDim),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(client.phone,
                          style: TextStyle(
                              color: context.appTextDim, fontSize: 12)),
                    ),
                    IconButton(
                      tooltip: 'اتصال',
                      icon: Icon(Icons.call_rounded,
                          size: 20, color: context.appGreen),
                      onPressed: () async {
                        final uri = Uri(scheme: 'tel', path: client.phone);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                    ),
                    IconButton(
                      tooltip: 'واتساب',
                      icon: Icon(Icons.chat_rounded,
                          size: 20, color: context.appGold),
                      onPressed: () async {
                        final bal = client.balance;
                        final status = bal == 0
                            ? 'متساوي'
                            : (bal > 0
                                ? 'لك مبلغ ${bal.abs().toStringAsFixed(2)} ج.م'
                                : 'عليك مبلغ ${bal.abs().toStringAsFixed(2)} ج.م');
                        final msg = Uri.encodeComponent(
                            'مرحباً ${client.name} 👋\n'
                            'رصيدك الحالي لدى ${p.merchantName}: $status\n'
                            '— عبر Hamo Note');
                        final phone = client.phone.replaceAll(RegExp(r'[^0-9+]'), '');
                        final uri = Uri.parse('https://wa.me/$phone?text=$msg');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                    IconButton(
                      tooltip: 'مشاركة الرصيد نصاً',
                      icon: Icon(Icons.share_rounded,
                          size: 20, color: context.appTextDim),
                      onPressed: () {
                        final bal = client.balance;
                        final status = bal == 0
                            ? 'متساوي'
                            : (bal > 0
                                ? 'له ${bal.abs().toStringAsFixed(2)} ج.م'
                                : 'عليه ${bal.abs().toStringAsFixed(2)} ج.م');
                        Share.share(
                          'عميل: ${client.name}\nهاتف: ${client.phone}\nالرصيد: $status\nالتاجر: ${p.merchantName}',
                        );
                      },
                    ),
                  ],
                ),
                if (client.note != null && client.note!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('📝 ${client.note}',
                      style: TextStyle(
                          color: context.appTextDim, fontSize: 12)),
                ],
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1),

          const SizedBox(height: 14),

          if (client.balance != 0) _settlementCard(context, p, client),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _addTx(context, client.id, TxType.credit),
                  icon: const Icon(Icons.arrow_downward_rounded),
                  label: const Text('دفع لي'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _addTx(context, client.id, TxType.debit),
                  icon: const Icon(Icons.arrow_upward_rounded),
                  label: const Text('أخذ مني'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.appRed.withOpacity(0.9),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.receipt_long_rounded,
                  size: 18, color: context.appGreen),
              const SizedBox(width: 6),
              Text('سجل المعاملات (${txs.length})',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.appText)),
            ],
          ),
          const SizedBox(height: 10),

          if (txs.isEmpty)
            GlassCard(
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined,
                      color: context.appTextDim, size: 40),
                  const SizedBox(height: 8),
                  Text('لا توجد معاملات',
                      style: TextStyle(color: context.appTextDim)),
                ],
              ),
            )
          else
            ...txs.map((t) => _txTile(context, p, client, t)),
        ],
      ),
    );
  }

  Widget _settlementCard(BuildContext context, AppProvider p, Client client) {
    final isCredit = client.balance > 0;
    final color = isCredit ? context.appGreen : context.appGold;
    final label = isCredit ? 'تم التسليم' : 'أخذت';
    final icon = isCredit
        ? Icons.check_circle_rounded
        : Icons.done_all_rounded;
    final subtitle = isCredit
        ? 'سلّمت للعميل ${_fmt(client.balance)} ج.م'
        : 'أخذت من العميل ${_fmt(client.balance.abs())} ج.م';

    return GlassCard(
      gradient: LinearGradient(
        colors: [color.withOpacity(0.25), context.appCard],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: color.withOpacity(0.5),
      padding: const EdgeInsets.all(18),
      onTap: () => _settle(context, p, client, isCredit ? TxType.debit : TxType.credit),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: color)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12, color: context.appTextDim)),
              ],
            ),
          ),
          Icon(Icons.arrow_back_ios_rounded,
              size: 16, color: context.appTextDim),
        ],
      ),
    ).animate().shimmer(
          duration: const Duration(seconds: 3),
          color: color.withOpacity(0.15),
        );
  }

  Widget _txTile(
      BuildContext context, AppProvider p, Client client, Transaction t) {
    final isCredit = t.type == TxType.credit;
    final color = isCredit ? context.appGreen : context.appRed;
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              t.isSettlement
                  ? Icons.verified_rounded
                  : (isCredit
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded),
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${_fmt(t.amount)} ج.م',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: context.appText),
                    ),
                    if (t.isSettlement)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('تسوية',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: color)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(_date(t.date),
                    style: TextStyle(
                        color: context.appTextDim, fontSize: 11)),
                if (t.note.isNotEmpty)
                  Text('📝 ${t.note}',
                      style: TextStyle(
                          color: context.appTextDim, fontSize: 11)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'مشاركة وصل كصورة',
            icon: Icon(Icons.share_rounded,
                color: context.appTextDim, size: 20),
            onPressed: () async {
              await _shareReceipt(context, p, client, t);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                color: context.appTextDim, size: 20),
            onPressed: () => context
                .read<AppProvider>()
                .deleteTransaction(client.id, t.id),
          ),
        ],
      ),
    );
  }

  Future<void> _settle(
    BuildContext ctx,
    AppProvider p,
    Client client,
    TxType type,
  ) async {
    final amount = client.balance.abs();
    final noteCtrl = TextEditingController();
    final isDeliver = type == TxType.debit;
    final color = isDeliver ? ctx.appGreen : ctx.appGold;
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (dctx) => AlertDialog(
        backgroundColor: ctx.appCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(
            isDeliver ? Icons.check_circle_rounded : Icons.done_all_rounded,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            isDeliver ? 'تأكيد تم التسليم' : 'تأكيد أخذت',
            style: TextStyle(color: ctx.appText, fontSize: 17),
          ),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(children: [
                Text(
                  isDeliver ? 'هتسلّم' : 'هتاخد',
                  style: TextStyle(color: ctx.appTextDim, fontSize: 12),
                ),
                Text('${amount.toStringAsFixed(2)} ج.م',
                    style: TextStyle(
                        color: color,
                        fontSize: 24,
                        fontWeight: FontWeight.w900)),
              ]),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: noteCtrl,
              style: TextStyle(color: ctx.appText),
              decoration: const InputDecoration(hintText: 'ملاحظة (اختياري)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dctx, false),
              child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: color, foregroundColor: Colors.black),
            onPressed: () => Navigator.pop(dctx, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await p.addTransaction(
        client.id,
        Transaction(
          id: p.newTxId(),
          type: type,
          amount: amount,
          note: noteCtrl.text.trim().isEmpty
              ? 'تسوية كاملة'
              : noteCtrl.text.trim(),
          date: DateTime.now(),
          isSettlement: true,
        ),
      );
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: const Text('✅ تم الحفظ بنجاح'),
            backgroundColor: color,
          ),
        );
      }
    }
  }


  Future<void> _shareReceipt(
    BuildContext context,
    AppProvider p,
    Client client,
    Transaction t,
  ) async {
    await ReceiptPreview.showAndShare(
      context: context,
      client: client,
      transaction: t,
      merchantName: p.merchantName,
      merchantPhone: p.merchantPhone,
      merchantAddress: p.merchantAddress,
      currentBalance: client.balance,
    );
  }

  void _addTx(BuildContext ctx, String id, TxType type) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(clientId: id, type: type),
      ),
    );
  }
}
