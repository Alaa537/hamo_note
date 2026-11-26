import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../models/note.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

const _noteColors = [
  Color(0xFFFEF3C7), // soft yellow
  Color(0xFFDCFCE7), // soft green
  Color(0xFFE0E7FF), // soft indigo
  Color(0xFFFCE7F3), // soft pink
  Color(0xFFE0F2FE), // soft sky
  Color(0xFFF3E8FF), // soft purple
];

const _noteColorsDark = [
  Color(0xFF422006),
  Color(0xFF14532D),
  Color(0xFF1E1B4B),
  Color(0xFF500724),
  Color(0xFF0C4A6E),
  Color(0xFF3B0764),
];

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final filtered = p.notes.where((n) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return n.title.toLowerCase().contains(q) ||
          n.content.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ملاحظاتي الخاصة'),
        actions: [
          IconButton(
            tooltip: 'ملاحظة جديدة',
            icon: Icon(Icons.note_add_rounded, color: context.appGold),
            onPressed: () => _openEditor(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.edit_rounded),
        label: const Text('ملاحظة جديدة'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: InputDecoration(
                hintText: 'بحث في الملاحظات...',
                prefixIcon: Icon(Icons.search_rounded, color: context.appTextDim),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sticky_note_2_outlined,
                            size: 56, color: context.appTextDim),
                        const SizedBox(height: 12),
                        Text(
                          _query.isEmpty
                              ? 'لا توجد ملاحظات بعد'
                              : 'لا نتائج للبحث',
                          style: TextStyle(color: context.appTextDim),
                        ),
                        if (_query.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'سجّل أفكارك وملاحظاتك الخاصة هنا',
                            style: TextStyle(
                                color: context.appTextDim, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final note = filtered[i];
                      return _NoteCard(
                        note: note,
                        onTap: () => _openEditor(context, note: note),
                        onPin: () =>
                            context.read<AppProvider>().togglePinNote(note.id),
                        onDelete: () => _confirmDelete(context, note),
                      ).animate().fadeIn(delay: (40 * i).ms).slideY(begin: 0.05);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, {Note? note}) async {
    final isNew = note == null;
    final titleCtrl = TextEditingController(text: note?.title ?? '');
    final contentCtrl = TextEditingController(text: note?.content ?? '');
    var colorIndex = note?.colorIndex ?? 0;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.appBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isNew ? 'ملاحظة جديدة' : 'تعديل الملاحظة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: context.appText,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleCtrl,
                    style: TextStyle(color: context.appText),
                    decoration: const InputDecoration(
                      hintText: 'العنوان',
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentCtrl,
                    style: TextStyle(color: context.appText),
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: 'اكتب ملاحظتك هنا...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('لون البطاقة',
                      style: TextStyle(
                          color: context.appTextDim, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(_noteColors.length, (i) {
                      final c = context.isDark
                          ? _noteColorsDark[i]
                          : _noteColors[i];
                      final selected = colorIndex == i;
                      return GestureDetector(
                        onTap: () => setModal(() => colorIndex = i),
                        child: Container(
                          margin: const EdgeInsets.only(left: 8),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? context.appGold
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: selected
                              ? Icon(Icons.check,
                                  size: 16,
                                  color: context.isDark
                                      ? Colors.white
                                      : Colors.black87)
                              : null,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final title = titleCtrl.text.trim();
                      final content = contentCtrl.text.trim();
                      if (title.isEmpty && content.isEmpty) {
                        Navigator.pop(ctx);
                        return;
                      }
                      final p = context.read<AppProvider>();
                      if (isNew) {
                        await p.addNote(
                          title: title.isEmpty ? 'بدون عنوان' : title,
                          content: content,
                          colorIndex: colorIndex,
                        );
                      } else {
                        note!.title =
                            title.isEmpty ? 'بدون عنوان' : title;
                        note.content = content;
                        note.colorIndex = colorIndex;
                        await p.updateNote(note);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(isNew ? 'حفظ الملاحظة' : 'تحديث'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Note note) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.appCard,
        title: Text('حذف الملاحظة؟',
            style: TextStyle(color: context.appText)),
        content: Text('سيتم حذف الملاحظة نهائياً.',
            style: TextStyle(color: context.appTextDim)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: TextStyle(color: context.appRed)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AppProvider>().deleteNote(note.id);
    }
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onPin;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onPin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bg = context.isDark
        ? _noteColorsDark[note.colorIndex % _noteColorsDark.length]
        : _noteColors[note.colorIndex % _noteColors.length];
    final date =
        DateFormat('dd/MM/yyyy  HH:mm').format(note.updatedAt);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      gradient: LinearGradient(
        colors: [
          bg.withOpacity(context.isDark ? 0.55 : 0.9),
          context.appCard,
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      borderColor: note.pinned
          ? context.appGold.withOpacity(0.6)
          : context.appBorder,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (note.pinned)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(Icons.push_pin_rounded,
                      size: 16, color: context.appGold),
                ),
              Expanded(
                child: Text(
                  note.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: context.appText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  note.pinned
                      ? Icons.push_pin_rounded
                      : Icons.push_pin_outlined,
                  size: 18,
                  color: context.appTextDim,
                ),
                onPressed: onPin,
                tooltip: note.pinned ? 'إلغاء التثبيت' : 'تثبيت',
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    size: 18, color: context.appTextDim),
                onPressed: onDelete,
              ),
            ],
          ),
          if (note.content.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              note.content,
              style: TextStyle(
                color: context.appTextDim,
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Text(date,
              style: TextStyle(
                  color: context.appTextDim.withOpacity(0.8), fontSize: 11)),
        ],
      ),
    );
  }
}
