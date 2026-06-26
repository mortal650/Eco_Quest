import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'domain/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserRoleProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  final snap = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();
  return snap.data()?['role'] as String?;
});

class AuthRepository {
  const AuthRepository(this._auth, this._firestore);
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user!.updateDisplayName(displayName);

    final now = DateTime.now();
    final userDoc = EcoUser(
      uid: credential.user!.uid,
      displayName: displayName,
      email: email,
      role: role,
      createdAt: now,
      lastLogin: now,
    );

    await _usersCol.doc(credential.user!.uid).set(userDoc.toJson());
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _usersCol.doc(_auth.currentUser!.uid).update({
      'lastLogin': DateTime.now().toIso8601String(),
    });
  }

  Future<String?> getUserRole() async {
    if (_auth.currentUser == null) return null;
    final snap = await _usersCol.doc(_auth.currentUser!.uid).get();
    return snap.data()?['role'] as String?;
  }

  Future<void> updateUserProfile({
    required String field,
    required dynamic value,
  }) async {
    if (_auth.currentUser == null) return;
    await _usersCol.doc(_auth.currentUser!.uid).update({field: value});
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final uid = user.uid;

    // Delete subcollections first (quiz_results)
    final quizResults = await _firestore
        .collection('users')
        .doc(uid)
        .collection('quiz_results')
        .get();
    for (final doc in quizResults.docs) {
      await doc.reference.delete();
    }

    // Delete main user document
    await _firestore.collection('users').doc(uid).delete();

    // Delete Firebase Auth account
    await user.delete();
  }
}
