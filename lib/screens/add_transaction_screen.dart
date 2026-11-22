import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  final String clientId;
  final TxType type;
  const AddTransactionScreen({
    super.key,
    required this.clientId,
    required this.type,
  });
  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amount = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = widget.type == TxType.credit;
    final color = isCredit ? AppColors.green : AppColors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text(isCredit ? 'دفع لي' : 'أخذ مني'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  isCredit
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: color,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  isCredit ? 'المبلغ اللي دفعه لك' : 'المبلغ اللي أخذه منك',
                  style: TextStyle(color: color.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('المبلغ (ج.م)',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _amount,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            decoration: const InputDecoration(hintText: '0.00'),
          ),
          const SizedBox(height: 16),
          const Text('ملاحظة (اختياري)',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _note,
            maxLines: 2,
            decoration: const InputDecoration(hintText: 'تفاصيل المعاملة'),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: Text(isCredit ? 'تأكيد الدفع' : 'تأكيد الاستلام',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final v = double.tryParse(_amount.text.trim());
    if (v == null || v <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل مبلغ صحيح')),
      );
      return;
    }
    final p = context.read<AppProvider>();
    await p.addTransaction(
      widget.clientId,
      Transaction(
        id: p.newTxId(),
        type: widget.type,
        amount: v,
        note: _note.text.trim(),
        date: DateTime.now(),
      ),
    );
    if (mounted) Navigator.pop(context);
  }
}
