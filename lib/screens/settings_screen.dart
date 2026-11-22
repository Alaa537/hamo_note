import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(context, Icons.palette_rounded, 'المظهر'),
          const SizedBox(height: 10),
          GlassCard(
            child: Column(
              children: [
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded),
                        label: Text('داكن')),
                    ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded),
                        label: Text('فاتح')),
                    ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_rounded),
                        label: Text('تلقائي')),
                  ],
                  selected: {p.themeMode},
                  onSelectionChanged: (s) => p.setThemeMode(s.first),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: context.appGreen.withOpacity(0.2),
                    selectedForegroundColor: context.appGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _header(context, Icons.person_rounded, 'بيانات التاجر'),
          const SizedBox(height: 10),
          GlassCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.appGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.store_rounded, color: context.appGreen),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('اسم التاجر',
                          style: TextStyle(
                              color: context.appTextDim, fontSize: 11)),
                      Text(p.merchantName,
                          style: TextStyle(
                              color: context.appText,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_rounded, color: context.appGreen),
                  onPressed: () => _editName(context, p),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _header(context, Icons.tune_rounded, 'خيارات'),
          const SizedBox(height: 10),
          GlassCard(
            child: Column(
              children: [
                _tile(
                  context,
                  icon: Icons.school_rounded,
                  color: context.appGold,
                  title: 'إعادة عرض الإرشادات',
                  subtitle: 'شوف شاشة الترحيب مرة تانية',
                  onTap: () async {
                    await p.setOnboardingShown(false);
                    if (context.mounted) {
                      Navigator.popUntil(context, (r) => r.isFirst);
                    }
                  },
                ),
                const Divider(height: 20),
                _tile(
                  context,
                  icon: Icons.info_rounded,
                  color: context.appGreen,
                  title: 'Hamo Note',
                  subtitle: 'الإصدار 1.0.0',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _header(context, Icons.bar_chart_rounded, 'إحصائيات'),
          const SizedBox(height: 10),
          GlassCard(
            child: Row(
              children: [
                Expanded(
                  child: _stat(
                      context, 'عدد العملاء', '${p.clients.length}',
                      Icons.people_rounded),
                ),
                Container(
                    width: 1, height: 40, color: context.appBorder),
                Expanded(
                  child: _stat(
                      context,
                      'إجمالي المعاملات',
                      '${p.clients.fold<int>(0, (s, c) => s + c.transactions.length)}',
                      Icons.receipt_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GlassCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.delete_forever_rounded,
                  color: context.appRed),
              title: Text('مسح كل البيانات',
                  style: TextStyle(
                      color: context.appRed, fontWeight: FontWeight.w700)),
              subtitle: Text('لا يمكن التراجع',
                  style:
                      TextStyle(color: context.appTextDim, fontSize: 11)),
              onTap: () => _confirmClear(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 18, color: context.appGreen),
      const SizedBox(width: 6),
      Text(text,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.appTextDim)),
    ]);
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              color: context.appText,
              fontSize: 14,
              fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: TextStyle(color: context.appTextDim, fontSize: 11)),
      trailing: onTap != null
          ? Icon(Icons.chevron_left_rounded, color: context.appTextDim)
          : null,
      onTap: onTap,
    );
  }

  Widget _stat(
      BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: context.appGreen, size: 20),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                color: context.appText,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        Text(label,
            style: TextStyle(color: context.appTextDim, fontSize: 11)),
      ],
    );
  }

  Future<void> _editName(BuildContext context, AppProvider p) async {
    final ctrl = TextEditingController(text: p.merchantName);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.appCard,
        title: Text('اسم التاجر', style: TextStyle(color: context.appText)),
        content: TextField(
            controller: ctrl, style: TextStyle(color: context.appText)),
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
    if (ok == true) await p.setMerchantName(ctrl.text.trim());
  }

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.appCard,
        title: Text('مسح كل البيانات؟', style: TextStyle(color: context.appText)),
        content: Text('لا يمكن التراجع عن هذه العملية!',
            style: TextStyle(color: context.appTextDim)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('مسح',
                  style: TextStyle(color: context.appRed))),
        ],
      ),
    );
    if (ok == true) {
      await context.read<AppProvider>().reset();
      if (context.mounted) Navigator.pop(context);
    }
  }
}
