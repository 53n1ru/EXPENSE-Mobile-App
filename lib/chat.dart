import 'package:flutter/material.dart';

class GroupChatPage extends StatefulWidget {
  final String groupName;
  final String groupInitial;
  final Color groupColor;

  const GroupChatPage({
    super.key,
    required this.groupName,
    required this.groupInitial,
    required this.groupColor,
  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  late AnimationController _orbController;

  static const _indigo = Color(0xFF6366F1);
  static const _purple = Color(0xFFA855F7);
  static const _bg = Color(0xFF0F1117);

  // Replace with your real message model / stream
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      sender: 'Ravi', initial: 'R',
      color: Color(0xFF14B8A6),
      text: "Hey everyone! Let's track this month's expenses together 💪",
      time: '9:14 AM', isMe: false,
    ),
    _ChatMessage(
      sender: 'Mom', initial: 'M',
      color: Color(0xFFEC4899),
      text: 'Sure! I just paid the electricity bill.',
      time: '9:16 AM', isMe: false,
    ),
    _ChatMessage(
      sender: 'Mom', initial: 'M',
      color: Color(0xFFEC4899),
      text: '', time: '9:16 AM', isMe: false,
      isExpenseCard: true,
      expenseAmount: 'Rs. 3,200',
      expenseDesc: 'Electricity Bill · Personal · Jul 14',
      expenseIcon: '💡',
    ),
    _ChatMessage(
      sender: 'Dad', initial: 'D',
      color: Color(0xFFF59E0B),
      text: "I'll handle groceries today. Around 2k.",
      time: '10:02 AM', isMe: false,
    ),
    _ChatMessage(
      sender: 'You', initial: 'J',
      color: Color(0xFF818CF8),
      text: 'I logged the water bill too. Rs. 850 this month 💧',
      time: '10:15 AM', isMe: true,
    ),
    _ChatMessage(
      sender: 'You', initial: 'J',
      color: Color(0xFF818CF8),
      text: '', time: '10:15 AM', isMe: true,
      isExpenseCard: true,
      expenseAmount: 'Rs. 850',
      expenseDesc: 'Water Bill · Family · Jul 14',
      expenseIcon: '💧',
    ),
    _ChatMessage(
      sender: 'Ravi', initial: 'R',
      color: Color(0xFF14B8A6),
      text: "Great! We're at Rs. 6,250 so far this month.",
      time: '10:18 AM', isMe: false,
    ),
    _ChatMessage(
      sender: 'You', initial: 'J',
      color: Color(0xFF818CF8),
      text: 'Still within budget 🎉',
      time: '10:19 AM', isMe: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this, duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orbController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(
        sender: 'You', initial: 'J',
        color: const Color(0xFF818CF8),
        text: text,
        time: _nowTime(),
        isMe: true,
      ));
    });
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _nowTime() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
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
                    size: 300, color: _indigo.withOpacity(0.18)),
                _Orb(x: w - 160 - 20 * t, y: h - 260 + 26 * t,
                    size: 220, color: _purple.withOpacity(0.12)),
              ]);
            },
          ),

          CustomPaint(size: Size.infinite, painter: _GridPainter()),

          SafeArea(
            child: Column(
              children: [
                // ── Chat top bar ─────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.025),
                    border: Border(
                        bottom: BorderSide(
                            color: Colors.white.withOpacity(0.06))),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.08)),
                          ),
                          child: const Icon(Icons.chevron_left_rounded,
                              color: Colors.white54, size: 20),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Group avatar
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: widget.groupColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color:
                                  widget.groupColor.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(
                            widget.groupInitial,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: widget.groupColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(widget.groupName,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF8FAFC),
                                )),
                            Text('4 members · 3 online',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.35),
                                )),
                          ],
                        ),
                      ),

                      // Action buttons
                      Row(children: [
                        _IconBtn(
                          icon: Icons.history_rounded,
                          onTap: () {},
                        ),
                        const SizedBox(width: 6),
                        _IconBtn(
                          icon: Icons.more_horiz_rounded,
                          onTap: () {},
                        ),
                      ]),
                    ],
                  ),
                ),

                // ── Messages ─────────────────────────────
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                    itemCount: _messages.length + 1,
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        return Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(bottom: 14),
                            child: Text('Today',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.22),
                                )),
                          ),
                        );
                      }
                      return _MessageBubble(
                          message: _messages[i - 1]);
                    },
                  ),
                ),

                // ── Input bar ────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    border: Border(
                        top: BorderSide(
                            color: Colors.white.withOpacity(0.06))),
                  ),
                  child: Row(
                    children: [
                      // Attach
                      _IconBtn(
                        icon: Icons.attach_file_rounded,
                        onTap: () {},
                      ),
                      const SizedBox(width: 8),

                      // Text input
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    Colors.white.withOpacity(0.09)),
                          ),
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 13,
                                color: Color(0xFFF8FAFC)),
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 13,
                                  color:
                                      Colors.white.withOpacity(0.25)),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Mic
                      _IconBtn(
                        icon: Icons.mic_none_rounded,
                        onTap: () {},
                      ),
                      const SizedBox(width: 6),

                      // Send
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6366F1),
                                Color(0xFFA855F7)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1)
                                    .withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.send_rounded,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Message Bubble ─────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isExpenseCard) {
      return Align(
        alignment: message.isMe
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            bottom: 10,
            left: message.isMe ? 48 : 36,
            right: message.isMe ? 0 : 48,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: message.isMe
                ? const Color(0xFF6366F1).withOpacity(0.12)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: message.isMe
                  ? const Color(0xFF6366F1).withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${message.expenseIcon} Expense logged',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 9,
                  letterSpacing: 0.8,
                  color: message.isMe
                      ? const Color(0xFF818CF8).withOpacity(0.8)
                      : Colors.white.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message.expenseAmount ?? '',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message.expenseDesc ?? '',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: message.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: message.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Center(
                child: Text(message.initial,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: message.color,
                    )),
              ),
            ),
            const SizedBox(width: 7),
          ],

          Column(
            crossAxisAlignment: message.isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (!message.isMe)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3, left: 2),
                  child: Text(message.sender,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 9,
                        color: Colors.white.withOpacity(0.35),
                      )),
                ),
              Container(
                constraints: BoxConstraints(
                  maxWidth:
                      MediaQuery.of(context).size.width * 0.65,
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 13, vertical: 9),
                decoration: BoxDecoration(
                  color: message.isMe
                      ? const Color(0xFF6366F1).withOpacity(0.22)
                      : Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(14),
                    topRight: const Radius.circular(14),
                    bottomLeft: Radius.circular(
                        message.isMe ? 14 : 4),
                    bottomRight: Radius.circular(
                        message.isMe ? 4 : 14),
                  ),
                  border: Border.all(
                    color: message.isMe
                        ? const Color(0xFF6366F1).withOpacity(0.3)
                        : Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Text(message.text,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      color: Color(0xFFF8FAFC),
                      height: 1.4,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 3, left: 2, right: 2),
                child: Text(message.time,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 9,
                      color: Colors.white.withOpacity(0.22),
                    )),
              ),
            ],
          ),

          if (message.isMe) ...[
            const SizedBox(width: 7),
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: message.color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Center(
                child: Text(message.initial,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: message.color,
                    )),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Icon Button ────────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Icon(icon,
            size: 17, color: Colors.white.withOpacity(0.4)),
      ),
    );
  }
}

// ── Data Model ─────────────────────────────────────────────────────────────

class _ChatMessage {
  final String sender, initial, text, time;
  final Color color;
  final bool isMe;
  final bool isExpenseCard;
  final String? expenseAmount, expenseDesc, expenseIcon;

  const _ChatMessage({
    required this.sender,
    required this.initial,
    required this.text,
    required this.time,
    required this.color,
    required this.isMe,
    this.isExpenseCard = false,
    this.expenseAmount,
    this.expenseDesc,
    this.expenseIcon,
  });
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