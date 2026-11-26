import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _glow =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat(reverse: true);
  late final AnimationController _shine =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))
        ..repeat();
  late final AnimationController _fade = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
    ..forward();
  late final AnimationController _scale = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600))
    ..forward();
  late final AnimationController _subFade = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000));

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _subFade.forward();
    });
    Timer(const Duration(milliseconds: 3800), () {
      if (!mounted) return;
      final p = context.read<AppProvider>();
      final Widget next;
      if (p.pinEnabled && p.pinCode != null) {
        next = _PinLockScreen();
      } else if (p.onboardingShown) {
        next = const DashboardScreen();
      } else {
        next = const OnboardingScreen();
      }
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, __, ___) => next,
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _glow.dispose();
    _shine.dispose();
    _fade.dispose();
    _scale.dispose();
    _subFade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF0E1A1F), Color(0xFF000000)],
            center: Alignment.center,
            radius: 1.2,
          ),
        ),
        child: Stack(
          children: [
            // subtle grid of dots
            Positioned.fill(
              child: CustomPaint(painter: _DotsPainter()),
            ),
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_glow, _shine, _fade, _scale]),
                builder: (context, _) {
                  final glowVal = 0.35 + (_glow.value * 0.65);
                  final fadeVal = Curves.easeOut.transform(_fade.value);
                  final scaleVal = 0.85 + (Curves.easeOutBack.transform(_scale.value) * 0.15);
                  final shine = -0.4 + (_shine.value * 1.8);

                  return Opacity(
                    opacity: fadeVal,
                    child: Transform.scale(
                      scale: scaleVal,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // The fancy name with glow + shine
                          ShaderMask(
                            blendMode: BlendMode.srcATop,
                            shaderCallback: (bounds) => LinearGradient(
                              colors: const [
                                Color(0xFF00E676),
                                Color(0xFFFFFFFF),
                                Color(0xFF00E676),
                              ],
                              stops: [
                                (shine - 0.3).clamp(0.0, 1.0),
                                shine.clamp(0.0, 1.0),
                                (shine + 0.3).clamp(0.0, 1.0),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ).createShader(bounds),
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.green
                                        .withOpacity(0.55 * glowVal),
                                    blurRadius: 50,
                                    spreadRadius: 8,
                                  ),
                                  BoxShadow(
                                    color: AppColors.green
                                        .withOpacity(0.25 * glowVal),
                                    blurRadius: 90,
                                    spreadRadius: 20,
                                  ),
                                ],
                              ),
                              child: const Text(
                                '𝑯𝒂𝒎𝒐 𝑵𝒐𝒕𝒆',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // divider line
                          FadeTransition(
                            opacity: _subFade,
                            child: Container(
                              width: 120,
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.green,
                                    Colors.transparent,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.green.withOpacity(0.6),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          FadeTransition(
                            opacity: _subFade,
                            child: const Text(
                              'إدارة العملاء والأرصدة باحترافية',
                              style: TextStyle(
                                color: AppColors.textDim,
                                fontSize: 14,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // bottom version
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _subFade,
                child: const Text(
                  'v1.0.0  •  Hamo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDim,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E676).withOpacity(0.06)
      ..style = PaintingStyle.fill;
    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _PinLockScreen extends StatefulWidget {
  const _PinLockScreen();
  @override
  State<_PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<_PinLockScreen> {
  String _input = '';
  String? _error;

  void _onDigit(String d) {
    if (_input.length >= 6) return;
    setState(() {
      _input += d;
      _error = null;
    });
    final p = context.read<AppProvider>();
    final needed = p.pinCode?.length ?? 4;
    if (_input.length >= needed) {
      if (p.verifyPin(_input)) {
        final shown = p.onboardingShown;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                shown ? const DashboardScreen() : const OnboardingScreen(),
          ),
        );
      } else {
        setState(() {
          _error = 'رقم سري خاطئ';
          _input = '';
        });
      }
    }
  }

  void _backspace() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.4),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'H',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'أهلاً، ${p.merchantName}',
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'أدخل الرقم السري',
              style: TextStyle(color: AppColors.textDim, fontSize: 13),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                final filled = i < _input.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? AppColors.gold : Colors.transparent,
                    border: Border.all(color: AppColors.gold, width: 1.5),
                  ),
                );
              }),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.red, fontSize: 13),
              ),
            ],
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                childAspectRatio: 1.4,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final d in [
                    '1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'
                  ])
                    d.isEmpty
                        ? const SizedBox.shrink()
                        : InkWell(
                            borderRadius: BorderRadius.circular(40),
                            onTap: () {
                              if (d == '⌫') {
                                _backspace();
                              } else {
                                _onDigit(d);
                              }
                            },
                            child: Center(
                              child: Text(
                                d,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

