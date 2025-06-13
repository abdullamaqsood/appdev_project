import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
