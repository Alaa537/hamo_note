import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../models/client.dart';
import 'add_client_screen.dart';
import 'client_details_screen.dart';

enum _BalanceFilter { all, debit, credit, zero }
enum _SortMode { newest, name, balanceHigh, balanceLow }

class ClientsScreen extends StatefulWidget {
  final String? highlight;
  const ClientsScreen({super.key, this.highlight});
  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String query = '';
  _BalanceFilter balanceFilter = _BalanceFilter.all;
  ClientCategory? categoryFilter;
  _SortMode sortMode = _SortMode.newest;

  String _fmt(double v) => NumberFormat('#,##0.00').format(v);

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    var list = p.clients.where((c) {
      final q = query.toLowerCase();
      final matchQ = q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.phone.contains(query);
      if (!matchQ) return false;
      switch (balanceFilter) {
        case _BalanceFilter.debit:
          if (c.balance >= 0) return false;
          break;
        case _BalanceFilter.credit:
          if (c.balance <= 0) return false;
          break;
        case _BalanceFilter.zero:
          if (c.balance != 0) return false;
          break;
        case _BalanceFilter.all:
          break;
      }
      if (categoryFilter != null && c.category != categoryFilter) return false;
      return true;
    }).toList();

    switch (sortMode) {
      case _SortMode.newest:
        list = list.reversed.toList();
        break;
      case _SortMode.name:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case _SortMode.balanceHigh:
        list.sort((a, b) => b.balance.abs().compareTo(a.balance.abs()));
        break;
      case _SortMode.balanceLow:
        list.sort((a, b) => a.balance.abs().compareTo(b.balance.abs()));
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('العملاء (${list.length})'),
        actions: [
          PopupMenuButton<_SortMode>(
            tooltip: 'ترتيب',
            icon: Icon(Icons.sort_rounded, color: context.appGold),
            onSelected: (v) => setState(() => sortMode = v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: _SortMode.newest, child: Text('الأحدث')),
              PopupMenuItem(value: _SortMode.name, child: Text('الاسم')),
              PopupMenuItem(
                  value: _SortMode.balanceHigh, child: Text('الأعلى رصيداً')),
              PopupMenuItem(
                  value: _SortMode.balanceLow, child: Text('الأقل رصيداً')),
            ],
          ),
          IconButton(
            icon: Icon(Icons.person_add_alt_1_rounded, color: context.appGold),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddClientScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              onChanged: (v) => setState(() => query = v.trim()),
              decoration: InputDecoration(
                hintText: 'بحث بالاسم أو الهاتف...',
                prefixIcon:
                    Icon(Icons.search_rounded, color: context.appTextDim),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip(
                  context,
                  label: 'الكل',
                  selected: balanceFilter == _BalanceFilter.all &&
                      categoryFilter == null,
                  onTap: () => setState(() {
                    balanceFilter = _BalanceFilter.all;
                    categoryFilter = null;
                  }),
                ),
                _chip(
                  context,
                  label: 'عليه',
                  selected: balanceFilter == _BalanceFilter.debit,
                  color: context.appRed,
                  onTap: () => setState(() {
                    balanceFilter = balanceFilter == _BalanceFilter.debit
                        ? _BalanceFilter.all
                        : _BalanceFilter.debit;
                  }),
                ),
                _chip(
                  context,
                  label: 'له',
                  selected: balanceFilter == _BalanceFilter.credit,
                  color: context.appGreen,
                  onTap: () => setState(() {
                    balanceFilter = balanceFilter == _BalanceFilter.credit
                        ? _BalanceFilter.all
                        : _BalanceFilter.credit;
                  }),
                ),
                _chip(
                  context,
                  label: 'متساوي',
                  selected: balanceFilter == _BalanceFilter.zero,
                  onTap: () => setState(() {
                    balanceFilter = balanceFilter == _BalanceFilter.zero
                        ? _BalanceFilter.all
                        : _BalanceFilter.zero;
                  }),
                ),
                const SizedBox(width: 6),
                ...ClientCategory.values.map((cat) => _chip(
                      context,
                      label: '${cat.emoji} ${cat.arName}',
                      selected: categoryFilter == cat,
                      onTap: () => setState(() {
                        categoryFilter =
                            categoryFilter == cat ? null : cat;
                      }),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline_rounded,
                            size: 52, color: context.appTextDim),
                        const SizedBox(height: 10),
                        Text('لا يوجد عملاء مطابقين',
                            style: TextStyle(color: context.appTextDim)),
                      ],
                    ),
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: list.length,
                      itemBuilder: (ctx, i) {
                        final c = list[i];
                        final color = c.balance > 0
                            ? context.appGreen
                            : (c.balance < 0
                                ? context.appRed
                                : context.appTextDim);
                        final highlighted = widget.highlight == c.id;
                        return AnimationConfiguration.staggeredList(
                          position: i,
                          duration: const Duration(milliseconds: 280),
                          child: SlideAnimation(
                            verticalOffset: 30,
                            child: FadeInAnimation(
                              child: GlassCard(
                                margin: const EdgeInsets.only(bottom: 10),
                                borderColor: highlighted
                                    ? context.appGold
                                    : context.appBorder,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ClientDetailsScreen(clientId: c.id),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: color.withOpacity(0.15),
                                      child: Text(
                                        c.name.isNotEmpty ? c.name[0] : '?',
                                        style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(c.name,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: context.appText,
                                                  fontSize: 15)),
                                          const SizedBox(height: 2),
                                          Text(
                                              '${c.category.emoji} ${c.phone}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: context.appTextDim)),
                                          if (c.note != null &&
                                              c.note!.isNotEmpty)
                                            Text('📝 ${c.note}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        context.appTextDim)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${_fmt(c.balance.abs())}',
                                          style: TextStyle(
                                              color: color,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15),
                                        ),
                                        Text(
                                          c.balance == 0
                                              ? 'متساوي'
                                              : (c.balance > 0 ? 'له' : 'عليه'),
                                          style: TextStyle(
                                              color: color, fontSize: 11),
                                        ),
                                        Text(
                                          '${c.transactions.length} عملية',
                                          style: TextStyle(
                                              color: context.appTextDim,
                                              fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? context.appGold;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? Colors.black : context.appText,
            )),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: c.withOpacity(0.85),
        backgroundColor: context.appCardLight,
        side: BorderSide(
            color: selected ? c : context.appBorder, width: 1),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}
