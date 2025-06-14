import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/debt_model.dart';

class DebtRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> addDebt(DebtModel debt) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('debts')
        .doc(debt.id)
        .set(debt.toMap());
  }

  Future<List<DebtModel>> fetchDebts() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('debts')
        .orderBy('givenDate', descending: true)
        .get();

    return snap.docs.map((doc) => DebtModel.fromMap(doc.data())).toList();
  }

  Future<void> deleteDebt(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('debts')
        .doc(id)
        .delete();
  }

  Future<void> updateDebt(DebtModel debt) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('debts')
        .doc(debt.id)
        .update(debt.toMap());
  }
}
