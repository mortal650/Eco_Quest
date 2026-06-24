import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/quiz_model.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
});

class QuizRepository {
  const QuizRepository(this._firestore, this._auth);
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  Future<void> saveResult(QuizResult result) async {
    if (_uid == null) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('quiz_results')
        .add(result.toJson());
  }
}
