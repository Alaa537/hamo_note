import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/client.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});
  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _note = TextEditingController();
  ClientCategory category = ClientCategory.vodafone;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عميل جديد')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('الاسم', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            decoration: const InputDecoration(hintText: 'مثال: أحمد محمد'),
          ),
          const SizedBox(height: 16),
          const Text('رقم الهاتف',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '01xxxxxxxxx'),
          ),
          const SizedBox(height: 16),
          const Text('الفئة', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ClientCategory.values.map((c) {
              final sel = category == c;
              return ChoiceChip(
                label: Text('${c.emoji} ${c.arName}'),
                selected: sel,
                onSelected: (_) => setState(() => category = c),
                selectedColor: AppColors.green.withOpacity(0.25),
                backgroundColor: AppColors.cardLight,
                labelStyle: TextStyle(
                  color: sel ? AppColors.green : AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: sel ? AppColors.green : AppColors.border,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('ملاحظة (اختياري)',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _note,
            maxLines: 2,
            decoration: const InputDecoration(hintText: 'أي تفاصيل إضافية'),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _save,
            child: const Text('حفظ العميل'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('من فضلك املأ الاسم والهاتف')),
      );
      return;
    }
    await context.read<AppProvider>().addClient(
          name: _name.text.trim(),
          phone: _phone.text.trim(),
          category: category,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        );
    if (mounted) Navigator.pop(context);
  }
}
