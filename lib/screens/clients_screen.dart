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

class ClientsScreen extends StatefulWidget {
  final String? highlight;
  const ClientsScreen({super.key, this.highlight});
  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String query = '';

  String _fmt(double v) => NumberFormat('#,##0.00').format(v);

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final list = p.clients
        .where((c) =>
            c.name.toLowerCase().contains(query.toLowerCase()) ||
            c.phone.contains(query))
        .toList()
        .reversed
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('العملاء')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => query = v),
              style: const TextStyle(color: AppColors.text),
              decoration: const InputDecoration(
                hintText: 'ابحث بالاسم أو الرقم',
                prefixIcon:
                    Icon(Icons.search_rounded, color: AppColors.textDim),
              ),
            ),
          ).animate().fadeIn().slideY(begin: -0.1),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.people_outline,
                            color: AppColors.textDim, size: 60),
                        SizedBox(height: 12),
                        Text('لا يوجد عملاء',
                            style: TextStyle(color: AppColors.textDim)),
                      ],
                    ),
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final c = list[i];
                        return AnimationConfiguration.staggeredList(
                          position: i,
                          duration: const Duration(milliseconds: 400),
                          child: SlideAnimation(
                            verticalOffset: 30,
                            child: FadeInAnimation(
                              child: GlassCard(
                                margin: const EdgeInsets.only(bottom: 10),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ClientDetailsScreen(clientId: c.id),
                                  ),
                                ).then((_) => setState(() {})),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor:
                                          AppColors.green.withOpacity(0.15),
                                      child: Text(
                                        c.name.isNotEmpty ? c.name[0] : '?',
                                        style: const TextStyle(
                                            color: AppColors.green,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 20),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(c.name,
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w700,
                                                  fontSize: 15)),
                                          const SizedBox(height: 2),
                                          Text(c.phone,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textDim)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${_fmt(c.balance.abs())} ج.م',
                                          style: TextStyle(
                                            color: c.balance >= 0
                                                ? AppColors.green
                                                : AppColors.red,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          c.balance >= 0 ? 'له' : 'عليه',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: c.balance >= 0
                                                  ? AppColors.green
                                                  : AppColors.red),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddClientScreen()),
        ).then((_) => setState(() {})),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('عميل جديد'),
      ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
    );
  }
}
