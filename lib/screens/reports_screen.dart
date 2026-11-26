import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_provider.dart';
import '../models/client.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'client_details_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  String _fmt(double v) => NumberFormat('#,##0.00').format(v);

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    int monthTxCount = 0;
    double monthIn = 0;
    double monthOut = 0;
    for (final c in p.clients) {
      for (final t in c.transactions) {
        if (!t.date.isBefore(monthStart)) {
          monthTxCount++;
          if (t.type == TxType.credit) {
            monthIn += t.amount;
          } else {
            monthOut += t.amount;
          }
        }
      }
    }

    final debtors = p.clients.where((c) => c.balance < 0).toList()
      ..sort((a, b) => a.balance.compareTo(b.balance));
    final creditors = p.clients.where((c) => c.balance > 0).toList()
      ..sort((a, b) => b.balance.compareTo(a.balance));

    final aging = <Client>[];
    for (final c in p.clients.where((c) => c.balance < 0)) {
      if (c.transactions.isEmpty) continue;
      final last = c.transactions
          .map((t) => t.date)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      if (now.difference(last).inDays >= 30) aging.add(c);
    }

    final catMap = <ClientCategory, int>{};
    for (final c in p.clients) {
      catMap[c.category] = (catMap[c.category] ?? 0) + 1;
    }

    final monthLabel = DateFormat('MM/yyyy').format(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير والإحصائيات'),
        actions: [
          IconButton(
            tooltip: 'مشاركة الملخص',
            icon: Icon(Icons.share_rounded, color: context.appGold),
            onPressed: () => _shareSummary(context, p),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            gradient: LinearGradient(
              colors: [
                context.appGold.withOpacity(0.22),
                context.appCard,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderColor: context.appGold.withOpacity(0.4),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: context.appGold),
                    const SizedBox(width: 8),
                    Text(
                      'ملخص شهر $monthLabel',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: context.appText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _miniStat(context, 'معاملات', '$monthTxCount',
                          Icons.receipt_long_rounded, context.appGold),
                    ),
                    Expanded(
                      child: _miniStat(context, 'دخل (له)',
                          '${_fmt(monthIn)} ج', Icons.arrow_downward_rounded,
                          context.appGreen),
                    ),
                    Expanded(
                      child: _miniStat(context, 'خرج (عليه)',
                          '${_fmt(monthOut)} ج', Icons.arrow_upward_rounded,
                          context.appRed),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.08),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('إجمالي له',
                          style: TextStyle(
                              color: context.appTextDim, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text('${_fmt(p.totalCredit)} ج.م',
                          style: TextStyle(
                              color: context.appGreen,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('إجمالي عليه',
                          style: TextStyle(
                              color: context.appTextDim, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text('${_fmt(p.totalDebit)} ج.م',
                          style: TextStyle(
                              color: context.appRed,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('صافي الرصيد',
                    style: TextStyle(
                        color: context.appText, fontWeight: FontWeight.w700)),
                Text(
                  '${_fmt(p.netBalance.abs())} ج.م ${p.netBalance >= 0 ? "(لك)" : "(عليك)"}',
                  style: TextStyle(
                    color:
                        p.netBalance >= 0 ? context.appGreen : context.appRed,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _sectionTitle(
              context, Icons.warning_amber_rounded, 'ديون متأخرة (+30 يوم)'),
          const SizedBox(height: 8),
          if (aging.isEmpty)
            GlassCard(
              child: Text('لا توجد ديون متأخرة 👍',
                  style: TextStyle(color: context.appTextDim)),
            )
          else
            ...aging.take(8).map((c) => _clientTile(context, c)),
          const SizedBox(height: 22),
          _sectionTitle(
              context, Icons.trending_down_rounded, 'أكبر المبالغ عليه'),
          const SizedBox(height: 8),
          if (debtors.isEmpty)
            GlassCard(
              child: Text('لا يوجد عملاء عليهم مبالغ',
                  style: TextStyle(color: context.appTextDim)),
            )
          else
            ...debtors.take(5).map((c) => _clientTile(context, c)),
          const SizedBox(height: 22),
          _sectionTitle(
              context, Icons.trending_up_rounded, 'أكبر المبالغ له'),
          const SizedBox(height: 8),
          if (creditors.isEmpty)
            GlassCard(
              child: Text('لا يوجد عملاء لهم مبالغ',
                  style: TextStyle(color: context.appTextDim)),
            )
          else
            ...creditors.take(5).map((c) => _clientTile(context, c)),
          const SizedBox(height: 22),
          _sectionTitle(
              context, Icons.pie_chart_rounded, 'توزيع حسب الشبكة'),
          const SizedBox(height: 8),
          GlassCard(
            child: Column(
              children: ClientCategory.values.map((cat) {
                final count = catMap[cat] ?? 0;
                final total = p.clients.isEmpty ? 1 : p.clients.length;
                final pct = count / total;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Text(cat.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 70,
                        child: Text(cat.arName,
                            style: TextStyle(
                                color: context.appText, fontSize: 13)),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 8,
                            backgroundColor: context.appBorder,
                            color: context.appGold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('$count',
                          style: TextStyle(
                              color: context.appTextDim,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: () => _shareSummary(context, p),
            icon: const Icon(Icons.ios_share_rounded),
            label: const Text('مشاركة ملخص الأعمال'),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.appGold),
        const SizedBox(width: 6),
        Text(title,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: context.appText)),
      ],
    );
  }

  Widget _miniStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                color: context.appText,
                fontWeight: FontWeight.w800,
                fontSize: 13),
            textAlign: TextAlign.center),
        Text(label,
            style: TextStyle(color: context.appTextDim, fontSize: 10),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _clientTile(BuildContext context, Client c) {
    final color = c.balance >= 0 ? context.appGreen : context.appRed;
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ClientDetailsScreen(clientId: c.id)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Text(c.name.isNotEmpty ? c.name[0] : '?',
                style: TextStyle(color: color, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: context.appText)),
                Text('${c.category.emoji} ${c.phone}',
                    style:
                        TextStyle(fontSize: 11, color: context.appTextDim)),
              ],
            ),
          ),
          Text(
            '${_fmt(c.balance.abs())} ج',
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Future<void> _shareSummary(BuildContext context, AppProvider p) async {
    final buf = StringBuffer();
    buf.writeln('📊 ملخص Hamo Note — ${p.merchantName}');
    buf.writeln('📅 ${DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now())}');
    buf.writeln('────────────────');
    buf.writeln('عدد العملاء: ${p.clients.length}');
    buf.writeln('إجمالي له: ${_fmt(p.totalCredit)} ج.م');
    buf.writeln('إجمالي عليه: ${_fmt(p.totalDebit)} ج.م');
    buf.writeln(
        'الصافي: ${_fmt(p.netBalance.abs())} ج.م ${p.netBalance >= 0 ? "(لك)" : "(عليك)"}');
    buf.writeln('────────────────');
    final debtors = p.clients.where((c) => c.balance < 0).toList()
      ..sort((a, b) => a.balance.compareTo(b.balance));
    if (debtors.isNotEmpty) {
      buf.writeln('أبرز المبالغ عليه:');
      for (final c in debtors.take(10)) {
        buf.writeln('• ${c.name}: ${_fmt(c.balance.abs())} ج.م');
      }
    }
    await Share.share(buf.toString());
  }
}
