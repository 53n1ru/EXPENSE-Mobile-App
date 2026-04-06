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
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    // Rotation animation - continuous slow rotation
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Glow pulsing animation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Progress bar animation
    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..forward();

    // Navigate to the next screen after loading completes
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                widget.nextScreen,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _progressController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F0A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            // "EXPENSES" title text with metallic gradient
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF8899AA),
                  Color(0xFFCCDDEE),
                  Color(0xFF8899AA),
                  Color(0xFFAABBCC),
                ],
                stops: [0.0, 0.3, 0.6, 1.0],
              ).createShader(bounds),
              child: const Text(
                'EXPENSES',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 8,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Rotating abstract green element
            AnimatedBuilder(
              animation: Listenable.merge([_rotationController, _glowController]),
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * pi,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FF66).withValues(
                            alpha: 0.3 + (_glowController.value * 0.3),
                          ),
                          blurRadius: 40 + (_glowController.value * 20),
                          spreadRadius: 5 + (_glowController.value * 10),
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: _AbstractGlowPainter(
                        rotationValue: _rotationController.value,
                        glowValue: _glowController.value,
                      ),
                    ),
                  ),
                );
              },
            ),
            const Spacer(flex: 2),
            // Loading progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Column(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: const Color(0xFF1A2A1A),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: _progressController.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF00CC55),
                                      Color(0xFF00FF88),
                                      Color(0xFF00CC55),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00FF66)
                                          .withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}

// Custom painter to draw abstract green swirling shapes
class _AbstractGlowPainter extends CustomPainter {
  final double rotationValue;
  final double glowValue;

  _AbstractGlowPainter({
    required this.rotationValue,
    required this.glowValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Draw multiple swirling abstract paths - like energy tendrils
    for (int i = 0; i < 6; i++) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 + (glowValue * 1.5)
        ..strokeCap = StrokeCap.round;

      // Different green shades for each tendril
      final hue = 120.0 + (i * 15.0) - 40.0; // Range from cyan-ish to green
      final saturation = 0.8 + (glowValue * 0.2);
      final lightness = 0.4 + (glowValue * 0.2);
      paint.color = HSLColor.fromAHSL(
        0.6 + (glowValue * 0.3),
        hue.clamp(80, 160),
        saturation,
        lightness,
      ).toColor();

      final path = Path();
      final angleOffset = (i * pi / 3) + (rotationValue * 2 * pi);

      // Create organic swirling shapes
      final points = <Offset>[];
      for (double t = 0; t <= 1.0; t += 0.02) {
        final angle = angleOffset + (t * 3 * pi);
        final radius =
            maxRadius * (0.2 + 0.6 * sin(t * pi) * (0.8 + 0.2 * sin(angle * 2 + rotationValue * 4 * pi)));
        final wobble = sin(t * 8 + rotationValue * 6 * pi + i) * 10;
        final x = center.dx + cos(angle) * radius + wobble * cos(angle + pi / 2);
        final y = center.dy + sin(angle) * radius + wobble * sin(angle + pi / 2);
        points.add(Offset(x, y));
      }

      if (points.isNotEmpty) {
        path.moveTo(points[0].dx, points[0].dy);
        for (int j = 1; j < points.length - 2; j++) {
          final cp = points[j];
          final end = Offset(
            (points[j].dx + points[j + 1].dx) / 2,
            (points[j].dy + points[j + 1].dy) / 2,
          );
          path.quadraticBezierTo(cp.dx, cp.dy, end.dx, end.dy);
        }
        canvas.drawPath(path, paint);

        // Draw glow layer
        final glowPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6 + (glowValue * 4)
          ..strokeCap = StrokeCap.round
          ..color = paint.color.withValues(alpha: 0.15 + glowValue * 0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawPath(path, glowPaint);
      }
    }

    // Draw some glowing dots at random positions along the paths
    for (int i = 0; i < 12; i++) {
      final angle = (i * pi / 6) + (rotationValue * 2 * pi);
      final radius = maxRadius * (0.3 + 0.4 * sin(i * 0.8 + rotationValue * 4 * pi).abs());
      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius;

      final dotPaint = Paint()
        ..color = Color.lerp(
          const Color(0xFF00FF66),
          const Color(0xFF00FFAA),
          glowValue,
        )!
            .withValues(alpha: 0.6 + glowValue * 0.4);

      canvas.drawCircle(Offset(x, y), 2 + glowValue * 1.5, dotPaint);

      // Glow around dots
      final dotGlowPaint = Paint()
        ..color = const Color(0xFF00FF66).withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(x, y), 4 + glowValue * 2, dotGlowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AbstractGlowPainter oldDelegate) => true;
}
