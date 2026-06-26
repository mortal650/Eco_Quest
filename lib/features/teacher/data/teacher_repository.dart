import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/challenge_model.dart';

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  return TeacherRepository(FirebaseFirestore.instance, FirebaseAuth.instance);
});

class TeacherRepository {
  const TeacherRepository(this._firestore, this._auth);
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static const _uuid = Uuid();

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _quizzesCol =>
      _firestore.collection('quizzes');

  CollectionReference<Map<String, dynamic>> get _challengesCol =>
      _firestore.collection('challenges');

  Future<void> createQuiz({
    required String title,
    required String classroomId,
    required List<Map<String, dynamic>> questions,
  }) async {
    await _quizzesCol.doc().set({
      'quizId': _uuid.v4(),
      'title': title,
      'classroomId': classroomId,
      'createdBy': _uid,
      'questions': questions,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Map<String, dynamic>>> watchQuizzes(String classroomId) {
    return _quizzesCol
        .where('classroomId', isEqualTo: classroomId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  Future<void> createChallenge({
    required String title,
    required String description,
    required String type,
    required int xpReward,
    required DateTime dueDate,
    required String classroomId,
  }) async {
    final challenge = EcoChallenge(
      challengeId: _uuid.v4(),
      title: title,
      description: description,
      type: type,
      xpReward: xpReward,
      dueDate: dueDate,
      createdBy: _uid!,
      classroomId: classroomId,
      completions: 0,
      createdAt: DateTime.now(),
    );

    await _challengesCol.doc(challenge.challengeId).set(challenge.toJson());
  }

  Stream<List<EcoChallenge>> watchChallenges(String classroomId) {
    return _challengesCol
        .where('classroomId', isEqualTo: classroomId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => EcoChallenge.fromJson(doc.data()))
            .toList());
  }

  Future<Map<String, dynamic>> getStudentAnalytics(String classroomId) async {
    final membersSnap = await _firestore
        .collection('classroom_members')
        .where('classroomId', isEqualTo: classroomId)
        .get();

    final totalStudents = membersSnap.docs.length;

    int totalQuizzes = 0;
    double totalScore = 0;
    int quizAttempts = 0;

    for (final member in membersSnap.docs) {
      final studentId = member.data()['studentId'];
      final resultsSnap = await _firestore
          .collection('quiz_results')
          .where('classroomId', isEqualTo: classroomId)
          .where('userId', isEqualTo: studentId)
          .get();
      for (final result in resultsSnap.docs) {
        totalQuizzes++;
        final score = result.data()['score'] ?? 0;
        final total = result.data()['totalQuestions'] ?? 1;
        totalScore += (score / total) * 100;
        quizAttempts++;
      }
    }

    final challengesSnap = await _challengesCol
        .where('classroomId', isEqualTo: classroomId)
        .get();

    return {
      'totalStudents': totalStudents,
      'totalQuizzes': totalQuizzes,
      'averageScore': quizAttempts > 0 ? (totalScore / quizAttempts).round() : 0,
      'activeChallenges': challengesSnap.docs.length,
    };
  }
}
