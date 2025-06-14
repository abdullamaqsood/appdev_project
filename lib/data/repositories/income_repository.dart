import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/income_model.dart';

class IncomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addIncome(IncomeModel income) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('income')
        .doc(income.id)
        .set(income.toMap());
  }

  Future<List<IncomeModel>> fetchUserIncome() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('income')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => IncomeModel.fromMap(doc.data())).toList();
  }

  Future<List<IncomeModel>> fetchUserIncomeByMonth(DateTime month) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('income')
        .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('date', isLessThan: end.toIso8601String())
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => IncomeModel.fromMap(doc.data())).toList();
  }

  Future<void> deleteIncome(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('income')
        .doc(id)
        .delete();
  }
}
