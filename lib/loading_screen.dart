import 'package:flutter/material.dart';
import 'dart:math';

class LoadingScreen extends StatefulWidget {
  final Widget nextScreen;

  const LoadingScreen({super.key, required this.nextScreen});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _progressController;
  late AnimationController _glowPulseController;
  late AnimationController _fadeInController;
  late AnimationController _particleController;

  late Animation<double> _titleFade;
  late Animation<double> _titleSlide;
  late Animation<double> _orbFade;
  late Animation<double> _barFade;

  @override
  void initState() {
    super.initState();

    // Continuous rotation for the orb
    _rotationController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    // Glow pulse
    _glowPulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    // Particle shimmer
    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // Staggered fade-in for elements
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..forward();

    _titleFade = CurvedAnimation(
      parent: _fadeInController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _titleSlide = Tween<double>(begin: -20, end: 0).animate(
      CurvedAnimation(
        parent: _fadeInController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );
    _orbFade = CurvedAnimation(
      parent: _fadeInController,
      curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
    );
    _barFade = CurvedAnimation(
      parent: _fadeInController,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
    );

    // Progress bar
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    // Start progress after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _progressController.forward();
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                widget.nextScreen,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 900),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _progressController.dispose();
    _glowPulseController.dispose();
    _fadeInController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A05),
      body: Stack(
        children: [
          // Subtle radial background glow
          AnimatedBuilder(
            animation: _glowPulseController,
            builder: (context, child) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: _BackgroundGlowPainter(
                    pulse: _glowPulseController.value,
                  ),
                ),
              );
            },
          ),

