import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _orbController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  static const _indigo = Color(0xFF6366F1);
  static const _violet = Color(0xFF8B5CF6);
  static const _purple = Color(0xFFA855F7);
  static const _bg = Color(0xFF0F1117);

  // Sample expense data — replace with your real model
  final List<Map<String, dynamic>> _expenses = [
    {
      'name': 'Groceries',
      'date': 'Today, 10:30 AM',
      'account': 'Personal',
      'amount': -3200,
      'icon': Icons.shopping_bag_outlined,
      'color': Color(0xFF6366F1),
    },
    {
      'name': 'Salary Credit',
      'date': 'Yesterday',
      'account': 'Family',
      'amount': 85000,
      'icon': Icons.account_balance_outlined,
      'color': Color(0xFF14B8A6),
    },
    {
      'name': 'Dining Out',
      'date': 'Jul 12',
      'account': 'Friends',
      'amount': -1800,
      'icon': Icons.restaurant_outlined,
      'color': Color(0xFFEC4899),
    },
    {
      'name': 'Office Supplies',
      'date': 'Jul 11',
      'account': 'Marketing',
      'amount': -5400,
      'icon': Icons.business_center_outlined,
      'color': Color(0xFFF59E0B),
    },
  ];

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this, duration: const Duration(seconds: 7),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 16, end: 0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _orbController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // ── Orbs ──────────────────────────────────────────
          AnimatedBuilder(
            animation: _orbController,
            builder: (_, __) {
              final t = _orbController.value;
              final w = MediaQuery.of(context).size.width;
              final h = MediaQuery.of(context).size.height;
              return Stack(children: [
                _Orb(x: -70 + 30 * t, y: -90 + 40 * t,
                    size: 300, color: _indigo.withOpacity(0.22)),
                _Orb(x: w - 160 - 20 * t, y: h - 260 + 26 * t,
                    size: 220, color: _purple.withOpacity(0.14)),
              ]);
            },
          ),

          CustomPaint(size: Size.infinite, painter: _GridPainter()),

          // ── Content ───────────────────────────────────────
          SafeArea(
            child: AnimatedBuilder(
              animation: _fadeAnim,
              builder: (_, child) => Opacity(
                opacity: _fadeAnim.value,
                child: Transform.translate(
                    offset: Offset(0, _slideAnim.value), child: child),
              ),
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(children: [
                      Text(
                        'EXPENSES',
                        style: TextStyle(
                          fontFamily: 'SpaceMono',
                          fontSize: 8,
                          letterSpacing: 2.5,
                          color: _indigo.withOpacity(0.6),
                        ),
                      ),
                      const Text(
                        'Dashboard',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          color: Color(0xFFF8FAFC),
                        ),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 14),

                  // Scrollable body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Stat cards ───────────────────
                          Row(children: [
                            Expanded(
                              child: _StatCard(
                                label: 'Current Month Spending',
                                value: 'Rs. 60,000',
                                sub: '▲ 12% vs last month',
                                subColor: const Color(0xFFF09595),
                                valueColor: const Color(0xFFF8FAFC),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatCard(
                                label: 'Remaining Budget',
                                value: 'Rs. 90,000',
                                sub: '60% remaining',
                                subColor: const Color(0xFF5DCAA5),
                                valueColor: const Color(0xFF818CF8),
                              ),
                            ),
                          ]),

                          const SizedBox(height: 14),

                          // ── Budget progress bar ──────────
                          _BudgetBar(
                            spent: 60000,
                            total: 150000,
                            color: _indigo,
                          ),

                          const SizedBox(height: 14),

                          // ── Quick actions ────────────────
                          Row(children: [
                            Expanded(
                              child: _QuickAction(
                                icon: Icons.add_card_outlined,
                                label: 'Add Expense',
                                color: const Color(0xFF818CF8),
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _QuickAction(
                                icon: Icons.history_rounded,
                                label: 'History',
                                color: const Color(0xFF5DCAA5),
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _QuickAction(
                                icon: Icons.bar_chart_rounded,
                                label: 'Analytics',
                                color: const Color(0xFFEC4899),
                                onTap: () {},
                              ),
                            ),
                          ]),

                          const SizedBox(height: 16),

                          // ── Expense history ──────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Expense History',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF8FAFC),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap),
                                child: const Text(
                                  'See all →',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 12,
                                    color: Color(0xFF818CF8),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          ..._expenses.map((e) => _ExpenseItem(expense: e)),

                          const SizedBox(height: 16),

                          // ── Find Loved Ones map card ─────
                          const Text(
                            'Find Your Loved Ones',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF8FAFC),
                            ),
                          ),

                          const SizedBox(height: 10),

                          _LovedOnesMapCard(
                            onTap: () {
                              // 👉 Navigate to map/location page
                              Navigator.pushNamed(context, '/loved-ones');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const _BottomNav(activeIndex: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ──────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label, value, sub;
  final Color subColor, valueColor;
  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.subColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 10,
              color: Colors.white.withOpacity(0.35),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 10,
              color: subColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Budget Bar ─────────────────────────────────────────────────────────────

class _BudgetBar extends StatelessWidget {
  final double spent, total;
  final Color color;
  const _BudgetBar({
    required this.spent,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (spent / total).clamp(0.0, 1.0);
    final pctLabel = '${(pct * 100).round()}% of Rs. ${_fmt(total.toInt())}';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Budget used',
                style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.35))),
            Text(pctLabel,
                style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 10,
                    color: Color(0xFF818CF8))),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: Colors.white.withOpacity(0.07),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF818CF8)),
          ),
        ),
      ],
    );
  }

  String _fmt(int v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)},000';
    return v.toString();
  }
}

