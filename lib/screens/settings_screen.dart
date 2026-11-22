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
          GlassCard(
            child: Row(
              children: [
                const Icon(Icons.person_rounded, color: AppColors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('اسم التاجر',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(p.merchantName,
                          style: const TextStyle(
                              color: AppColors.textDim, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.green),
                  onPressed: () => _editName(context, p),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline,
                      color: AppColors.green),
                  title: const Text('Hamo Note'),
                  subtitle: const Text('v1.0.0',
                      style: TextStyle(color: AppColors.textDim)),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.people_rounded,
                      color: AppColors.green),
                  title: const Text('عدد العملاء'),
                  trailing: Text('${p.clients.length}',
                      style: const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.delete_forever, color: AppColors.red),
              title: const Text('مسح كل البيانات',
                  style: TextStyle(color: AppColors.red)),
              onTap: () => _confirmClear(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editName(BuildContext context, AppProvider p) async {
    final ctrl = TextEditingController(text: p.merchantName);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('اسم التاجر'),
        content: TextField(controller: ctrl),
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
        backgroundColor: AppColors.card,
        title: const Text('مسح كل البيانات؟'),
        content: const Text('لا يمكن التراجع عن هذه العملية!'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('مسح', style: TextStyle(color: AppColors.red))),
        ],
      ),
    );
    if (ok == true) {
      final storage = context.read<AppProvider>();
      await storage.reset();
    }
  }
}
