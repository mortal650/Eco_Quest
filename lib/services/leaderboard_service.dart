import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final leaderboardServiceProvider = Provider<LeaderboardService>((ref) {
  return LeaderboardService(FirebaseFirestore.instance, FirebaseAuth.instance);
});

class LeaderboardEntry {
  final String uid;
  final String displayName;
  final int xp;
  final int level;
  final int completedModules;
  final double averageQuizScore;

  LeaderboardEntry({
    required this.uid,
    required this.displayName,
    required this.xp,
    required this.level,
    required this.completedModules,
    required this.averageQuizScore,
  });
}

class LeaderboardService {
  const LeaderboardService(this._firestore, this._auth);
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');

  LeaderboardEntry _entryFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return LeaderboardEntry(
      uid: doc.id,
      displayName: (data['displayName'] as String?) ?? 'Student',
      xp: (data['xp'] as num?)?.toInt() ?? 0,
      level: (data['level'] as num?)?.toInt() ?? 1,
      completedModules: (data['completedLessons'] is Map)
          ? (data['completedLessons'] as Map).length
          : 0,
      averageQuizScore: (data['averageQuizScore'] as num?)?.toDouble() ?? 0,
    );
  }

  Future<List<LeaderboardEntry>> getGlobalLeaderboard({int limit = 50}) async {
    try {
      final snap = await _usersCol
          .where('role', isEqualTo: 'student')
          .orderBy('xp', descending: true)
          .limit(limit)
          .get();

      return snap.docs.map(_entryFromDoc).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        throw const LeaderboardException(
          'Leaderboard index is building. Please try again in a few minutes.',
        );
      }
      throw LeaderboardException('Could not load leaderboard: ${e.message}');
    } catch (e) {
      throw LeaderboardException('Could not load leaderboard: $e');
    }
  }

  Future<List<LeaderboardEntry>> getClassroomLeaderboard(
    String classroomId, {
    int limit = 50,
  }) async {
    try {
      final membersSnap = await _firestore
          .collection('classroom_members')
          .where('classroomId', isEqualTo: classroomId)
          .get();

      if (membersSnap.docs.isEmpty) return [];

      final studentIds = membersSnap.docs
          .map((d) => (d.data()['studentId'] as String?))
          .where((id) => id != null && id.isNotEmpty)
          .toList();

      if (studentIds.isEmpty) return [];

      final entries = <LeaderboardEntry>[];
      for (final sid in studentIds) {
        final userSnap = await _usersCol.doc(sid).get();
        if (!userSnap.exists || userSnap.data() == null) continue;
        entries.add(_entryFromDoc(userSnap));
      }

      entries.sort((a, b) => b.xp.compareTo(a.xp));
      return entries.take(limit).toList();
    } on FirebaseException catch (e) {
      throw LeaderboardException(
        'Could not load classroom leaderboard: ${e.message}',
      );
    } catch (e) {
      throw LeaderboardException('Could not load classroom leaderboard: $e');
    }
  }

  Future<int> getCurrentUserRank() async {
    if (_uid == null) return 0;
    try {
      final userSnap = await _usersCol.doc(_uid).get();
      final myXp = (userSnap.data()?['xp'] as num?)?.toInt() ?? 0;

      final higherCount = await _usersCol
          .where('role', isEqualTo: 'student')
          .where('xp', isGreaterThan: myXp)
          .count()
          .get();

      return (higherCount.count ?? 0) + 1;
    } catch (e) {
      return 0;
    }
  }
}

class LeaderboardException implements Exception {
  final String message;
  const LeaderboardException(this.message);

  @override
  String toString() => message;
}
