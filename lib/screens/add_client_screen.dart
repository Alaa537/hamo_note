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
          _sectionHeader(context, Icons.person_rounded, 'بيانات أساسية'),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            style: TextStyle(
                color: context.appText,
                fontSize: 16,
                fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              labelText: 'اسم العميل',
              hintText: 'مثال: أحمد محمد',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            style: TextStyle(
                color: context.appText,
                fontSize: 16,
                fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف',
              hintText: '01xxxxxxxxx',
              prefixIcon: Icon(Icons.phone_rounded),
            ),
          ),
          const SizedBox(height: 24),
          _sectionHeader(context, Icons.category_rounded, 'الفئة'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ClientCategory.values.map((c) {
              final sel = category == c;
              return ChoiceChip(
                label: Text('${c.emoji} ${c.arName}'),
                selected: sel,
                onSelected: (_) => setState(() => category = c),
                selectedColor: context.appGreen.withOpacity(0.2),
                backgroundColor: context.appCardLight,
                labelStyle: TextStyle(
                  color: sel ? context.appGreen : context.appText,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                side: BorderSide(
                  color: sel ? context.appGreen : context.appBorder,
                  width: sel ? 1.5 : 1,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _sectionHeader(context, Icons.notes_rounded, 'ملاحظة (اختياري)'),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            maxLines: 3,
            style: TextStyle(color: context.appText, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'أي تفاصيل إضافية عن العميل...',
              prefixIcon: Icon(Icons.edit_note_rounded),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: const Text('حفظ العميل', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, IconData icon, String text) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: context.appGreen.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: context.appGreen, size: 16),
      ),
      const SizedBox(width: 8),
      Text(text,
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.appText)),
    ]);
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('من فضلك املأ الاسم والهاتف'),
          backgroundColor: context.appRed,
        ),
      );
      return;
    }
    await context.read<AppProvider>().addClient(
          name: _name.text.trim(),
          phone: _phone.text.trim(),
          category: category,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ تم إضافة العميل'),
          backgroundColor: context.appGreen,
        ),
      );
      Navigator.pop(context);
    }
  }
}
