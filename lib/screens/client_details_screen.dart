import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../models/transaction.dart';
import '../models/client.dart';
import '../services/pdf_service.dart';
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
            tooltip: 'مشاركة كشف الحساب PDF',
            icon: const Icon(Icons.picture_as_pdf_rounded),
            onPressed: () async {
              await PdfService.shareStatement(
                client: client,
                merchantName: p.merchantName,
              );
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
          // Balance header
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
                    Text(client.phone,
                        style: TextStyle(
                            color: context.appTextDim, fontSize: 12)),
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

          // Settlement big action (if not zero)
          if (client.balance != 0) _settlementCard(context, p, client),

          const SizedBox(height: 14),

          // Regular actions
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
            tooltip: 'مشاركة وصل',
            icon: Icon(Icons.share_rounded,
                color: context.appTextDim, size: 20),
            onPressed: () => PdfService.shareReceipt(
              client: client,
              transaction: t,
              merchantName: p.merchantName,
              currentBalance: client.balance,
            ),
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
            content: Text('✅ تم الحفظ بنجاح'),
            backgroundColor: color,
          ),
        );
      }
    }
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
