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
            icon: const Icon(Icons.share_rounded),
            onPressed: () async {
              await PdfService.shareClientStatement(
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
                    backgroundColor: AppColors.card,
                    title: const Text('حذف العميل؟'),
                    content: const Text('سيتم حذف كل معاملاته نهائياً.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('إلغاء')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('حذف',
                              style: TextStyle(color: AppColors.red))),
                    ],
                  ),
                );
                if (ok == true) {
                  await context.read<AppProvider>().deleteClient(client.id);
                  if (context.mounted) Navigator.pop(context);
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'delete',
                child: Text('حذف العميل',
                    style: TextStyle(color: AppColors.red)),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          GlassCard(
            gradient: LinearGradient(
              colors: [
                (client.balance >= 0 ? AppColors.green : AppColors.red)
                    .withOpacity(0.25),
                AppColors.card,
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
                          style: const TextStyle(
                              color: AppColors.textDim, fontSize: 13)),
                    ),
                    Text(
                      client.balance >= 0 ? 'له' : 'عليه',
                      style: TextStyle(
                        color: client.balance >= 0
                            ? AppColors.green
                            : AppColors.red,
                        fontWeight: FontWeight.w700,
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
                        ? AppColors.green
                        : AppColors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone_rounded,
                        size: 14, color: AppColors.textDim),
                    const SizedBox(width: 4),
                    Text(client.phone,
                        style: const TextStyle(
                            color: AppColors.textDim, fontSize: 12)),
                  ],
                ),
                if (client.note != null && client.note!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('📝 ${client.note}',
                      style: const TextStyle(
                          color: AppColors.textDim, fontSize: 12)),
                ],
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1),

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _addTx(context, client.id, TxType.credit),
                  icon: const Icon(Icons.arrow_downward_rounded),
                  label: const Text('دفع لي'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _addTx(context, client.id, TxType.debit),
                  icon: const Icon(Icons.arrow_upward_rounded),
                  label: const Text('أخذ مني'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red.withOpacity(0.85),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 24),
          const Text('سجل المعاملات',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),

          if (txs.isEmpty)
            GlassCard(
              child: Column(
                children: const [
                  Icon(Icons.receipt_long_outlined,
                      color: AppColors.textDim, size: 40),
                  SizedBox(height: 8),
                  Text('لا توجد معاملات',
                      style: TextStyle(color: AppColors.textDim)),
                ],
              ),
            )
          else
            ...txs.map((t) {
              final isCredit = t.type == TxType.credit;
              return GlassCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isCredit ? AppColors.green : AppColors.red)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isCredit
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        color: isCredit ? AppColors.green : AppColors.red,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_fmt(t.amount)} ج.م — ${t.type.arVerb}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(_date(t.date),
                              style: const TextStyle(
                                  color: AppColors.textDim, fontSize: 11)),
                          if (t.note.isNotEmpty)
                            Text('📝 ${t.note}',
                                style: const TextStyle(
                                    color: AppColors.textDim, fontSize: 11)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.textDim, size: 20),
                      onPressed: () async {
                        await context
                            .read<AppProvider>()
                            .deleteTransaction(client.id, t.id);
                      },
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
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
