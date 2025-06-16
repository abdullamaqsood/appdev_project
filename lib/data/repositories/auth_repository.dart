import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Future<User?> logInWithEmail(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;

    // Removed Firestore user record creation from here

    return user;
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    // Add Firestore user record manually after signup
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': email,
        'role': 'normal',
      });
    }
    return user;
  }

  Future<User?> logInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCred = await _firebaseAuth.signInWithCredential(credential);
    final user = userCred.user;
    if (user != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();
      if (!docSnapshot.exists) {
        await userDoc.set({
          'email': user.email,
          'role': 'normal',
        });
      }
    }
    return user;
  }

  Future<void> logOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  Stream<User?> get user => _firebaseAuth.authStateChanges();

  /// Fetch all users (for admin)
  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['uid'] = doc.id;
      return data;
    }).toList();
  }

  /// Delete a user and all their details (for admin)
  Future<void> deleteUserAndDetails(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final expenses = await userRef.collection('expenses').get();
    for (final doc in expenses.docs) {
      await doc.reference.delete();
    }
    final incomes = await userRef.collection('income').get();
    for (final doc in incomes.docs) {
      await doc.reference.delete();
    }
    final budgets = await userRef.collection('budgets').get();
    for (final doc in budgets.docs) {
      await doc.reference.delete();
    }
    final debts = await userRef.collection('debts').get();
    for (final doc in debts.docs) {
      await doc.reference.delete();
    }
    await userRef.delete();
  }
}
