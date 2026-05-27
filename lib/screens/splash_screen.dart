import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ────────────────────────────────────────────
  late final AnimationController _bgController;
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _taglineController;
  late final AnimationController _shimmerController;

  // ── Animations ─────────────────────────────────────────────
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;

  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;

  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // Logo bounce in
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoController, curve: const Interval(0.0, 0.4)),
    );

    // Pulsing ring behind logo
    _ringScale = Tween<double>(begin: 0.6, end: 1.4).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );
    _ringOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    // App name slide up
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
            begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Tagline slide up
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeIn),
    );
    _taglineSlide = Tween<Offset>(
            begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _taglineController, curve: Curves.easeOut));

    // Gold shimmer sweep
    _shimmer = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _bgController.forward();
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 550));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 350));
    _taglineController.forward();

    // Wait for everything to settle, then navigate
    await Future.delayed(const Duration(milliseconds: 1400));
    _navigateNext();
  }

  void _navigateNext() {
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    Navigator.of(context).pushReplacementNamed(
      user != null ? '/main' : '/login',
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _taglineController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF8F2), // warm cream top
              Color(0xFFFAF0E6), // linen bottom
            ],
          ),
        ),
        child: Stack(
          children: [
            // ── Decorative background petals ──────────────────
            _buildDecoBackground(),

            // ── Main content ──────────────────────────────────
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with animated ring
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulsing ring
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, _) {
                            return Transform.scale(
                              scale: _ringScale.value,
                              child: Opacity(
                                opacity: _ringOpacity.value,
                                child: Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.gold,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Logo circle
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, _) {
                            return Transform.scale(
                              scale: _logoScale.value,
                              child: Opacity(
                                opacity: _logoOpacity.value,
                                child: _buildLogoCircle(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // App name with shimmer
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: AnimatedBuilder(
                        animation: _shimmer,
                        builder: (context, child) {
                          return ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                begin: Alignment(_shimmer.value - 1, 0),
                                end: Alignment(_shimmer.value + 1, 0),
                                colors: const [
                                  AppColors.darkGray,
                                  AppColors.gold,
                                  Color(0xFFF5E8B0),
                                  AppColors.gold,
                                  AppColors.darkGray,
                                ],
                                stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                              ).createShader(bounds);
                            },
                            child: child,
                          );
                        },
                        child: Text(
                          'Flora & Fern',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGray,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Divider line
                  SlideTransition(
                    position: _taglineSlide,
                    child: FadeTransition(
                      opacity: _taglineOpacity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 1,
                            color: AppColors.gold.withValues(alpha: 0.5),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(
                              Icons.local_florist,
                              size: 12,
                              color: AppColors.gold.withValues(alpha: 0.8),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 1,
                            color: AppColors.gold.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tagline
                  SlideTransition(
                    position: _taglineSlide,
                    child: FadeTransition(
                      opacity: _taglineOpacity,
                      child: Text(
                        'Elegance in Every Thread',
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          color: AppColors.lightGray,
                          letterSpacing: 1.2,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom loading dots ───────────────────────────
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _taglineOpacity,
                child: const _PulsingDots(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoCircle() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [AppColors.softPink, Color(0xFFF8D7E3)],
          radius: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.25),
            blurRadius: 25,
            spreadRadius: 4,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: AppColors.softPink.withValues(alpha: 0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.local_florist,
        color: AppColors.gold,
        size: 52,
      ),
    );
  }

  Widget _buildDecoBackground() {
    return Stack(
      children: [
        Positioned(
          top: -40,
          right: -40,
          child: _decoCircle(200, AppColors.softPink, 0.3),
        ),
        Positioned(
          bottom: -60,
          left: -60,
          child: _decoCircle(240, AppColors.blushPink, 0.2),
        ),
        Positioned(
          top: 100,
          left: -20,
          child: _decoCircle(80, AppColors.gold, 0.07),
        ),
        Positioned(
          bottom: 120,
          right: -10,
          child: _decoCircle(100, AppColors.gold, 0.06),
        ),
      ],
    );
  }

  Widget _decoCircle(double size, Color color, double opacity) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

// ── Animated Loading Dots ──────────────────────────────────────────────────

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      final anim = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
      );
      _controllers.add(ctrl);
      _animations.add(anim);
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) ctrl.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: _animations[i].value,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
