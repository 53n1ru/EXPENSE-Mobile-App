import 'package:flutter/material.dart';

// ── Groups List Page ───────────────────────────────────────────────────────

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});
  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  late AnimationController _orbController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  static const _indigo = Color(0xFF6366F1);
  static const _purple = Color(0xFFA855F7);
  static const _bg = Color(0xFF0F1117);

  final List<Map<String, dynamic>> _groups = [
    {
      'name': 'Family',
      'initial': 'F',
      'color': Color(0xFF6366F1),
      'lastMessage': 'Jane: Paid electricity bill 🔔',
      'time': '2m ago',
      'unread': 3,
    },
    {
      'name': 'Friends',
      'initial': 'Fr',
      'color': Color(0xFFEC4899),
      'lastMessage': 'You: Split the dinner 🍽️',
      'time': '1h ago',
      'unread': 0,
    },
    {
      'name': 'Marketing',
      'initial': 'M',
      'color': Color(0xFFF59E0B),
      'lastMessage': 'Office supplies logged',
      'time': '3h ago',
      'unread': 1,
    },
    {
      'name': 'Trip 2025',
      'initial': 'T',
      'color': Color(0xFF14B8A6),
      'lastMessage': 'Ravi: Hotel booked ✈️',
      'time': 'Yesterday',
      'unread': 0,
    },
    {
      'name': 'Solo',
      'initial': 'S',
      'color': Color(0xFFA855F7),
      'lastMessage': 'Personal expense added',
      'time': 'Jul 12',
      'unread': 0,
    },
  ];

  List<Map<String, dynamic>> get _filtered => _groups
      .where((g) => (g['name'] as String)
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()))
      .toList();

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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _indigo.withOpacity(0.4),
              blurRadius: 16, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.add_rounded,
              color: Colors.white, size: 24),
          onPressed: () {},
        ),
      ),
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
                    offset: Offset(0, _slideAnim.value),
                    child: child),
              ),
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
                                color:
                                    Colors.white.withOpacity(0.05),
                                borderRadius:
                                    BorderRadius.circular(11),
                                border: Border.all(
                                    color: Colors.white
                                        .withOpacity(0.08)),
                              ),
                              child: const Icon(
                                  Icons.chevron_left_rounded,
                                  color: Colors.white54, size: 20),
                            ),
                          ),
                        ),
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('EXPENSES',
                                  style: TextStyle(
                                    fontFamily: 'SpaceMono',
                                    fontSize: 8,
                                    letterSpacing: 2.5,
                                    color: _indigo.withOpacity(0.6),
                                  )),
                              const Text('Groups',
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

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) =>
                          setState(() => _searchQuery = v),
                      style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          color: Color(0xFFF8FAFC)),
                      decoration: InputDecoration(
                        hintText: 'Search groups...',
                        hintStyle: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.25)),
                        prefixIcon: Icon(Icons.search_rounded,
                            size: 18,
                            color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
                        contentPadding:
                            const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color:
                                  Colors.white.withOpacity(0.08)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                              color: Color(0xFF6366F1), width: 1.2),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Groups list
                  Expanded(
                    child: ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(16, 4, 16, 80),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) {
                        final g = _filtered[i];
                        return _GroupItem(
                          group: g,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GroupChatPage(
                                groupName: g['name'] as String,
                                groupInitial:
                                    g['initial'] as String,
                                groupColor: g['color'] as Color,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Group Item ─────────────────────────────────────────────────────────────

class _GroupItem extends StatelessWidget {
  final Map<String, dynamic> group;
  final VoidCallback onTap;
  const _GroupItem({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color color = group['color'] as Color;
    final int unread = group['unread'] as int;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(13),
                border:
                    Border.all(color: color.withOpacity(0.25)),
              ),
              child: Center(
                child: Text(
                  group['initial'] as String,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group['name'] as String,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF8FAFC),
                      )),
                  const SizedBox(height: 3),
                  Text(group['lastMessage'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.32),
                      )),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(group['time'] as String,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.28),
                    )),
                if (unread > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 20, height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6366F1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('$unread',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          )),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Group Chat Page ────────────────────────────────────────────────────────

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
          // ✅ FIXED: changed (_, _) to (_, __)
          AnimatedBuilder(
            animation: _orbController,
            builder: (_, __) {
              final t = _orbController.value;
              final w = MediaQuery.of(context).size.width;
              final h = MediaQuery.of(context).size.height;
              return Stack(children: [
                _Orb(x: -70 + 30 * t, y: -90 + 40 * t,
                    size: 300,
                    color: _indigo.withOpacity(0.18)),
                _Orb(x: w - 160 - 20 * t, y: h - 260 + 26 * t,
                    size: 220,
                    color: _purple.withOpacity(0.12)),
              ]);
            },
          ),

          CustomPaint(
              size: Size.infinite, painter: _GridPainter()),

          SafeArea(
            child: Column(
              children: [
                // ── Chat top bar ───────────────────────
                Container(
                  padding:
                      const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.025),
                    border: Border(
                        bottom: BorderSide(
                            color:
                                Colors.white.withOpacity(0.06))),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withOpacity(0.05),
                            borderRadius:
                                BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.white
                                    .withOpacity(0.08)),
                          ),
                          child: const Icon(
                              Icons.chevron_left_rounded,
                              color: Colors.white54, size: 20),
                        ),
                      ),
                      const SizedBox(width: 10),

                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: widget.groupColor
                              .withOpacity(0.15),
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                              color: widget.groupColor
                                  .withOpacity(0.3)),
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
                                  color: Colors.white
                                      .withOpacity(0.35),
                                )),
                          ],
                        ),
                      ),

                      Row(children: [
                        _IconBtn(
                            icon: Icons.history_rounded,
                            onTap: () {}),
                        const SizedBox(width: 6),
                        _IconBtn(
                            icon: Icons.more_horiz_rounded,
                            onTap: () {}),
                      ]),
                    ],
                  ),
                ),

                // ── Messages ──────────────────────────
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                        14, 14, 14, 8),
                    itemCount: _messages.length + 1,
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 14),
                            child: Text('Today',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 11,
                                  color: Colors.white
                                      .withOpacity(0.22),
                                )),
                          ),
                        );
                      }
                      return _MessageBubble(
                          message: _messages[i - 1]);
                    },
                  ),
                ),

                // ── Input bar ─────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(
                      12, 8, 12, 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    border: Border(
                        top: BorderSide(
                            color:
                                Colors.white.withOpacity(0.06))),
                  ),
                  child: Row(
                    children: [
                      _IconBtn(
                          icon: Icons.attach_file_rounded,
                          onTap: () {}),
                      const SizedBox(width: 8),

                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withOpacity(0.05),
                            borderRadius:
                                BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white
                                    .withOpacity(0.09)),
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
                                  color: Colors.white
                                      .withOpacity(0.25)),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      _IconBtn(
                          icon: Icons.mic_none_rounded,
                          onTap: () {}),
                      const SizedBox(width: 6),

                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(12),
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
                  padding: const EdgeInsets.only(
                      bottom: 3, left: 2),
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
                    bottomLeft:
                        Radius.circular(message.isMe ? 14 : 4),
                    bottomRight:
                        Radius.circular(message.isMe ? 4 : 14),
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
                padding: const EdgeInsets.only(
                    top: 3, left: 2, right: 2),
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
          border: Border.all(
              color: Colors.white.withOpacity(0.08)),
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