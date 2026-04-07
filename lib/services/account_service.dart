import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class AccountService {
  static final _db = FirebaseFirestore.instance;

  // ── Create account ─────────────────────────────────────
  static Future<bool> createAccount({
    required String name,
    required String type,
    required String colorHex,
  }) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) return false;

      await _db.collection('accounts').add({
        'userId': userId,
        'name': name,
        'type': type,
        'color': colorHex,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Get user accounts ──────────────────────────────────
  static Stream<QuerySnapshot> getAccounts() {
    final userId = AuthService.currentUserId;
    return _db
        .collection('accounts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt')
        .snapshots();
  }

  // ── Delete account ─────────────────────────────────────
  static Future<bool> deleteAccount(String accountId) async {
    try {
      await _db.collection('accounts').doc(accountId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}