// ── Quick Action ───────────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 10,
                color: Colors.white.withOpacity(0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Expense Item ───────────────────────────────────────────────────────────

class _ExpenseItem extends StatelessWidget {
  final Map<String, dynamic> expense;
  const _ExpenseItem({required this.expense});

  @override
  Widget build(BuildContext context) {
    final Color color = expense['color'] as Color;
    final int amount = expense['amount'] as int;
    final bool isPositive = amount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: color.withOpacity(0.22)),
            ),
            child: Icon(expense['icon'] as IconData, size: 18, color: color),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense['name'] as String,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFF8FAFC),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${expense['date']} · ${expense['account']}',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.32),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : '-'} Rs. ${_fmt(amount.abs())}',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isPositive
                  ? const Color(0xFF5DCAA5)
                  : const Color(0xFFF09595),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int v) {
    if (v >= 1000) {
      final s = v.toString();
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return v.toString();
  }
}

// ── Loved Ones Map Card ────────────────────────────────────────────────────

class _LovedOnesMapCard extends StatelessWidget {
  final VoidCallback onTap;
  const _LovedOnesMapCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.25)),
          color: const Color(0xFF0D1520),
        ),
        child: Stack(
          children: [
            // Map grid background
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CustomPaint(
                size: const Size(double.infinity, 130),
                painter: _MapGridPainter(),
              ),
            ),

            // Gradient overlay (right side for text)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF0D1520).withOpacity(0.2),
                    const Color(0xFF0D1520).withOpacity(0.92),
                  ],
                  stops: const [0.0, 0.55],
                ),
              ),
            ),

            // Location pins (left side)
            Positioned(
              left: 16, top: 28,
              child: _LocationPin(color: const Color(0xFF6366F1), label: 'Jane'),
            ),
            Positioned(
              left: 55, top: 55,
              child: _LocationPin(color: const Color(0xFFEC4899), label: ''),
            ),
            Positioned(
              left: 28, top: 72,
              child: _LocationPin(color: const Color(0xFF14B8A6), label: ''),
            ),

            // Text content (right side)
            Positioned(
              right: 0, top: 0, bottom: 0,
              width: MediaQuery.of(context).size.width * 0.52,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LOCATION',
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 8,
                        letterSpacing: 1.8,
                        color: const Color(0xFF818CF8).withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Find Your\nLoved Ones',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: Color(0xFFF8FAFC),
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color:
                                const Color(0xFF6366F1).withOpacity(0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF818CF8),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            '3 online',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 10,
                              color: Color(0xFF818CF8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tap arrow indicator
            Positioned(
              right: 14, bottom: 14,
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.3)),
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    size: 14, color: Color(0xFF818CF8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Location Pin ───────────────────────────────────────────────────────────

class _LocationPin extends StatelessWidget {
  final Color color;
  final String label;
  const _LocationPin({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.85),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 8,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 2),
        ],
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 6),
            ],
          ),
        ),
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

// ── Map Grid Painter ───────────────────────────────────────────────────────

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.1)
      ..strokeWidth = 0.8;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    // Subtle road lines
    final roadPaint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.25)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final path1 = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
          size.width * 0.3, size.height * 0.45,
          size.width * 0.6, size.height * 0.38);
    canvas.drawPath(path1, roadPaint);
    final roadPaint2 = Paint()
      ..color = const Color(0xFFA855F7).withOpacity(0.15)
      ..strokeWidth = 1.0;
    final path2 = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(
          size.width * 0.4, size.height * 0.65,
          size.width * 0.6, size.height * 0.58);
    canvas.drawPath(path2, roadPaint2);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Bottom Nav ─────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int activeIndex;
  const _BottomNav({required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_outlined, Icons.home_rounded, 'Home'),
      (Icons.add_box_outlined, Icons.add_box_rounded, 'Add'),
      (Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Analytics'),
      (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
    ];
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.025),
        border:
            Border(top: BorderSide(color: Colors.white.withOpacity(0.07))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = i == activeIndex;
          return GestureDetector(
            onTap: () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  active ? items[i].$2 : items[i].$1,
                  size: 22,
                  color: active
                      ? const Color(0xFF818CF8)
                      : Colors.white.withOpacity(0.28),
                ),
                const SizedBox(height: 3),
                Text(
                  items[i].$3,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 10,
                    color: active
                        ? const Color(0xFF818CF8)
                        : Colors.white.withOpacity(0.28),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Shared Helpers ─────────────────────────────────────────────────────────

class _Orb extends StatelessWidget {
  final double x, y, size;
  final Color color;
  const _Orb({required this.x, required this.y,
      required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x, top: y,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.022)
      ..strokeWidth = 0.5;
    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}