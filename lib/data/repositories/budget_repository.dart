import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> addBudget(BudgetModel budget) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .doc(budget.id)
        .set(budget.toMap());
  }

  Future<List<BudgetModel>> fetchBudgets() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs.map((doc) => BudgetModel.fromMap(doc.data())).toList();
  }

  Future<void> deleteBudget(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .doc(id)
        .delete();
  }

  Future<void> updateBudget(BudgetModel budget) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('budgets')
        .doc(budget.id)
        .update(budget.toMap());
  }
}
