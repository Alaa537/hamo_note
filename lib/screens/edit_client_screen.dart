import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/client.dart';

class EditClientScreen extends StatefulWidget {
  final String clientId;
  const EditClientScreen({super.key, required this.clientId});
  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  late TextEditingController _name;
  late TextEditingController _phone;
  late TextEditingController _note;
  late ClientCategory category;

  @override
  void initState() {
    super.initState();
    final c = context.read<AppProvider>().clients
        .firstWhere((e) => e.id == widget.clientId);
    _name = TextEditingController(text: c.name);
    _phone = TextEditingController(text: c.phone);
    _note = TextEditingController(text: c.note ?? '');
    category = c.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل البيانات')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('الاسم', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(controller: _name),
          const SizedBox(height: 16),
          const Text('الهاتف',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(controller: _phone, keyboardType: TextInputType.phone),
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
                    color: sel ? AppColors.green : AppColors.text),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('ملاحظة',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(controller: _note, maxLines: 2),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () async {
              final p = context.read<AppProvider>();
              final c = p.clients.firstWhere((e) => e.id == widget.clientId);
              c.name = _name.text.trim();
              c.phone = _phone.text.trim();
              c.note = _note.text.trim();
              c.category = category;
              await p.updateClient(c);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('حفظ التعديلات'),
          ),
        ],
      ),
    );
  }
}
