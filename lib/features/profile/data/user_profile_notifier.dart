import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/user_model.dart';
import '../../quiz/domain/quiz_model.dart';
import '../../../services/gamification_service.dart';

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, EcoUser?>(UserProfileNotifier.new);

class UserProfileNotifier extends AsyncNotifier<EcoUser?> {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _userDoc =>
      _uid != null ? _firestore.collection('users').doc(_uid) : null;

  @override
  Future<EcoUser?> build() async {
    if (_uid == null) return null;

    try {
      final snap = await _userDoc!.get();
      if (!snap.exists || snap.data() == null) return null;

      final raw = snap.data()!;
      final needsMigration = _needsMigration(raw);

      if (needsMigration) {
        final patched = _patchOldDocument(raw);
        try {
          await _userDoc!.update(patched);
        } catch (_) {
          // Firestore write failed - still try to parse locally
        }
        return EcoUser.fromJson(patched);
      }

      return EcoUser.fromJson(raw);
    } catch (e) {
      // Everything failed - return a default user so the app never breaks
      return EcoUser(
        uid: _uid!,
        displayName: FirebaseAuth.instance.currentUser?.displayName ?? 'Explorer',
        email: FirebaseAuth.instance.currentUser?.email ?? '',
        role: 'student',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
    }
  }

  bool _needsMigration(Map<String, dynamic> data) {
    return !data.containsKey('role') ||
        !data.containsKey('totalQuizzes') ||
        !data.containsKey('totalQuizCorrect') ||
        !data.containsKey('averageQuizScore') ||
        !data.containsKey('schoolName') ||
        !data.containsKey('city') ||
        !data.containsKey('state') ||
        !data.containsKey('grade') ||
        !data.containsKey('profilePicture') ||
        !data.containsKey('institutionName') ||
        !data.containsKey('subject') ||
        !data.containsKey('experience') ||
        data['createdAt'] is! String ||
        data['lastLogin'] is! String;
  }

  Map<String, dynamic> _patchOldDocument(Map<String, dynamic> data) {
    final now = DateTime.now().toIso8601String();

    // Sanitize badges - must be List<String>
    dynamic badges = data['badges'];
    if (badges is! List) {
      badges = <String>[];
    } else {
      badges = badges.whereType<String>().toList();
    }

    // Sanitize completedLessons - must be Map<String, List<int>>
    dynamic completedLessons = data['completedLessons'];
    if (completedLessons is! Map) {
      completedLessons = <String, List<int>>{};
    } else {
      final sanitized = <String, List<int>>{};
      completedLessons.forEach((key, value) {
        if (key is String && value is List) {
          sanitized[key] = value.whereType<int>().toList();
        }
      });
      completedLessons = sanitized;
    }

    return {
      ...data,
      'uid': data['uid'] ?? _uid,
      'displayName': data['displayName'] ?? '',
      'email': data['email'] ?? '',
      'role': data['role'] ?? 'student',
      'schoolName': data['schoolName'] ?? '',
      'city': data['city'] ?? '',
      'state': data['state'] ?? '',
      'grade': data['grade'] ?? '',
      'profilePicture': data['profilePicture'] ?? '',
      'institutionName': data['institutionName'] ?? '',
      'subject': data['subject'] ?? '',
      'experience': data['experience'] ?? '',
      'xp': (data['xp'] as num?)?.toInt() ?? 0,
      'level': (data['level'] as num?)?.toInt() ?? 1,
      'streak': (data['streak'] as num?)?.toInt() ?? 0,
      'totalQuizzes': (data['totalQuizzes'] as num?)?.toInt() ?? 0,
      'totalQuizCorrect': (data['totalQuizCorrect'] as num?)?.toInt() ?? 0,
      'averageQuizScore': (data['averageQuizScore'] as num?)?.toDouble() ?? 0.0,
      'badges': badges,
      'completedLessons': completedLessons,
      'createdAt': _normalizeDateField(data['createdAt']) ?? now,
      'lastLogin': _normalizeDateField(data['lastLogin']) ?? now,
    };
  }

  String _normalizeDateField(dynamic value) {
    if (value == null) return DateTime.now().toIso8601String();
    if (value is DateTime) return value.toIso8601String();
    if (value is String) return value;
    if (value is Timestamp) return value.toDate().toIso8601String();
    return DateTime.now().toIso8601String();
  }

  Future<void> incrementStreak() async {
    if (_uid == null || state.value == null) return;

    final user = state.value!;
    final now = DateTime.now();
    final newStreak =
        GamificationService.calculateStreak(user.lastLogin, now, user.streak);

    try {
      await _userDoc!.update({
        'streak': newStreak,
        'lastLogin': now.toIso8601String(),
      });

      state = AsyncData(user.copyWith(
        streak: newStreak,
        lastLogin: now,
      ));
    } catch (e, st) {
      // Keep previous state alive - don't poison the provider
      // The UI can still render with stale data
    }
  }

  Future<void> completeLesson(String moduleId, int lessonIndex, int xpReward) async {
    if (_uid == null || state.value == null) return;

    final user = state.value!;
    final now = DateTime.now();

    final alreadyCompleted =
        user.completedLessons[moduleId]?.contains(lessonIndex) ?? false;
    if (alreadyCompleted) return;

    final updatedLessons = Map<String, List<int>>.from(user.completedLessons);
    final moduleLessons = List<int>.from(updatedLessons[moduleId] ?? []);
    moduleLessons.add(lessonIndex);
    updatedLessons[moduleId] = moduleLessons;

    final newXP = user.xp + xpReward;
    final newLevel = GamificationService.calculateLevel(newXP);

    // Update local state immediately so UI reflects the change
    state = AsyncData(user.copyWith(
      xp: newXP,
      level: newLevel,
      completedLessons: updatedLessons,
      lastLogin: now,
    ));

    try {
      final quizSnap = await _userDoc!.collection('quiz_results').get();
      final quizzesCompleted = quizSnap.docs.length;

      final newBadges = GamificationService.evaluateBadges(
        xp: newXP,
        level: newLevel,
        streak: user.streak,
        quizzesCompleted: quizzesCompleted,
        currentBadges: user.badges,
      );

      await _userDoc!.update({
        'xp': newXP,
        'level': newLevel,
        'badges': newBadges,
        'completedLessons': updatedLessons.map(
          (k, v) => MapEntry(k, v),
        ),
        'lastLogin': now.toIso8601String(),
      });

      state = AsyncData(user.copyWith(
        xp: newXP,
        level: newLevel,
        badges: newBadges,
        completedLessons: updatedLessons,
        lastLogin: now,
      ));
    } catch (e, st) {
      // Firestore write failed but local state is already updated
      // Don't poison the provider - UI stays functional
    }
  }

  Future<void> addXP(int xpAmount) async {
    if (_uid == null || state.value == null) return;

    final user = state.value!;
    final now = DateTime.now();

    final newXP = user.xp + xpAmount;
    final newLevel = GamificationService.calculateLevel(newXP);

    // Update local state immediately so UI reflects the change
    state = AsyncData(user.copyWith(
      xp: newXP,
      level: newLevel,
      lastLogin: now,
    ));

    try {
      final quizSnap = await _userDoc!.collection('quiz_results').get();
      final quizzesCompleted = quizSnap.docs.length;

      final newBadges = GamificationService.evaluateBadges(
        xp: newXP,
        level: newLevel,
        streak: user.streak,
        quizzesCompleted: quizzesCompleted,
        currentBadges: user.badges,
      );

      await _userDoc!.update({
        'xp': newXP,
        'level': newLevel,
        'badges': newBadges,
        'lastLogin': now.toIso8601String(),
      });

      state = AsyncData(user.copyWith(
        xp: newXP,
        level: newLevel,
        badges: newBadges,
        lastLogin: now,
      ));
    } catch (e, st) {
      // Firestore write failed but local state is already updated
      // Don't poison the provider - UI stays functional
    }
  }

  Future<void> applyQuizResult(QuizResult result) async {
    if (_uid == null || state.value == null) return;

    final user = state.value!;
    final now = DateTime.now();

    final newStreak =
        GamificationService.calculateStreak(user.lastLogin, now, user.streak);
    final newXP = user.xp + result.ecoPointsEarned;
    final newLevel = GamificationService.calculateLevel(newXP);

    final newTotalQuizzes = user.totalQuizzes + 1;
    final newTotalQuizCorrect = user.totalQuizCorrect + result.score;
    final newAverage = newTotalQuizzes > 0
        ? (newTotalQuizCorrect / newTotalQuizzes * 100).roundToDouble()
        : 0.0;

    // Update local state immediately so UI reflects the change
    state = AsyncData(user.copyWith(
      xp: newXP,
      level: newLevel,
      streak: newStreak,
      totalQuizzes: newTotalQuizzes,
      totalQuizCorrect: newTotalQuizCorrect,
      averageQuizScore: newAverage,
      lastLogin: now,
    ));

    try {
      final quizSnap = await _userDoc!.collection('quiz_results').get();
      final quizzesCompleted = quizSnap.docs.length;

      final newBadges = GamificationService.evaluateBadges(
        xp: newXP,
        level: newLevel,
        streak: newStreak,
        quizzesCompleted: quizzesCompleted,
        currentBadges: user.badges,
      );

      await _userDoc!.update({
        'xp': newXP,
        'level': newLevel,
        'streak': newStreak,
        'badges': newBadges,
        'totalQuizzes': newTotalQuizzes,
        'totalQuizCorrect': newTotalQuizCorrect,
        'averageQuizScore': newAverage,
        'lastLogin': now.toIso8601String(),
      });

      state = AsyncData(user.copyWith(
        xp: newXP,
        level: newLevel,
        streak: newStreak,
        badges: newBadges,
        totalQuizzes: newTotalQuizzes,
        totalQuizCorrect: newTotalQuizCorrect,
        averageQuizScore: newAverage,
        lastLogin: now,
      ));
    } catch (e, st) {
      // Firestore write failed but local state is already updated
      // Don't poison the provider - UI stays functional
    }
  }
}