          // Floating particles layer
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: _FloatingParticlesPainter(
                    time: _particleController.value,
                    glow: _glowPulseController.value,
                  ),
                ),
              );
            },
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 5),

                // "EXPENSES" title
                AnimatedBuilder(
                  animation: _fadeInController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _titleFade.value,
                      child: Transform.translate(
                        offset: Offset(0, _titleSlide.value),
                        child: Column(
                          children: [
                            // Main title with metallic shader
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF6B7D8E),
                                  Color(0xFFD4E0EC),
                                  Color(0xFFFFFFFF),
                                  Color(0xFFD4E0EC),
                                  Color(0xFF8A9BAB),
                                ],
                                stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                              ).createShader(bounds),
                              child: const Text(
                                'EXPENSES',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 10,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 50),

                // Rotating abstract orb
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _rotationController,
                    _glowPulseController,
                    _fadeInController,
                  ]),
                  builder: (context, child) {
                    return Opacity(
                      opacity: _orbFade.value,
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00FF66).withValues(
                                      alpha:
                                          0.15 +
                                          (_glowPulseController.value * 0.15),
                                    ),
                                    blurRadius:
                                        50 +
                                        (_glowPulseController.value * 25),
                                    spreadRadius:
                                        10 +
                                        (_glowPulseController.value * 15),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF00CC88).withValues(
                                      alpha:
                                          0.08 +
                                          (_glowPulseController.value * 0.08),
                                    ),
                                    blurRadius:
                                        80 +
                                        (_glowPulseController.value * 30),
                                    spreadRadius:
                                        20 +
                                        (_glowPulseController.value * 20),
                                  ),
                                ],
                              ),
                            ),
                            // The rotating painted orb
                            Transform.rotate(
                              angle: _rotationController.value * 2 * pi,
                              child: CustomPaint(
                                size: const Size(200, 200),
                                painter: _EnergyOrbPainter(
                                  rotation: _rotationController.value,
                                  glow: _glowPulseController.value,
                                ),
                              ),
                            ),
                            // Inner bright core
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withValues(
                                      alpha:
                                          0.9 +
                                          _glowPulseController.value * 0.1,
                                    ),
                                    const Color(0xFF00FF88).withValues(
                                      alpha: 0.6,
                                    ),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00FF88).withValues(
                                      alpha: 0.8,
                                    ),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(flex: 3),

                // Loading bar
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _progressController,
                    _fadeInController,
                  ]),
                  builder: (context, child) {
                    return Opacity(
                      opacity: _barFade.value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 80),
                        child: Column(
                          children: [
                            // Progress bar container
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: const Color(0xFF0D1A0D),
                                border: Border.all(
                                  color: const Color(0xFF1A3A1A)
                                      .withValues(alpha: 0.5),
                                  width: 0.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: Curves.easeInOut.transform(
                                      _progressController.value,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF007744),
                                            Color(0xFF00CC66),
                                            Color(0xFF00FF88),
                                            Color(0xFF00CC66),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF00FF66)
                                                .withValues(alpha: 0.6),
                                            blurRadius: 10,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Percentage text
                            Text(
                              '${(_progressController.value * 100).toInt()}%',
                              style: TextStyle(
                                color: const Color(0xFF00CC66).withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Background radial glow painter
class _BackgroundGlowPainter extends CustomPainter {
  final double pulse;

  _BackgroundGlowPainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.45);

    // Primary green glow
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.6,
        colors: [
          const Color(0xFF003311).withValues(alpha: 0.4 + pulse * 0.15),
          const Color(0xFF001A08).withValues(alpha: 0.2 + pulse * 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(
        Rect.fromCenter(
          center: center,
          width: size.width * 1.5,
          height: size.height * 1.2,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BackgroundGlowPainter oldDelegate) =>
      oldDelegate.pulse != pulse;
}

// Floating ambient particles
class _FloatingParticlesPainter extends CustomPainter {
  final double time;
  final double glow;
  final List<_Particle> _particles;

  _FloatingParticlesPainter({required this.time, required this.glow})
      : _particles = _generateParticles();

  static List<_Particle> _generateParticles() {
    final random = Random(42); // Fixed seed for consistency
    return List.generate(30, (i) {
      return _Particle(
        baseX: random.nextDouble(),
        baseY: random.nextDouble(),
        speed: 0.3 + random.nextDouble() * 0.7,
        size: 0.5 + random.nextDouble() * 2.0,
        phase: random.nextDouble() * 2 * pi,
        amplitude: 0.01 + random.nextDouble() * 0.03,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final x =
          (p.baseX + sin(time * 2 * pi * p.speed + p.phase) * p.amplitude) *
              size.width;
      final y =
          ((p.baseY + time * p.speed * 0.1) % 1.0) * size.height;
      final alpha =
          (0.15 + glow * 0.15) * (1.0 - (y / size.height) * 0.5);

      final paint = Paint()
        ..color = const Color(0xFF00FF88).withValues(alpha: alpha.clamp(0.0, 1.0));

      canvas.drawCircle(Offset(x, y), p.size, paint);

      // Subtle glow around particles
      final glowPaint = Paint()
        ..color = const Color(0xFF00FF66)
            .withValues(alpha: (alpha * 0.3).clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(x, y), p.size * 2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingParticlesPainter oldDelegate) => true;
}

class _Particle {
  final double baseX, baseY, speed, size, phase, amplitude;
  const _Particle({
    required this.baseX,
    required this.baseY,
    required this.speed,
    required this.size,
    required this.phase,
    required this.amplitude,
  });
}

// The main energy orb custom painter
class _EnergyOrbPainter extends CustomPainter {
  final double rotation;
  final double glow;

  _EnergyOrbPainter({required this.rotation, required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 * 0.85;

    // Draw multiple energy tendrils with varying parameters
    for (int layer = 0; layer < 3; layer++) {
      for (int i = 0; i < 5; i++) {
        _drawTendril(
          canvas,
          center,
          maxRadius,
          tendrilIndex: i,
          layerIndex: layer,
        );
      }
    }

    // Draw bright accent nodes
    _drawAccentNodes(canvas, center, maxRadius);
  }

  void _drawTendril(
    Canvas canvas,
    Offset center,
    double maxRadius, {
    required int tendrilIndex,
    required int layerIndex,
  }) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Layer-specific properties
    final layerAlpha = [0.7, 0.4, 0.2][layerIndex];
    final layerWidth = [2.5, 4.0, 7.0][layerIndex];
    final blur = [0.0, 3.0, 8.0][layerIndex];

    // Color variation across tendrils
    final hue = 130.0 + tendrilIndex * 20.0 - 40.0;
    final saturation = 0.75 + glow * 0.25;
    final lightness = [0.45 + glow * 0.15, 0.4 + glow * 0.1, 0.35 + glow * 0.08][layerIndex];

    paint.color = HSLColor.fromAHSL(
      (layerAlpha + glow * 0.15).clamp(0.0, 1.0),
      hue.clamp(80.0, 170.0),
      saturation.clamp(0.0, 1.0),
      lightness.clamp(0.0, 1.0),
    ).toColor();
    paint.strokeWidth = layerWidth + glow * 1.0;

    if (blur > 0) {
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    }

    final path = Path();
    final angleOffset = tendrilIndex * (2 * pi / 5);
    final timeShift = rotation * 2 * pi;

    final points = <Offset>[];
    for (double t = 0; t <= 1.0; t += 0.015) {
      final baseAngle = angleOffset + t * 2.8 * pi + timeShift;

      // Organic radius modulation
      final r1 = sin(t * pi) * 0.9; // Main envelope
      final r2 = sin(t * 5 + timeShift * 1.5 + tendrilIndex) * 0.15; // Wobble
      final r3 = cos(t * 3 + timeShift * 0.7) * 0.1; // Secondary wobble
      final radiusFactor = (r1 + r2 + r3).clamp(0.0, 1.0);

      final radius = maxRadius * (0.15 + 0.85 * radiusFactor);

      // Perpendicular displacement for organic feel
      final displacement =
          sin(t * 7 + timeShift * 2.3 + tendrilIndex * 1.5) * 12 * sin(t * pi);

      final angle = baseAngle;
      final x = center.dx +
          cos(angle) * radius +
          cos(angle + pi / 2) * displacement;
      final y = center.dy +
          sin(angle) * radius +
          sin(angle + pi / 2) * displacement;

      points.add(Offset(x, y));
    }

    if (points.length < 3) return;

    // Smooth curve through points
    path.moveTo(points[0].dx, points[0].dy);
    for (int j = 1; j < points.length - 1; j++) {
      final midX = (points[j].dx + points[j + 1].dx) / 2;
      final midY = (points[j].dy + points[j + 1].dy) / 2;
      path.quadraticBezierTo(points[j].dx, points[j].dy, midX, midY);
    }

    canvas.drawPath(path, paint);
  }

  void _drawAccentNodes(Canvas canvas, Offset center, double maxRadius) {
    final random = Random(7);
    for (int i = 0; i < 16; i++) {
      final angle = (i * pi / 8) + (rotation * 2 * pi * 0.7) + random.nextDouble();
      final radiusFactor = 0.25 + 0.55 * sin(i * 0.9 + rotation * 5 * pi).abs();
      final radius = maxRadius * radiusFactor;
      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius;

      final brightness = 0.5 + glow * 0.5;
      final nodeSize = 1.2 + glow * 1.0 + random.nextDouble() * 0.8;

      // Bright dot
      final dotPaint = Paint()
        ..color = Color.lerp(
          const Color(0xFF00FF66),
          const Color(0xFF88FFCC),
          glow,
        )!.withValues(alpha: brightness.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), nodeSize, dotPaint);

      // Soft halo
      final haloPaint = Paint()
        ..color = const Color(0xFF00FF66)
            .withValues(alpha: (brightness * 0.25).clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(Offset(x, y), nodeSize * 3, haloPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EnergyOrbPainter oldDelegate) => true;
}
