import 'package:flutter/material.dart';
import 'dart:math';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  int _selectedProfileType = -1; // -1 = none selected

  final List<_ProfileTypeOption> _profileTypes = [
    _ProfileTypeOption('Solo', Icons.person_outline_rounded),
    _ProfileTypeOption('Family', Icons.family_restroom_rounded),
    _ProfileTypeOption('Group', Icons.groups_outlined),
    _ProfileTypeOption('Business', Icons.business_center_outlined),
  ];

  late AnimationController _orbRotationController;
  late AnimationController _glowPulseController;
  late AnimationController _fadeInController;
  late AnimationController _particleController;

  late Animation<double> _titleFade;
  late Animation<double> _orbFade;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;

  @override
  void initState() {
    super.initState();

    _orbRotationController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();

    _glowPulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..forward();

    _titleFade = CurvedAnimation(
      parent: _fadeInController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );
    _orbFade = CurvedAnimation(
      parent: _fadeInController,
      curve: const Interval(0.1, 0.4, curve: Curves.easeOut),
    );
    _formFade = CurvedAnimation(
      parent: _fadeInController,
      curve: const Interval(0.25, 0.7, curve: Curves.easeOut),
    );
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeInController,
      curve: const Interval(0.25, 0.7, curve: Curves.easeOutCubic),
    ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _orbRotationController.dispose();
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
          // Background ambient glow
          AnimatedBuilder(
            animation: _glowPulseController,
            builder: (context, child) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: _RegisterBackgroundPainter(
                    pulse: _glowPulseController.value,
                  ),
                ),
              );
            },
          ),

          // Floating particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: _RegisterParticlesPainter(
                    time: _particleController.value,
                    glow: _glowPulseController.value,
                  ),
                ),
              );
            },
          ),

          // Main scrollable content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // "EXPENSES" app title
                    AnimatedBuilder(
                      animation: _fadeInController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _titleFade.value,
                          child: ShaderMask(
                            shaderCallback: (bounds) =>
                                const LinearGradient(
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
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 10,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // "CREATE YOUR OWN ACCOUNT" subtitle
                    AnimatedBuilder(
                      animation: _fadeInController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _titleFade.value,
                          child: Column(
                            children: [
                              Text(
                                'CREATE YOUR OWN ACCOUNT',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 3,
                                  color: const Color(0xFF00FF66)
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    // Small rotating orb
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _orbRotationController,
                        _glowPulseController,
                        _fadeInController,
                      ]),
                      builder: (context, child) {
                        return Opacity(
                          opacity: _orbFade.value,
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glow behind orb
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00FF66)
                                            .withValues(
                                          alpha: 0.12 +
                                              _glowPulseController.value *
                                                  0.1,
                                        ),
                                        blurRadius: 30 +
                                            _glowPulseController.value * 15,
                                        spreadRadius: 5 +
                                            _glowPulseController.value * 8,
                                      ),
                                    ],
                                  ),
                                ),
                                Transform.rotate(
                                  angle:
                                      _orbRotationController.value * 2 * pi,
                                  child: CustomPaint(
                                    size: const Size(80, 80),
                                    painter: _MiniOrbPainter(
                                      rotation:
                                          _orbRotationController.value,
                                      glow: _glowPulseController.value,
                                    ),
                                  ),
                                ),
                                // Core dot
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00FF88)
                                            .withValues(alpha: 0.7),
                                        blurRadius: 8,
                                        spreadRadius: 2,
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

                    const SizedBox(height: 28),

                    // Form fields with slide-in animation
                    AnimatedBuilder(
                      animation: _fadeInController,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _formSlide,
                          child: Opacity(
                            opacity: _formFade.value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Full Name field
                          _buildFieldLabel('Full Name'),
                          const SizedBox(height: 8),
                          _buildGlowingTextField(
                            controller: _nameController,
                            hint: 'Enter your full name',
                            icon: Icons.person_outline_rounded,
                          ),

                          const SizedBox(height: 18),

                          // Email field
                          _buildFieldLabel('Email Address'),
                          const SizedBox(height: 8),
                          _buildGlowingTextField(
                            controller: _emailController,
                            hint: 'Enter your email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 18),

                          // Password field
                          _buildFieldLabel('Password'),
                          const SizedBox(height: 8),
                          _buildGlowingTextField(
                            controller: _passwordController,
                            hint: 'Create a password',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF00CC66)
                                    .withValues(alpha: 0.5),
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Profile type selection
                          _buildFieldLabel('Select Your Profile Type'),
                          const SizedBox(height: 12),
                          _buildProfileTypeSelector(),

                          const SizedBox(height: 24),

                          // Terms checkbox
                          _buildTermsCheckbox(),

                          const SizedBox(height: 28),

                          // Register button
                          _buildRegisterButton(),

                          const SizedBox(height: 24),

                          // Login link
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: 'Already have an Account? ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white
                                        .withValues(alpha: 0.4),
                                    fontWeight: FontWeight.w300,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Login',
                                      style: TextStyle(
                                        color: const Color(0xFF00FF66)
                                            .withValues(alpha: 0.9),
                                        fontWeight: FontWeight.w600,
                                        decoration:
                                            TextDecoration.underline,
                                        decorationColor:
                                            const Color(0xFF00FF66)
                                                .withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ],
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Colors.white.withValues(alpha: 0.6),
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildGlowingTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return AnimatedBuilder(
      animation: _glowPulseController,
      builder: (context, child) {
        final glowAlpha = 0.15 + _glowPulseController.value * 0.1;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FF66).withValues(alpha: glowAlpha),
                blurRadius: 12 + _glowPulseController.value * 6,
                spreadRadius: 0,
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
            cursorColor: const Color(0xFF00FF66),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.2),
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF00CC66).withValues(alpha: 0.5),
                size: 20,
              ),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: const Color(0xFF0A1A0E).withValues(alpha: 0.9),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: const Color(0xFF00FF66).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: const Color(0xFF00FF66).withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileTypeSelector() {
    return AnimatedBuilder(
      animation: _glowPulseController,
      builder: (context, child) {
        return Row(
          children: List.generate(_profileTypes.length, (index) {
            final isSelected = _selectedProfileType == index;
            final type = _profileTypes[index];
            final pulseVal = _glowPulseController.value;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedProfileType = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  margin: EdgeInsets.only(
                    right: index < _profileTypes.length - 1 ? 8 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected
                        ? const Color(0xFF0D2A14).withValues(alpha: 0.95)
                        : const Color(0xFF0A1A0E).withValues(alpha: 0.8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00FF66)
                              .withValues(alpha: 0.6 + pulseVal * 0.2)
                          : const Color(0xFF00FF66).withValues(alpha: 0.12),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00FF66)
                                  .withValues(alpha: 0.2 + pulseVal * 0.1),
                              blurRadius: 14 + pulseVal * 6,
                              spreadRadius: 0,
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        type.icon,
                        size: 22,
                        color: isSelected
                            ? const Color(0xFF00FF66)
                                .withValues(alpha: 0.9)
                            : Colors.white.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        type.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? const Color(0xFF00FF66)
                                  .withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.35),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildTermsCheckbox() {
    return AnimatedBuilder(
      animation: _glowPulseController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _agreedToTerms = !_agreedToTerms;
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Custom glowing checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: _agreedToTerms
                      ? const Color(0xFF0D2A14)
                      : const Color(0xFF0A1A0E).withValues(alpha: 0.9),
                  border: Border.all(
                    color: _agreedToTerms
                        ? const Color(0xFF00FF66).withValues(alpha: 0.7)
                        : const Color(0xFF00FF66).withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: _agreedToTerms
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00FF66).withValues(
                                alpha:
                                    0.25 + _glowPulseController.value * 0.1),
                            blurRadius:
                                10 + _glowPulseController.value * 4,
                            spreadRadius: 0,
                          ),
                        ]
                      : [],
                ),
                child: _agreedToTerms
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Color(0xFF00FF66),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: 'Agreement of ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w300,
                    ),
                    children: [
                      TextSpan(
                        text: 'services',
                        style: TextStyle(
                          color: const Color(0xFF00FF66)
                              .withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFF00FF66)
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      TextSpan(
                        text: ' & ',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      TextSpan(
                        text: 'conditions',
                        style: TextStyle(
                          color: const Color(0xFF00FF66)
                              .withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFF00FF66)
                              .withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegisterButton() {
    return AnimatedBuilder(
      animation: _glowPulseController,
      builder: (context, child) {
        final glowIntensity = 0.3 + _glowPulseController.value * 0.2;
        return Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(0xFF00FF66).withValues(alpha: glowIntensity),
                blurRadius: 18 + _glowPulseController.value * 10,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: const Color(0xFF00CC44)
                    .withValues(alpha: glowIntensity * 0.5),
                blurRadius: 30,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              // Handle registration
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D2A14),
              foregroundColor: const Color(0xFF00FF66),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: const Color(0xFF00FF66).withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Register',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileTypeOption {
  final String label;
  final IconData icon;

  _ProfileTypeOption(this.label, this.icon);
}

// Background glow for register page
class _RegisterBackgroundPainter extends CustomPainter {
  final double pulse;

  _RegisterBackgroundPainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    // Top center glow
    final topCenter = Offset(size.width / 2, size.height * 0.2);
    final topPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF003311).withValues(alpha: 0.35 + pulse * 0.1),
          const Color(0xFF001A08).withValues(alpha: 0.15 + pulse * 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 1.0],
      ).createShader(
        Rect.fromCenter(
          center: topCenter,
          width: size.width * 1.4,
          height: size.height * 0.7,
        ),
      );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      topPaint,
    );

    // Mid glow near profile types
    final midCenter = Offset(size.width / 2, size.height * 0.6);
    final midPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF002211).withValues(alpha: 0.1 + pulse * 0.04),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCenter(
          center: midCenter,
          width: size.width * 1.0,
          height: size.height * 0.3,
        ),
      );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      midPaint,
    );

    // Bottom edge glow near the button
    final bottomCenter = Offset(size.width / 2, size.height * 0.85);
    final bottomPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF002211).withValues(alpha: 0.15 + pulse * 0.05),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCenter(
          center: bottomCenter,
          width: size.width,
          height: size.height * 0.3,
        ),
      );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      bottomPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RegisterBackgroundPainter oldDelegate) =>
      oldDelegate.pulse != pulse;
}

// Floating particles for register screen
class _RegisterParticlesPainter extends CustomPainter {
  final double time;
  final double glow;

  _RegisterParticlesPainter({required this.time, required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(77);
    for (int i = 0; i < 18; i++) {
      final baseX = random.nextDouble();
      final baseY = random.nextDouble();
      final speed = 0.2 + random.nextDouble() * 0.5;
      final phase = random.nextDouble() * 2 * pi;
      final pSize = 0.4 + random.nextDouble() * 1.5;

      final x =
          (baseX + sin(time * 2 * pi * speed + phase) * 0.02) * size.width;
      final y = ((baseY + time * speed * 0.08) % 1.0) * size.height;
      final alpha = (0.1 + glow * 0.1) * (1.0 - (y / size.height) * 0.4);

      final paint = Paint()
        ..color =
            const Color(0xFF00FF88).withValues(alpha: alpha.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), pSize, paint);

      final glowPaint = Paint()
        ..color = const Color(0xFF00FF66)
            .withValues(alpha: (alpha * 0.25).clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(x, y), pSize * 2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RegisterParticlesPainter oldDelegate) => true;
}

// Mini orb painter (same as login screen)
class _MiniOrbPainter extends CustomPainter {
  final double rotation;
  final double glow;

  _MiniOrbPainter({required this.rotation, required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 * 0.8;

    for (int layer = 0; layer < 2; layer++) {
      for (int i = 0; i < 4; i++) {
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

        final layerAlpha = [0.6, 0.25][layer];
        final layerWidth = [1.8, 4.5][layer];
        final blur = [0.0, 5.0][layer];

        final hue = 130.0 + i * 22.0 - 35.0;
        paint.color = HSLColor.fromAHSL(
          (layerAlpha + glow * 0.12).clamp(0.0, 1.0),
          hue.clamp(85.0, 165.0),
          (0.75 + glow * 0.25).clamp(0.0, 1.0),
          (0.4 + glow * 0.12 + layer * -0.05).clamp(0.0, 1.0),
        ).toColor();
        paint.strokeWidth = layerWidth + glow * 0.6;

        if (blur > 0) {
          paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
        }

        final path = Path();
        final angleOffset = i * (2 * pi / 4);
        final timeShift = rotation * 2 * pi;

        final points = <Offset>[];
        for (double t = 0; t <= 1.0; t += 0.02) {
          final baseAngle = angleOffset + t * 2.5 * pi + timeShift;
          final r1 = sin(t * pi) * 0.85;
          final r2 = sin(t * 4.5 + timeShift * 1.3 + i) * 0.12;
          final radiusFactor = (r1 + r2).clamp(0.0, 1.0);
          final radius = maxRadius * (0.15 + 0.85 * radiusFactor);

          final displacement =
              sin(t * 6 + timeShift * 2.0 + i * 1.3) * 6 * sin(t * pi);
          final x = center.dx +
              cos(baseAngle) * radius +
              cos(baseAngle + pi / 2) * displacement;
          final y = center.dy +
              sin(baseAngle) * radius +
              sin(baseAngle + pi / 2) * displacement;
          points.add(Offset(x, y));
        }

        if (points.length < 3) continue;

        path.moveTo(points[0].dx, points[0].dy);
        for (int j = 1; j < points.length - 1; j++) {
          final midX = (points[j].dx + points[j + 1].dx) / 2;
          final midY = (points[j].dy + points[j + 1].dy) / 2;
          path.quadraticBezierTo(points[j].dx, points[j].dy, midX, midY);
        }
        canvas.drawPath(path, paint);
      }
    }

    // Accent dots
    final random = Random(13);
    for (int i = 0; i < 10; i++) {
      final angle =
          (i * pi / 5) + (rotation * 2 * pi * 0.6) + random.nextDouble();
      final radiusFactor =
          0.2 + 0.5 * sin(i * 0.8 + rotation * 4 * pi).abs();
      final r = maxRadius * radiusFactor;
      final x = center.dx + cos(angle) * r;
      final y = center.dy + sin(angle) * r;

      final dotPaint = Paint()
        ..color = Color.lerp(
          const Color(0xFF00FF66),
          const Color(0xFF88FFCC),
          glow,
        )!.withValues(alpha: (0.5 + glow * 0.4).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), 1.0 + glow * 0.6, dotPaint);

      final haloPaint = Paint()
        ..color = const Color(0xFF00FF66).withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(x, y), 3 + glow, haloPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniOrbPainter oldDelegate) => true;
}
