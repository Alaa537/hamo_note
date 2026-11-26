import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/backup_service.dart';
import 'reports_screen.dart';

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
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.appGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.store_rounded, color: context.appGold),
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
                      icon: Icon(Icons.edit_rounded, color: context.appGold),
                      onPressed: () => _editName(context, p),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.appGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.phone_rounded, color: context.appGreen),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('هاتف التاجر',
                              style: TextStyle(
                                  color: context.appTextDim, fontSize: 11)),
                          Text(
                              p.merchantPhone.isEmpty
                                  ? 'غير محدد'
                                  : p.merchantPhone,
                              style: TextStyle(
                                  color: context.appText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit_rounded, color: context.appGreen),
                      onPressed: () => _editPhone(context, p),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.appGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          Icon(Icons.location_on_rounded, color: context.appGold),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('العنوان',
                              style: TextStyle(
                                  color: context.appTextDim, fontSize: 11)),
                          Text(
                              p.merchantAddress.isEmpty
                                  ? 'غير محدد'
                                  : p.merchantAddress,
                              style: TextStyle(
                                  color: context.appText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit_rounded, color: context.appGold),
                      onPressed: () => _editAddress(context, p),
                    ),
                  ],
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
          _header(context, Icons.analytics_rounded, 'التقارير'),
          const SizedBox(height: 10),
          GlassCard(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportsScreen()),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.appGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.bar_chart_rounded, color: context.appGold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('التقارير والإحصائيات',
                          style: TextStyle(
                              color: context.appText,
                              fontWeight: FontWeight.w700)),
                      Text('ملخص الشهر، الديون المتأخرة، التوزيع',
                          style: TextStyle(
                              color: context.appTextDim, fontSize: 11)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_left_rounded, color: context.appTextDim),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _header(context, Icons.security_rounded, 'الأمان والنسخ الاحتياطي'),
          const SizedBox(height: 10),
          GlassCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('قفل برقم سري',
                      style: TextStyle(
                          color: context.appText, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    p.pinEnabled ? 'مفعّل' : 'عند فتح التطبيق',
                    style: TextStyle(color: context.appTextDim, fontSize: 11),
                  ),
                  value: p.pinEnabled,
                  activeColor: context.appGold,
                  onChanged: (v) async {
                    if (v) {
                      await _setupPin(context, p);
                    } else {
                      await p.setPin(null);
                    }
                  },
                ),
                if (p.pinEnabled) ...[
                  const Divider(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.password_rounded, color: context.appGold),
                    title: Text('تغيير الرقم السري',
                        style: TextStyle(color: context.appText)),
                    onTap: () => _setupPin(context, p),
                  ),
                ],
                const Divider(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.backup_rounded, color: context.appGreen),
                  title: Text('تصدير نسخة احتياطية',
                      style: TextStyle(color: context.appText)),
                  subtitle: Text('ملف JSON تقدر تحفظه أو تبعته',
                      style: TextStyle(color: context.appTextDim, fontSize: 11)),
                  onTap: () async {
                    try {
                      await BackupService.shareBackup(
                        merchantName: p.merchantName,
                        merchantPhone: p.merchantPhone,
                        merchantAddress: p.merchantAddress,
                        clients: p.clients,
                        merchantTx: p.merchantTx,
                        notes: p.notes,
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('فشل التصدير: $e')),
                        );
                      }
                    }
                  },
                ),
                const Divider(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.restore_rounded, color: context.appGold),
                  title: Text('استعادة من نص JSON',
                      style: TextStyle(color: context.appText)),
                  subtitle: Text('الصق محتوى ملف النسخة الاحتياطية',
                      style: TextStyle(color: context.appTextDim, fontSize: 11)),
                  onTap: () => _restoreBackup(context, p),
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

  Future<void> _editPhone(BuildContext context, AppProvider p) async {
    final ctrl = TextEditingController(text: p.merchantPhone);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.appCard,
        title: Text('هاتف التاجر', style: TextStyle(color: context.appText)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.phone,
          style: TextStyle(color: context.appText),
          decoration: const InputDecoration(hintText: '01xxxxxxxxx'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('حفظ')),
        ],
      ),
    );
    if (ok == true) await p.setMerchantPhone(ctrl.text.trim());
  }

  Future<void> _editAddress(BuildContext context, AppProvider p) async {
    final ctrl = TextEditingController(text: p.merchantAddress);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.appCard,
        title: Text('عنوان التاجر', style: TextStyle(color: context.appText)),
        content: TextField(
          controller: ctrl,
          style: TextStyle(color: context.appText),
          decoration: const InputDecoration(hintText: 'العنوان / المنطقة'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('حفظ')),
        ],
      ),
    );
    if (ok == true) await p.setMerchantAddress(ctrl.text.trim());
  }


  Future<void> _setupPin(BuildContext context, AppProvider p) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.appCard,
        title: Text('تعيين رقم سري (4-6 أرقام)',
            style: TextStyle(color: context.appText, fontSize: 16)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          style: TextStyle(color: context.appText),
          decoration: const InputDecoration(hintText: '••••'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حفظ')),
        ],
      ),
    );
    if (ok == true) {
      final pin = ctrl.text.trim();
      if (pin.length >= 4 && pin.length <= 6 && int.tryParse(pin) != null) {
        await p.setPin(pin, enabled: true);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تفعيل القفل')),
          );
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرقم السري يجب أن يكون 4-6 أرقام')),
        );
      }
    }
  }

  Future<void> _restoreBackup(BuildContext context, AppProvider p) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.appCard,
        title: Text('استعادة النسخة',
            style: TextStyle(color: context.appText)),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: ctrl,
            maxLines: 8,
            style: TextStyle(color: context.appText, fontSize: 12),
            decoration: const InputDecoration(
              hintText: 'الصق محتوى ملف JSON هنا',
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('استعادة')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final payload = BackupService.parse(ctrl.text.trim());
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: context.appCard,
          title: Text('تأكيد الاستعادة',
              style: TextStyle(color: context.appText)),
          content: Text(
            'سيتم استبدال كل البيانات الحالية.\n'
            'عملاء: ${payload.clients.length} — ملاحظات: ${payload.notes.length}',
            style: TextStyle(color: context.appTextDim),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('استعادة')),
          ],
        ),
      );
      if (confirm == true) {
        await p.restoreBackup(
          merchantName: payload.merchantName,
          merchantPhone: payload.merchantPhone,
          merchantAddress: payload.merchantAddress,
          clients: payload.clients,
          merchantTx: payload.merchantTx,
          notes: payload.notes,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تمت الاستعادة بنجاح')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ملف غير صالح: $e')),
        );
      }
    }
  }

}
