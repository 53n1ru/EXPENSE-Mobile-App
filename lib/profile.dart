import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'services/auth_service.dart';
import 'services/account_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  String _activeFilter = 'All';
  bool _editMode = false;
  bool _isLoading = true;
  bool _isSaving = false;

  // Profile data — loaded from Firebase
  String _name = '';
  String _email = '';
  String _avatarUrl = '';
  File? _avatarFile;
  late TextEditingController _nameEditController;

  // Accounts — loaded from Firestore
  List<Map<String, dynamic>> _accounts = [];
  bool _accountsLoading = true;

  late AnimationController _orbController;
  late AnimationController _fadeController;
  late AnimationController _editPanelController;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _editPanelAnim;

  static const _indigo = Color(0xFF6366F1);
  static const _violet = Color(0xFF8B5CF6);
  static const _purple = Color(0xFFA855F7);
  static const _bg = Color(0xFF0F1117);

  final List<String> _filters = [
    'All', 'Solo', 'Family', 'Group', 'Business'
  ];

  List<Map<String, dynamic>> get _filtered =>
      _activeFilter == 'All'
          ? _accounts
          : _accounts
              .where((a) => a['type'] == _activeFilter)
              .toList();

  String get _initials {
    final parts = _name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty && parts[0].isNotEmpty
        ? parts[0][0].toUpperCase()
        : '?';
  }

  @override
  void initState() {
    super.initState();
    _nameEditController = TextEditingController();

    _orbController = AnimationController(
      vsync: this, duration: const Duration(seconds: 7),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700),
    )..forward();

    _editPanelController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 350),
    );

    _fadeAnim = CurvedAnimation(
        parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<double>(begin: 16, end: 0).animate(
      CurvedAnimation(
          parent: _fadeController, curve: Curves.easeOut),
    );
    _editPanelAnim = CurvedAnimation(
      parent: _editPanelController,
      curve: Curves.easeOutCubic,
    );

    _loadProfile();
    _loadAccounts();
  }

  @override
  void dispose() {
    _orbController.dispose();
    _fadeController.dispose();
    _editPanelController.dispose();
    _nameEditController.dispose();
    super.dispose();
  }

  // ── Load profile from Firebase ─────────────────────────
  Future<void> _loadProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _name = data['name'] as String? ?? user.displayName ?? '';
          _email = data['email'] as String? ?? user.email ?? '';
          _avatarUrl = data['avatarUrl'] as String? ?? '';
          _isLoading = false;
        });
        _nameEditController.text = _name;
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Load accounts from Firestore ───────────────────────
  Future<void> _loadAccounts() async {
    try {
      final snapshot =
          await AccountService.getAccounts().first;
      final accounts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'type': data['type'] ?? 'Solo',
          'color': _colorFromHex(
              data['color'] as String? ?? '0xFF6366F1'),
          'icon': _iconFromType(data['type'] as String? ?? 'Solo'),
          'active': true,
        };
      }).toList();

      if (mounted) {
        setState(() {
          _accounts = accounts;
          _accountsLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading accounts: $e');
      if (mounted) setState(() => _accountsLoading = false);
    }
  }

  Color _colorFromHex(String hex) {
    try {
      return Color(int.parse(hex));
    } catch (_) {
      return const Color(0xFF6366F1);
    }
  }

  IconData _iconFromType(String type) {
    switch (type) {
      case 'Family':
        return Icons.family_restroom_rounded;
      case 'Group':
        return Icons.group_outlined;
      case 'Business':
        return Icons.business_center_outlined;
      default:
        return Icons.person_outline_rounded;
    }
  }

  // ── Edit panel ─────────────────────────────────────────
  void _openEditPanel() {
    _nameEditController.text = _name;
    setState(() => _editMode = true);
    _editPanelController.forward();
  }

  void _closeEditPanel() {
    _editPanelController.reverse().then((_) {
      if (mounted) setState(() => _editMode = false);
    });
  }

  // ── Pick image ─────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 512,
      );
      if (picked != null && mounted) {
        setState(() => _avatarFile = File(picked.path));
      }
    } catch (e) {
      _showSnack('Could not open camera/gallery', isError: true);
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1D27),
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('CHOOSE PHOTO',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 9,
                  letterSpacing: 2,
                  color: _indigo.withOpacity(0.6),
                )),
            const SizedBox(height: 16),
            _SheetOption(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
            _SheetOption(
              icon: Icons.camera_alt_outlined,
              label: 'Take a Photo',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_avatarFile != null || _avatarUrl.isNotEmpty) ...[
              const SizedBox(height: 10),
              _SheetOption(
                icon: Icons.delete_outline_rounded,
                label: 'Remove Photo',
                isDestructive: true,
                onTap: () {
                  setState(() {
                    _avatarFile = null;
                    _avatarUrl = '';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Save profile to Firebase ───────────────────────────
  Future<void> _saveProfile() async {
    final newName = _nameEditController.text.trim();
    if (newName.isEmpty) {
      _showSnack('Name cannot be empty', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String? uploadedUrl;

      // Upload image to Firebase Storage if new image selected
      if (_avatarFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('avatars/${user.uid}.jpg');
        await ref.putFile(_avatarFile!);
        uploadedUrl = await ref.getDownloadURL();
      }

      // Update Firestore
      final updateData = <String, dynamic>{'name': newName};
      if (uploadedUrl != null) {
        updateData['avatarUrl'] = uploadedUrl;
      }
      if (_avatarUrl.isEmpty && _avatarFile == null) {
        updateData['avatarUrl'] = '';
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updateData);

      // Update Firebase Auth display name
      await user.updateDisplayName(newName);

      if (mounted) {
        setState(() {
          _name = newName;
          if (uploadedUrl != null) _avatarUrl = uploadedUrl;
          _isSaving = false;
        });
        _closeEditPanel();
        _showSnack('Profile updated successfully',
            isError: false);
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnack('Failed to save profile', isError: true);
      }
    }
  }

  // ── Sign out ───────────────────────────────────────────
  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D27),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF8FAFC),
            )),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 13,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: Colors.white.withOpacity(0.4),
                )),
          ),
          GestureDetector(
            onTap: () async {
              Navigator.pop(ctx);
              await AuthService.logout();
              // AuthWrapper will redirect to LoginPage
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE24B4A).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color:
                        const Color(0xFFE24B4A).withOpacity(0.4)),
              ),
              child: const Text('Sign Out',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF09595),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(fontFamily: 'Outfit')),
      backgroundColor: isError
          ? const Color(0xFF6366F1).withOpacity(0.9)
          : const Color(0xFF1D9E75),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Orbs ──────────────────────────────────────
          AnimatedBuilder(
            animation: _orbController,
            builder: (_, __) {
              final t = _orbController.value;
              final w = MediaQuery.of(context).size.width;
              final h = MediaQuery.of(context).size.height;
              return Stack(children: [
                _Orb(
                    x: -70 + 30 * t,
                    y: -90 + 40 * t,
                    size: 300,
                    color: _indigo.withOpacity(0.24)),
                _Orb(
                    x: w - 160 - 20 * t,
                    y: h - 260 + 26 * t,
                    size: 220,
                    color: _purple.withOpacity(0.14)),
              ]);
            },
          ),

          CustomPaint(
              size: Size.infinite, painter: _GridPainter()),

          // ── Main Content ───────────────────────────────
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
                    padding: const EdgeInsets.fromLTRB(
                        20, 12, 20, 0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: _editMode
                                ? _closeEditPanel
                                : () => Navigator.pop(context),
                            child: Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(0.05),
                                borderRadius:
                                    BorderRadius.circular(11),
                                border: Border.all(
                                    color: Colors.white
                                        .withOpacity(0.08)),
                              ),
                              child: const Icon(
                                  Icons.chevron_left_rounded,
                                  color: Colors.white54,
                                  size: 20),
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
                                    color:
                                        _indigo.withOpacity(0.6),
                                  )),
                              AnimatedSwitcher(
                                duration: const Duration(
                                    milliseconds: 200),
                                child: Text(
                                  _editMode
                                      ? 'Edit Profile'
                                      : 'Profile',
                                  key: ValueKey(_editMode),
                                  style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                    color: Color(0xFFF8FAFC),
                                  ),
                                ),
                              ),
                            ]),
                      ],
                    ),
                  ),

                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: _indigo.withOpacity(0.7),
                              strokeWidth: 2,
                            ),
                          )
                        : Stack(
                            children: [
                              // ── Profile view ───────────
                              SingleChildScrollView(
                                padding:
                                    const EdgeInsets.fromLTRB(
                                        20, 0, 20, 24),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // Avatar row
                                    Padding(
                                      padding: const EdgeInsets
                                          .symmetric(
                                          vertical: 20),
                                      child: Row(
                                        children: [
                                          _AvatarWidget(
                                            avatarFile:
                                                _avatarFile,
                                            avatarUrl:
                                                _avatarUrl,
                                            initials:
                                                _initials,
                                          ),
                                          const SizedBox(
                                              width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                Text(
                                                  _name.isEmpty
                                                      ? 'Loading...'
                                                      : _name,
                                                  style: const TextStyle(
                                                    fontFamily:
                                                        'Outfit',
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight
                                                            .w600,
                                                    color: Color(
                                                        0xFFF8FAFC),
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height: 2),
                                                Text(
                                                  _email,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Outfit',
                                                    fontSize: 12,
                                                    color: Colors
                                                        .white
                                                        .withOpacity(
                                                            0.38),
                                                  ),
                                                  overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Edit Profile button
                                    GestureDetector(
                                      onTap: _openEditPanel,
                                      child: Container(
                                        width: double.infinity,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withOpacity(0.04),
                                          borderRadius:
                                              BorderRadius.circular(
                                                  12),
                                          border: Border.all(
                                              color: Colors.white
                                                  .withOpacity(
                                                      0.09)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
                                          children: [
                                            Icon(
                                                Icons
                                                    .edit_outlined,
                                                size: 15,
                                                color: Colors.white
                                                    .withOpacity(
                                                        0.5)),
                                            const SizedBox(
                                                width: 6),
                                            Text(
                                              'Edit Profile',
                                              style: TextStyle(
                                                fontFamily:
                                                    'Outfit',
                                                fontSize: 13,
                                                fontWeight:
                                                    FontWeight.w500,
                                                color: Colors.white
                                                    .withOpacity(
                                                        0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Sign Out button
                                    GestureDetector(
                                      onTap: _signOut,
                                      child: Container(
                                        width: double.infinity,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: const Color(
                                                  0xFFE24B4A)
                                              .withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(
                                                  12),
                                          border: Border.all(
                                              color: const Color(
                                                      0xFFE24B4A)
                                                  .withOpacity(
                                                      0.25)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
                                          children: [
                                            Icon(
                                                Icons
                                                    .logout_rounded,
                                                size: 15,
                                                color: const Color(
                                                        0xFFF09595)
                                                    .withOpacity(
                                                        0.8)),
                                            const SizedBox(
                                                width: 6),
                                            Text(
                                              'Sign Out',
                                              style: TextStyle(
                                                fontFamily:
                                                    'Outfit',
                                                fontSize: 13,
                                                fontWeight:
                                                    FontWeight.w500,
                                                color: const Color(
                                                        0xFFF09595)
                                                    .withOpacity(
                                                        0.8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    Text(
                                      'MANAGE ACCOUNTS',
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 10,
                                        letterSpacing: 1.0,
                                        color: Colors.white
                                            .withOpacity(0.3),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Filter chips
                                    SingleChildScrollView(
                                      scrollDirection:
                                          Axis.horizontal,
                                      child: Row(
                                        children: _filters
                                            .map((f) {
                                          final active =
                                              _activeFilter == f;
                                          return Padding(
                                            padding:
                                                const EdgeInsets
                                                    .only(
                                                    right: 8),
                                            child:
                                                GestureDetector(
                                              onTap: () =>
                                                  setState(() =>
                                                      _activeFilter =
                                                          f),
                                              child:
                                                  AnimatedContainer(
                                                duration:
                                                    const Duration(
                                                        milliseconds:
                                                            200),
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 14,
                                                    vertical: 6),
                                                decoration:
                                                    BoxDecoration(
                                                  color: active
                                                      ? _indigo
                                                          .withOpacity(
                                                              0.18)
                                                      : Colors.white
                                                          .withOpacity(
                                                              0.04),
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                              20),
                                                  border:
                                                      Border.all(
                                                    color: active
                                                        ? _indigo
                                                            .withOpacity(
                                                                0.45)
                                                        : Colors
                                                            .white
                                                            .withOpacity(
                                                                0.08),
                                                  ),
                                                ),
                                                child: Text(f,
                                                    style:
                                                        TextStyle(
                                                      fontFamily:
                                                          'Outfit',
                                                      fontSize: 12,
                                                      color: active
                                                          ? const Color(
                                                              0xFF818CF8)
                                                          : Colors
                                                              .white
                                                              .withOpacity(
                                                                  0.4),
                                                    )),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    // Account cards
                                    _accountsLoading
                                        ? Center(
                                            child:
                                                CircularProgressIndicator(
                                              color: _indigo
                                                  .withOpacity(
                                                      0.6),
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : _filtered.isEmpty
                                            ? _EmptyAccounts()
                                            : Column(
                                                children: _filtered
                                                    .map((acc) =>
                                                        _AccountCard(
                                                          account:
                                                              acc,
                                                          onTap:
                                                              () {},
                                                        ))
                                                    .toList(),
                                              ),

                                    const SizedBox(height: 8),

                                    // Create button
                                    _GradientButton(
                                      label:
                                          'Create New Account / Group',
                                      icon: Icons.add_rounded,
                                      colors: [
                                        _indigo,
                                        _violet,
                                        _purple,
                                      ],
                                      onTap: () {
                                        // 👉 Navigate to create account page
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // ── Edit Panel overlay ──────
                              if (_editMode)
                                AnimatedBuilder(
                                  animation: _editPanelAnim,
                                  builder: (_, child) {
                                    return Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: _closeEditPanel,
                                          child: Container(
                                            color: Colors.black
                                                .withOpacity(0.5 *
                                                    _editPanelAnim
                                                        .value),
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          child:
                                              Transform.translate(
                                            offset: Offset(
                                              0,
                                              60 *
                                                  (1 -
                                                      _editPanelAnim
                                                          .value),
                                            ),
                                            child: Opacity(
                                              opacity:
                                                  _editPanelAnim
                                                      .value,
                                              child: child,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                  child: _EditPanel(
                                    avatarFile: _avatarFile,
                                    avatarUrl: _avatarUrl,
                                    initials: _initials,
                                    nameController:
                                        _nameEditController,
                                    isSaving: _isSaving,
                                    onPickImage:
                                        _showImageSourceSheet,
                                    onSave: _saveProfile,
                                    onCancel: _closeEditPanel,
                                  ),
                                ),
                            ],
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

// ── Edit Panel ─────────────────────────────────────────────────────────────

class _EditPanel extends StatelessWidget {
  final File? avatarFile;
  final String avatarUrl;
  final String initials;
  final TextEditingController nameController;
  final bool isSaving;
  final VoidCallback onPickImage;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _EditPanel({
    required this.avatarFile,
    required this.avatarUrl,
    required this.initials,
    required this.nameController,
    required this.isSaving,
    required this.onPickImage,
    required this.onSave,
    required this.onCancel,
  });

  static const _indigo = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13151F),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
            top: BorderSide(
                color: Colors.white.withOpacity(0.08))),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24,
          MediaQuery.of(context).viewInsets.bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Avatar picker
          GestureDetector(
            onTap: onPickImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                _AvatarWidget(
                  avatarFile: avatarFile,
                  avatarUrl: avatarUrl,
                  initials: initials,
                  size: 80,
                ),
                Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                    color: _indigo,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFF13151F), width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      size: 13, color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),
          Text('Tap to change photo',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 11,
                color: Colors.white.withOpacity(0.3),
              )),

          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerLeft,
            child: Text('FULL NAME',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 10,
                  letterSpacing: 0.9,
                  color: Colors.white.withOpacity(0.32),
                )),
          ),
          const SizedBox(height: 6),

          TextField(
            controller: nameController,
            autofocus: true,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              color: Color(0xFFF8FAFC),
            ),
            decoration: InputDecoration(
              hintText: 'Your full name',
              hintStyle: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                color: Colors.white.withOpacity(0.25),
              ),
              prefixIcon: Icon(Icons.person_outline_rounded,
                  size: 17,
                  color: Colors.white.withOpacity(0.28)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.04),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 13),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.09),
                    width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFF6366F1), width: 1.2),
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              Colors.white.withOpacity(0.09)),
                    ),
                    child: Center(
                      child: Text('Cancel',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color:
                                Colors.white.withOpacity(0.5),
                          )),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: isSaving ? null : onSave,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6366F1),
                          Color(0xFF8B5CF6)
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _indigo.withOpacity(0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: isSaving
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2))
                          : const Text('Save Changes',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Avatar Widget ──────────────────────────────────────────────────────────

class _AvatarWidget extends StatelessWidget {
  final File? avatarFile;
  final String avatarUrl;
  final String initials;
  final double size;

  const _AvatarWidget({
    required this.avatarFile,
    required this.avatarUrl,
    required this.initials,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (avatarFile != null) {
      imageProvider = FileImage(avatarFile!);
    } else if (avatarUrl.isNotEmpty) {
      imageProvider = NetworkImage(avatarUrl);
    }

    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: imageProvider == null
            ? const LinearGradient(
                colors: [
                  Color(0xFF3730A3),
                  Color(0xFF6D28D9)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.4),
          width: 2,
        ),
        image: imageProvider != null
            ? DecorationImage(
                image: imageProvider, fit: BoxFit.cover)
            : null,
      ),
      child: imageProvider == null
          ? Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE0E7FF),
                ),
              ),
            )
          : null,
    );
  }
}

// ── Empty Accounts ─────────────────────────────────────────────────────────

class _EmptyAccounts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF6366F1).withOpacity(0.15)),
      ),
      child: Column(children: [
        Icon(Icons.account_balance_wallet_outlined,
            size: 28,
            color:
                const Color(0xFF818CF8).withOpacity(0.4)),
        const SizedBox(height: 8),
        Text('No accounts yet',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 13,
              color: Colors.white.withOpacity(0.35),
            )),
        const SizedBox(height: 4),
        Text('Tap the button below to create one',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 11,
              color:
                  const Color(0xFF818CF8).withOpacity(0.5),
            )),
      ]),
    );
  }
}

// ── Sheet Option ───────────────────────────────────────────────────────────

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? const Color(0xFFE24B4A)
        : const Color(0xFFF8FAFC);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDestructive
              ? const Color(0xFFE24B4A).withOpacity(0.08)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive
                ? const Color(0xFFE24B4A).withOpacity(0.25)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18, color: color.withOpacity(0.7)),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color.withOpacity(0.85),
                )),
          ],
        ),
      ),
    );
  }
}

// ── Account Card ───────────────────────────────────────────────────────────

class _AccountCard extends StatelessWidget {
  final Map<String, dynamic> account;
  final VoidCallback onTap;
  const _AccountCard(
      {required this.account, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color color = account['color'] as Color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: color.withOpacity(0.25)),
              ),
              child: Icon(account['icon'] as IconData,
                  size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(account['name'] as String,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF8FAFC),
                      )),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14B8A6)
                            .withOpacity(0.12),
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFF14B8A6)
                                .withOpacity(0.25)),
                      ),
                      child: Row(children: [
                        Container(
                          width: 5, height: 5,
                          decoration: const BoxDecoration(
                            color: Color(0xFF14B8A6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('Active',
                            style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 10,
                                color: Color(0xFF14B8A6))),
                      ]),
                    ),
                    const SizedBox(width: 6),
                    Text(account['type'] as String,
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 10,
                            color: Colors.white
                                .withOpacity(0.28))),
                  ]),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18,
                color: Colors.white.withOpacity(0.22)),
          ],
        ),
      ),
    );
  }
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
      (Icons.bar_chart_outlined,
          Icons.bar_chart_rounded, 'Analytics'),
      (Icons.person_outline_rounded,
          Icons.person_rounded, 'Profile'),
    ];
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.025),
        border: Border(
            top: BorderSide(
                color: Colors.white.withOpacity(0.07))),
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
                Text(items[i].$3,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 10,
                      color: active
                          ? const Color(0xFF818CF8)
                          : Colors.white.withOpacity(0.28),
                    )),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Gradient Button ────────────────────────────────────────────────────────

class _GradientButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.colors,
    required this.onTap,
  });
  @override
  State<_GradientButton> createState() =>
      _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity, height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: widget.colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    widget.colors.first.withOpacity(0.28),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon,
                  size: 18,
                  color: Colors.white.withOpacity(0.8)),
              const SizedBox(width: 8),
              Text(widget.label.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: Colors.white,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared Helpers ─────────────────────────────────────────────────────────

class _Orb extends StatelessWidget {
  final double x, y, size;
  final Color color;
  const _Orb({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x, top: y,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
              colors: [color, Colors.transparent]),
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