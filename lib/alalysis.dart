import 'dart:math';
import 'package:flutter/material.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});
  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage>
    with TickerProviderStateMixin {
  String _period = 'This Month';

  late AnimationController _orbController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  static const _indigo = Color(0xFF6366F1);
  static const _purple = Color(0xFFA855F7);
  static const _bg = Color(0xFF0F1117);

  final List<String> _periods = [
    'This Month', '3 Months', '6 Months', 'Year'
  ];

  // Replace with real data from your model/provider
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food',        'amount': 18400, 'color': Color(0xFFEC4899), 'icon': Icons.restaurant_outlined,       'pct': 0.82},
    {'name': 'Electricity', 'amount': 12800, 'color': Color(0xFF6366F1), 'icon': Icons.bolt_outlined,             'pct': 0.58},
    {'name': 'Shopping',    'amount': 9600,  'color': Color(0xFFF59E0B), 'icon': Icons.shopping_bag_outlined,     'pct': 0.44},
    {'name': 'Transport',   'amount': 7200,  'color': Color(0xFF14B8A6), 'icon': Icons.directions_car_outlined,   'pct': 0.32},
    {'name': 'Health',      'amount': 4800,  'color': Color(0xFFA855F7), 'icon': Icons.favorite_border_rounded,   'pct': 0.22},
    {'name': 'Other',       'amount': 7200,  'color': Color(0xFFF09595), 'icon': Icons.more_horiz_rounded,        'pct': 0.32},
  ];

  final List<double> _monthlyTrend = [
    48000, 55000, 42000, 68000, 52000, 60000, 71000, 63000
  ];
  final List<String> _months = [
    'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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

    _fadeAnim = CurvedAnimation(
        parent: _fadeController, curve: Curves.easeOut);
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
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.08)),
                              ),
                              child: const Icon(
                                  Icons.chevron_left_rounded,
                                  color: Colors.white54, size: 20),
                            ),
                          ),
                        ),
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          Text('EXPENSES',
                              style: TextStyle(
                                fontFamily: 'SpaceMono',
                                fontSize: 8,
                                letterSpacing: 2.5,
                                color: _indigo.withOpacity(0.6),
                              )),
                          const Text('Analysis',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                color: Color(0xFFF8FAFC),
                              )),
                        ]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Period filter ─────────────────
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _periods.map((p) {
                                final active = _period == p;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _period = p),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 200),
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: active
                                            ? _indigo.withOpacity(0.18)
                                            : Colors.white.withOpacity(0.04),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                          color: active
                                              ? _indigo.withOpacity(0.45)
                                              : Colors.white.withOpacity(0.08),
                                        ),
                                      ),
                                      child: Text(p,
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 12,
                                            color: active
                                                ? const Color(0xFF818CF8)
                                                : Colors.white.withOpacity(0.4),
                                          )),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ── Summary cards ─────────────────
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1.9,
                            children: [
                              _SummaryCard(
                                label: 'Total Spent',
                                value: 'Rs. 60,000',
                                sub: '▲ 12% vs last',
                                subColor: const Color(0xFFF09595),
                              ),
                              _SummaryCard(
                                label: 'Remaining',
                                value: 'Rs. 90,000',
                                valueColor: const Color(0xFF818CF8),
                                sub: '60% of budget',
                                subColor: const Color(0xFF5DCAA5),
                              ),
                              _SummaryCard(
                                label: 'Transactions',
                                value: '24',
                                sub: 'This month',
                                subColor:
                                    Colors.white.withOpacity(0.3),
                              ),
                              _SummaryCard(
                                label: 'Avg / Day',
                                value: 'Rs. 2,000',
                                sub: '14 days active',
                                subColor:
                                    Colors.white.withOpacity(0.3),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ── Category Spending card ─────────
                          _Card(
                            title: 'Category Spending',
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    // Bar chart
                                    Expanded(
                                      child: SizedBox(
                                        height: 100,
                                        child: CustomPaint(
                                          painter: _BarChartPainter(
                                              _categories),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Donut chart
                                    SizedBox(
                                      width: 90,
                                      height: 100,
                                      child: CustomPaint(
                                        painter: _DonutPainter(
                                            _categories),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Legend
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 6,
                                  children: _categories
                                      .map((c) => Row(
                                            mainAxisSize:
                                                MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 8, height: 8,
                                                decoration: BoxDecoration(
                                                  color: c['color']
                                                      as Color,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                c['name'] as String,
                                                style: TextStyle(
                                                  fontFamily: 'Outfit',
                                                  fontSize: 10,
                                                  color: Colors.white
                                                      .withOpacity(0.45),
                                                ),
                                              ),
                                            ],
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(height: 14),
                                // Action buttons
                                Row(children: [
                                  Expanded(
                                    child: _ActionButton(
                                      label: 'Download PDF',
                                      icon: Icons.picture_as_pdf_outlined,
                                      color: const Color(0xFFF09595),
                                      onTap: () {
                                        // 👉 PDF export logic
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _ActionButton(
                                      label: 'Export CSV',
                                      icon: Icons.table_chart_outlined,
                                      color: const Color(0xFF5DCAA5),
                                      onTap: () {
                                        // 👉 CSV export logic
                                      },
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ── Top Spending ──────────────────
                          _Card(
                            title: 'Top Spending Data',
                            child: Column(
                              children: List.generate(
                                _categories.length,
                                (i) => _TopSpendingItem(
                                  rank: i + 1,
                                  category: _categories[i],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ── Monthly Trend ─────────────────
                          _Card(
                            title: 'Monthly Trend',
                            child: SizedBox(
                              height: 100,
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: _LineTrendPainter(
                                  values: _monthlyTrend,
                                  labels: _months,
                                  color: _indigo,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const _BottomNav(activeIndex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary Card ───────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label, value, sub;
  final Color? valueColor;
  final Color subColor;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.subColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 9,
                letterSpacing: 0.6,
                color: Colors.white.withOpacity(0.3),
              )),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color:
                    valueColor ?? const Color(0xFFF8FAFC),
              )),
          const SizedBox(height: 2),
          Text(sub,
              style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 10,
                  color: subColor)),
        ],
      ),
    );
  }
}

// ── Card wrapper ───────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF8FAFC),
              )),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ── Top Spending Item ──────────────────────────────────────────────────────

class _TopSpendingItem extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> category;
  const _TopSpendingItem(
      {required this.rank, required this.category});

  @override
  Widget build(BuildContext context) {
    final Color color = category['color'] as Color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text('#$rank',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.25),
                )),
          ),
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.22)),
            ),
            child: Icon(category['icon'] as IconData,
                size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category['name'] as String,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFF8FAFC),
                    )),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: category['pct'] as double,
                    minHeight: 4,
                    backgroundColor:
                        Colors.white.withOpacity(0.07),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Rs. ${_fmt(category['amount'] as int)}',
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF8FAFC),
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

// ── Action Button ──────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color,
                )),
          ],
        ),
      ),
    );
  }
}

