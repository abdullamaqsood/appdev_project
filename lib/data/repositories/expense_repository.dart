import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add or update an expense
  Future<void> addExpense(ExpenseModel expense) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .doc(expense.id)
        .set(expense.toMap());
  }

  /// Fetch all expenses (sorted by date desc)
  Future<List<ExpenseModel>> fetchUserExpenses() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ExpenseModel.fromMap(doc.data()))
        .toList();
  }

  /// Fetch expenses filtered by a specific month (for reports)
  Future<List<ExpenseModel>> fetchUserExpensesByMonth(DateTime month) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThan: end.toIso8601String())
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ExpenseModel.fromMap(doc.data()))
        .toList();
  }

  /// Delete a specific expense
  Future<void> deleteExpense(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .doc(id)
        .delete();
  }
}
