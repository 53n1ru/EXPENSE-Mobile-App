import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class ExpenseService {
  static final _db = FirebaseFirestore.instance;

  // ── Add expense ────────────────────────────────────────
  static Future<bool> addExpense({
    required String accountId,
    required double amount,
    required String type,        // 'expense' or 'income'
    required String category,
    required String payerName,
    required DateTime date,
    String note = '',
    String otherCategory = '',
  }) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) return false;

      await _db.collection('expenses').add({
        'userId': userId,
        'accountId': accountId,
        'amount': amount,
        'type': type,
        'category': category == 'Other' ? otherCategory : category,
        'payerName': payerName,
        'note': note,
        'date': Timestamp.fromDate(date),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Get all expenses for current user ──────────────────
  static Stream<QuerySnapshot> getExpenses() {
    final userId = AuthService.currentUserId;
    return _db
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // ── Get expenses by account ────────────────────────────
  static Stream<QuerySnapshot> getExpensesByAccount(String accountId) {
    return _db
        .collection('expenses')
        .where('accountId', isEqualTo: accountId)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // ── Get expenses for current month ────────────────────
  static Stream<QuerySnapshot> getMonthlyExpenses() {
    final userId = AuthService.currentUserId;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return _db
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .orderBy('date', descending: true)
        .snapshots();
  }

  // ── Delete expense ─────────────────────────────────────
  static Future<bool> deleteExpense(String expenseId) async {
    try {
      await _db.collection('expenses').doc(expenseId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Calculate totals ───────────────────────────────────
  static Map<String, double> calculateTotals(List<QueryDocumentSnapshot> docs) {
    double totalExpense = 0;
    double totalIncome = 0;

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = (data['amount'] as num).toDouble();
      if (data['type'] == 'expense') {
        totalExpense += amount;
      } else {
        totalIncome += amount;
      }
    }

    return {
      'expense': totalExpense,
      'income': totalIncome,
      'balance': totalIncome - totalExpense,
    };
  }
}