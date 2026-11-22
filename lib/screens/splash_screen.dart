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
      final shown = context.read<AppProvider>().onboardingShown;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, __, ___) => shown
              ? const DashboardScreen()
              : const OnboardingScreen(),
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