// ── Bar Chart Painter ──────────────────────────────────────────────────────

class _BarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> categories;
  const _BarChartPainter(this.categories);

  @override
  void paint(Canvas canvas, Size size) {
    final maxAmt = categories
        .map((c) => c['amount'] as int)
        .reduce(max)
        .toDouble();
    final barW = (size.width - (categories.length - 1) * 6) /
        categories.length;

    for (int i = 0; i < categories.length; i++) {
      final pct = (categories[i]['amount'] as int) / maxAmt;
      final barH = (size.height - 16) * pct;
      final x = i * (barW + 6);
      final y = size.height - 16 - barH;

      final paint = Paint()
        ..color = (categories[i]['color'] as Color).withOpacity(0.85)
        ..style = PaintingStyle.fill;

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barW, barH),
        const Radius.circular(4),
      );
      canvas.drawRRect(rrect, paint);
    }

    // Baseline
    final line = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 0.8;
    canvas.drawLine(
      Offset(0, size.height - 16),
      Offset(size.width, size.height - 16),
      line,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Donut Painter ──────────────────────────────────────────────────────────

class _DonutPainter extends CustomPainter {
  final List<Map<String, dynamic>> categories;
  const _DonutPainter(this.categories);

  @override
  void paint(Canvas canvas, Size size) {
    final total = categories
        .map((c) => c['amount'] as int)
        .fold(0, (a, b) => a + b)
        .toDouble();

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;
    const strokeW = 14.0;

    double startAngle = -pi / 2;

    for (final cat in categories) {
      final sweep =
          2 * pi * (cat['amount'] as int) / total;
      final paint = Paint()
        ..color = cat['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep - 0.08,
        false,
        paint,
      );
      startAngle += sweep;
    }

    // Center text
    final tp = TextPainter(
      text: const TextSpan(
        text: '60k',
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF8FAFC),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      center - Offset(tp.width / 2, tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Line Trend Painter ─────────────────────────────────────────────────────

class _LineTrendPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color color;
  const _LineTrendPainter({
    required this.values,
    required this.labels,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = values.reduce(max);
    final minV = values.reduce(min);
    final range = maxV - minV == 0 ? 1 : maxV - minV;
    final chartH = size.height - 20;
    final stepX = size.width / (values.length - 1);

    List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = chartH - ((values[i] - minV) / range) * chartH * 0.85;
      points.add(Offset(x, y));
    }

    // Fill
    final fillPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath.lineTo(points.last.dx, chartH);
    fillPath.lineTo(points.first.dx, chartH);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = color.withOpacity(0.7)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Peak dot
    final peakIdx = values.indexOf(values.reduce(max));
    canvas.drawCircle(
        points[peakIdx], 4, Paint()..color = color);
    canvas.drawCircle(
        points[peakIdx],
        7,
        Paint()..color = color.withOpacity(0.2));

    // Labels
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < labels.length; i++) {
      tp.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 9,
          color: Colors.white.withOpacity(0.25),
        ),
      );
      tp.layout();
      tp.paint(canvas,
          Offset(i * stepX - tp.width / 2, size.height - 14));
    }
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
      (Icons.chat_bubble_outline_rounded,
          Icons.chat_bubble_rounded, 'Groups'),
      (Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Analytics'),
      (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
    ];
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.025),
        border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.07))),
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
                Icon(active ? items[i].$2 : items[i].$1, size: 22,
                    color: active
                        ? const Color(0xFF818CF8)
                        : Colors.white.withOpacity(0.28)),
                const SizedBox(height: 3),
                Text(items[i].$3,
                    style: TextStyle(
                        fontFamily: 'Outfit', fontSize: 10,
                        color: active
                            ? const Color(0xFF818CF8)
                            : Colors.white.withOpacity(0.28))),
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
          gradient:
              RadialGradient(colors: [color, Colors.transparent]),
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