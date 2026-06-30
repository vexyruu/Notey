import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app.dart';
import '../widgets/main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Logo reveal: 0ms → 2000ms  (cubic-bezier(0.2, 0, 0, 1) ≈ easeOut)
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoBlur;
  late final Animation<double> _logoY;

  // Loader fade-in: 500ms → 1200ms
  late final Animation<double> _loaderOpacity;

  // Loader fill: 500ms → 3500ms  (cubic-bezier(0.4, 0, 0.2, 1) ≈ easeInOut)
  late final Animation<double> _loaderFill;

  static const _bg = Color(0xFF13131B);
  static const _onSurface = Color(0xFFE4E1ED);
  static const _trackColor = Color(0xFF464554);

  // Total duration matches the HTML loader (500ms delay + 3000ms fill = 3500ms)
  static const _totalMs = 3500;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalMs),
    );

    // 0 → 2000ms as fraction of 3500ms = 0.0 → 0.571
    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.571, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.571, curve: Curves.easeOut),
      ),
    );
    _logoBlur = Tween(begin: 8.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.571, curve: Curves.easeOut),
      ),
    );
    _logoY = Tween(begin: 12.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.571, curve: Curves.easeOut),
      ),
    );

    // Loader bar fade: 500ms → 1200ms = 0.143 → 0.343
    _loaderOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.143, 0.343, curve: Curves.easeOut),
      ),
    );

    // Loader fill: 500ms → 3500ms = 0.143 → 1.0
    _loaderFill = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.143, 1.0, curve: Curves.easeInOut),
      ),
    );

    _ctrl.forward().then((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const MainShell(),
          transitionDuration: const Duration(milliseconds: 700),
          transitionsBuilder: (_, anim, _, child) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
            child: child,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Stack(
            children: [
              // Vignette — top-to-bottom gradient matching the HTML
              Positioned.fill(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x8013131B),
                        Colors.transparent,
                        _bg,
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Center content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Logo ──
                    Transform.translate(
                      offset: Offset(0, _logoY.value),
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoOpacity.value.clamp(0.0, 1.0),
                          child: _logoBlur.value > 0.3
                              ? ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                    sigmaX: _logoBlur.value,
                                    sigmaY: _logoBlur.value,
                                  ),
                                  child: const _LogoText(onSurface: _onSurface),
                                )
                              : const _LogoText(onSurface: _onSurface),
                        ),
                      ),
                    ),

                    const SizedBox(height: 56),

                    // ── Loader bar ──
                    Opacity(
                      opacity: _loaderOpacity.value.clamp(0.0, 1.0),
                      child: SizedBox(
                        width: 48,
                        height: 1,
                        child: Stack(
                          children: [
                            // Track
                            Container(width: 48, height: 1, color: _trackColor),
                            // Fill
                            Container(
                              width: 48 * _loaderFill.value,
                              height: 1,
                              color: kElectricIndigo,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LogoText extends StatelessWidget {
  final Color onSurface;
  const _LogoText({required this.onSurface});

  @override
  Widget build(BuildContext context) {
    const size = 80.0;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'N',
            style: GoogleFonts.dmSans(
              fontSize: size,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.04 * size,
              color: onSurface,
              height: 1.0,
            ),
          ),
          TextSpan(
            text: 'o',
            style: GoogleFonts.playfairDisplay(
              fontSize: size,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: kElectricIndigo,
              height: 1.0,
            ),
          ),
          TextSpan(
            text: 'tey',
            style: GoogleFonts.dmSans(
              fontSize: size,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.04 * size,
              color: onSurface,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
