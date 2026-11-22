import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _index = 0;

  final _pages = const [
    _OnboardData(
      icon: Icons.dashboard_customize_rounded,
      title: 'أهلاً بك في Hamo Note',
      subtitle:
          'تطبيقك الشخصي لإدارة العملاء والأرصدة بشكل احترافي وبسيط جدًا.',
      color: Color(0xFF00E676),
    ),
    _OnboardData(
      icon: Icons.people_alt_rounded,
      title: 'سجّل عملاءك بسهولة',
      subtitle:
          'أضف اسم العميل ورقمه وفئته (فودافون، أورنج، اتصالات...) وتابع كل معاملاته من مكان واحد.',
      color: Color(0xFFFFD54F),
    ),
    _OnboardData(
      icon: Icons.picture_as_pdf_rounded,
      title: 'اطبع وشارك بضغطة',
      subtitle:
          'اعمل كشف حساب احترافي PDF أو وصل حراري 80mm وشاركه مع عميلك على واتساب فورًا.',
      color: Color(0xFF2196F3),
    ),
    _OnboardData(
      icon: Icons.verified_rounded,
      title: 'تسوية بنقرة',
      subtitle:
          'لما عميل يسدد كل اللي عليه، اضغط "تم التسليم" وكل حاجة هتتسجل بالتاريخ تلقائيًا.',
      color: Color(0xFFE91E63),
    ),
  ];

  Future<void> _finish() async {
    await context.read<AppProvider>().setOnboardingShown(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const DashboardScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.appGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Hamo Note',
                      style: TextStyle(
                          color: context.appGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _finish,
                    child: Text('تخطي',
                        style: TextStyle(
                            color: context.appTextDim,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _OnboardPage(
                  data: _pages[i],
                  index: i,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: i == _index ? 26 : 8,
                        decoration: BoxDecoration(
                          color: i == _index
                              ? context.appGreen
                              : context.appTextDim.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (isLast) {
                          _finish();
                        } else {
                          _ctrl.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                      icon: Icon(
                        isLast
                            ? Icons.rocket_launch_rounded
                            : Icons.arrow_back_rounded,
                      ),
                      label: Text(isLast ? 'ابدأ الآن' : 'التالي'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _OnboardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

class _OnboardPage extends StatelessWidget {
  final _OnboardData data;
  final int index;
  const _OnboardPage({required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: data.color.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: data.color.withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(data.icon, size: 80, color: data.color),
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack)
              .fadeIn(),
          const SizedBox(height: 40),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: context.appText,
              height: 1.3,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: context.appTextDim,
              height: 1.7,
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}
