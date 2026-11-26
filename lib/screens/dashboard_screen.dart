import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/client.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'clients_screen.dart';
import 'settings_screen.dart';
import 'merchant_screen.dart';
import 'add_client_screen.dart';
import 'notes_screen.dart';
import 'reports_screen.dart';
import 'calculator_screen.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _fmt(double v) => NumberFormat('#,##0.00').format(v);

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();

    final bgColors = AppBackgrounds.colors(p.bgStyle, context.isDark);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
          color: context.appGreen,
          onRefresh: () => p.init(),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [context.appGreen, context.appGreenDark],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: context.appGreen.withOpacity(0.35),
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
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: context.appText)),
                        Text('نظرة سريعة على أعمالك',
                            style: TextStyle(
                                color: context.appTextDim, fontSize: 12)),
                      ],
                    ),
                  ).animate().fadeIn().slideX(begin: 0.2),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    icon: Icon(Icons.settings_rounded, color: context.appText),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1),

              const SizedBox(height: 24),

              GlassCard(
                gradient: LinearGradient(
                  colors: [
                    context.appGreen.withOpacity(0.25),
                    context.appCard,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderColor: context.appGreen.withOpacity(0.4),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_balance_wallet_rounded,
                            color: context.appGreen, size: 22),
                        const SizedBox(width: 8),
                        Text('صافي الرصيد',
                            style: TextStyle(
                                color: context.appTextDim, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_fmt(p.netBalance.abs())} ج.م',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: p.netBalance >= 0
                            ? context.appGreen
                            : context.appRed,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.netBalance >= 0 ? 'له (رصيد إيجابي)' : 'عليه (رصيد سالب)',
                      style: TextStyle(
                        color: p.netBalance >= 0
                            ? context.appGreen.withOpacity(0.8)
                            : context.appRed.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.15),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'إجمالي له',
                      value: _fmt(p.totalCredit),
                      icon: Icons.arrow_downward_rounded,
                      color: context.appGreen,
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.15),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'إجمالي عليه',
                      value: _fmt(p.totalDebit),
                      icon: Icons.arrow_upward_rounded,
                      color: context.appRed,
                    ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.15),
                  ),
                ],
              ),

              const SizedBox(height: 16),

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
                        color: context.appGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.storefront_rounded,
                          color: context.appGold, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('حسابي (التاجر)',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: context.appText)),
                          Text(
                            '${_fmt(p.merchantBalance.abs())} ج.م',
                            style: TextStyle(
                              color: p.merchantBalance >= 0
                                  ? context.appGold
                                  : context.appRed,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_left, color: context.appTextDim),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

              const SizedBox(height: 24),

              Text('إجراءات سريعة',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.appText)).animate().fadeIn(delay: 320.ms),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _quickActionButton(
                      context,
                      icon: Icons.person_add_alt_1_rounded,
                      label: 'عميل جديد',
                      color: context.appGreen,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddClientScreen()),
                      ).then((_) => p.init()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _quickActionButton(
                      context,
                      icon: Icons.people_alt_rounded,
                      label: 'العملاء',
                      color: context.appGreen,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ClientsScreen()),
                      ).then((_) => p.init()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _quickActionButton(
                      context,
                      icon: Icons.sticky_note_2_rounded,
                      label: 'ملاحظاتي',
                      color: context.appGold,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotesScreen()),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1),

              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _quickActionButton(
                      context,
                      icon: Icons.bar_chart_rounded,
                      label: 'التقارير',
                      color: context.appGold,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ReportsScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _quickActionButton(
                      context,
                      icon: Icons.account_balance_wallet_rounded,
                      label: 'خزنة التاجر',
                      color: context.appGreen,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MerchantScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _quickActionButton(
                      context,
                      icon: Icons.calculate_rounded,
                      label: 'حاسبة',
                      color: context.appGold,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CalculatorScreen()),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 380.ms).slideY(begin: 0.1),

              const SizedBox(height: 28),

              Text('آخر العملاء',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.appText)),
              const SizedBox(height: 12),
              if (p.clients.isEmpty)
                GlassCard(
                  child: Column(
                    children: [
                      Icon(Icons.person_add_alt_1_rounded,
                          color: context.appTextDim, size: 40),
                      const SizedBox(height: 8),
                      Text('لا يوجد عملاء بعد',
                          style: TextStyle(color: context.appTextDim)),
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
                              context.appGreen.withOpacity(0.15),
                          child: Text(
                            c.name.isNotEmpty ? c.name[0] : '?',
                            style: TextStyle(
                                color: context.appGreen,
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
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: context.appText)),
                              Text('${c.category.emoji} ${c.category.arName}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: context.appTextDim)),
                            ],
                          ),
                        ),
                        Text(
                          '${_fmt(c.balance.abs())}',
                          style: TextStyle(
                            color: c.balance >= 0
                                ? context.appGreen
                                : context.appRed,
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
      ),
    );
  }

  Widget _quickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: context.appCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: context.appText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ],
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
                    style: TextStyle(
                        color: context.appTextDim, fontSize: 12),
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
