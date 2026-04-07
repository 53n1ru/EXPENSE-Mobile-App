import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class GroupService {
  static final _db = FirebaseFirestore.instance;

  // ── Create group ───────────────────────────────────────
  static Future<String?> createGroup({required String name}) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) return null;

      final doc = await _db.collection('groups').add({
        'name': name,
        'members': [userId],
        'createdBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return doc.id;
    } catch (e) {
      return null;
    }
  }

  // ── Get user groups ────────────────────────────────────
  static Stream<QuerySnapshot> getGroups() {
    final userId = AuthService.currentUserId;
    return _db
        .collection('groups')
        .where('members', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ── Send message ───────────────────────────────────────
  static Future<bool> sendMessage({
    required String groupId,
    required String text,
    String type = 'text',
    Map<String, dynamic>? expenseData,
  }) async {
    try {
      final user = AuthService.currentUser;
      if (user == null) return false;

      await _db
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .add({
        'senderId': user.uid,
        'senderName': user.displayName ?? 'Unknown',
        'text': text,
        'type': type,
        'expenseData': expenseData,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Get messages stream ────────────────────────────────
  static Stream<QuerySnapshot> getMessages(String groupId) {
    return _db
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots();
  }
}