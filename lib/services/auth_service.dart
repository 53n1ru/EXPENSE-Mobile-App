import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_service.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  // Current logged in user
  static User? get currentUser => _auth.currentUser;
  static String? get currentUserId => _auth.currentUser?.uid;

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Add this method inside AuthService class
static Future<void> sendPasswordReset({required String email}) async {
  await _auth.sendPasswordResetEmail(email: email);
}

  // ── Register ───────────────────────────────────────────
  static Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String profileType,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);

      // Save user data to Firestore
      await UserService.createUser(
        userId: credential.user!.uid,
        name: name,
        email: email,
        profileType: profileType,
      );

      return null; // null = success
    } on FirebaseAuthException catch (e) {
      return _authError(e.code);
    }
  }

  // ── Login ──────────────────────────────────────────────
  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // null = success
    } on FirebaseAuthException catch (e) {
      return _authError(e.code);
    }
  }

  // ── Logout ─────────────────────────────────────────────
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // ── Error messages ─────────────────────────────────────
  static String _authError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found for this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'email-already-in-use':
        return 'Account already exists for this email';
      case 'weak-password':
        return 'Password must be at least 6 characters';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      default:
        return 'Something went wrong. Try again';
    }
  }
}