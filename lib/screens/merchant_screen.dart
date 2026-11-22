import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../models/transaction.dart';

class MerchantScreen extends StatefulWidget {
  const MerchantScreen({super.key});
  @override
  State<MerchantScreen> createState() => _MerchantScreenState();
}

class _MerchantScreenState extends State<MerchantScreen> {
  String _fmt(double v) => NumberFormat('#,##0.00').format(v);
  String _date(DateTime d) => DateFormat('dd/MM/yyyy hh:mm a').format(d);

  Future<void> _add(TxType type) async {
    final ctrl = TextEditingController();
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(type == TxType.credit ? 'إيداع / دخل' : 'مصروف / سحب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'المبلغ'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: note,
              decoration: const InputDecoration(hintText: 'ملاحظة'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حفظ')),
        ],
      ),
    );
    if (ok == true && mounted) {
      final v = double.tryParse(ctrl.text.trim());
      if (v == null || v <= 0) return;
      final p = context.read<AppProvider>();
      await p.addMerchantTx(Transaction(
        id: p.newTxId(),
        type: type,
        amount: v,
        note: note.text.trim(),
        date: DateTime.now(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final tx = p.merchantTx.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي (التاجر)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            gradient: LinearGradient(
              colors: [AppColors.gold.withOpacity(0.25), AppColors.card],
            ),
            borderColor: AppColors.gold.withOpacity(0.4),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.storefront_rounded,
                        color: AppColors.gold, size: 22),
                    SizedBox(width: 8),
                    Text('رصيد التاجر',
                        style: TextStyle(
                            color: AppColors.textDim, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '${_fmt(p.merchantBalance.abs())} ج.م',
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.gold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _add(TxType.credit),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('إيداع'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _add(TxType.debit),
                  icon: const Icon(Icons.remove_rounded),
                  label: const Text('مصروف'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red.withOpacity(0.85),
                      foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('سجل الحركات',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          if (tx.isEmpty)
            GlassCard(
              child: Column(
                children: const [
                  Icon(Icons.receipt_long_outlined,
                      color: AppColors.textDim, size: 40),
                  SizedBox(height: 8),
                  Text('لا توجد حركات',
                      style: TextStyle(color: AppColors.textDim)),
                ],
              ),
            )
          else
            ...tx.map((t) {
              final isCredit = t.type == TxType.credit;
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(
                      isCredit
                          ? Icons.add_circle_rounded
                          : Icons.remove_circle_rounded,
                      color: isCredit ? AppColors.green : AppColors.red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${_fmt(t.amount)} ج.م',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                          Text(_date(t.date),
                              style: const TextStyle(
                                  color: AppColors.textDim, fontSize: 11)),
                          if (t.note.isNotEmpty)
                            Text(t.note,
                                style: const TextStyle(
                                    color: AppColors.textDim, fontSize: 11)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.textDim, size: 20),
                      onPressed: () =>
                          context.read<AppProvider>().deleteMerchantTx(t.id),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
