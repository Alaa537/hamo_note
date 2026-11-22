import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'clients_screen.dart';
import 'settings_screen.dart';
import 'merchant_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _fmt(double v) => NumberFormat('#,##0.00').format(v);

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.green,
          onRefresh: () => p.init(),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.green, AppColors.greenDark],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withOpacity(0.35),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('H',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.w900)),
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('أهلاً، ${p.merchantName}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        const Text('نظرة سريعة على أعمالك',
                            style: TextStyle(
                                color: AppColors.textDim, fontSize: 12)),
                      ],
                    ),
                  ).animate().fadeIn().slideX(begin: 0.2),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    icon: const Icon(Icons.settings_rounded,
                        color: AppColors.text),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1),

              const SizedBox(height: 24),

              // Net balance card
              GlassCard(
                gradient: LinearGradient(
                  colors: [
                    AppColors.green.withOpacity(0.25),
                    AppColors.card,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderColor: AppColors.green.withOpacity(0.4),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.account_balance_wallet_rounded,
                            color: AppColors.green, size: 22),
                        SizedBox(width: 8),
                        Text('صافي الرصيد',
                            style: TextStyle(
                                color: AppColors.textDim, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_fmt(p.netBalance.abs())} ج.م',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: p.netBalance >= 0
                            ? AppColors.green
                            : AppColors.red,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.netBalance >= 0 ? 'له (رصيد إيجابي)' : 'عليه (رصيد سالب)',
                      style: TextStyle(
                        color: p.netBalance >= 0
                            ? AppColors.green.withOpacity(0.8)
                            : AppColors.red.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.15),

              const SizedBox(height: 16),

              // Credit / Debit small cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'إجمالي له',
                      value: _fmt(p.totalCredit),
                      icon: Icons.arrow_downward_rounded,
                      color: AppColors.green,
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.15),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'إجمالي عليه',
                      value: _fmt(p.totalDebit),
                      icon: Icons.arrow_upward_rounded,
                      color: AppColors.red,
                    ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.15),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Merchant account card
              GlassCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MerchantScreen()),
                ).then((_) => p.init()),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.storefront_rounded,
                          color: AppColors.gold, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('حسابي (التاجر)',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                          Text(
                            '${_fmt(p.merchantBalance.abs())} ج.م',
                            style: TextStyle(
                              color: p.merchantBalance >= 0
                                  ? AppColors.gold
                                  : AppColors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_left,
                        color: AppColors.textDim),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

              const SizedBox(height: 24),

              // Quick actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ClientsScreen()),
                      ).then((_) => p.init()),
                      icon: const Icon(Icons.people_alt_rounded),
                      label: const Text('العملاء'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 350.ms),

              const SizedBox(height: 20),

              // Recent clients
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('آخر العملاء',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              if (p.clients.isEmpty)
                GlassCard(
                  child: Column(
                    children: const [
                      Icon(Icons.person_add_alt_1_rounded,
                          color: AppColors.textDim, size: 40),
                      SizedBox(height: 8),
                      Text('لا يوجد عملاء بعد',
                          style: TextStyle(color: AppColors.textDim)),
                    ],
                  ),
                )
              else
                ...p.clients.reversed.take(5).map((c) {
                  return GlassCard(
                    margin: const EdgeInsets.only(bottom: 10),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClientsScreen(highlight: c.id),
                      ),
                    ).then((_) => p.init()),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor:
                              AppColors.green.withOpacity(0.15),
                          child: Text(
                            c.name.isNotEmpty ? c.name[0] : '?',
                            style: const TextStyle(
                                color: AppColors.green,
                                fontWeight: FontWeight.w800,
                                fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              Text('${c.category.emoji} ${c.category.arName}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textDim)),
                            ],
                          ),
                        ),
                        Text(
                          '${_fmt(c.balance.abs())}',
                          style: TextStyle(
                            color: c.balance >= 0
                                ? AppColors.green
                                : AppColors.red,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        color: AppColors.textDim, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
