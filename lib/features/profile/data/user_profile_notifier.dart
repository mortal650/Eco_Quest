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
    final snap = await _userDoc!.get();
    if (!snap.exists || snap.data() == null) return null;
    return EcoUser.fromJson(snap.data()!);
  }

  Future<void> incrementStreak() async {
    if (_uid == null || state.value == null) return;

    final user = state.value!;
    final now = DateTime.now();
    final newStreak =
        GamificationService.calculateStreak(user.lastLogin, now, user.streak);

    await _userDoc!.update({
      'streak': newStreak,
      'lastLogin': now.toIso8601String(),
    });

    state = AsyncData(user.copyWith(
      streak: newStreak,
      lastLogin: now,
    ));
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
  }

  Future<void> applyQuizResult(QuizResult result) async {
    if (_uid == null || state.value == null) return;

    final user = state.value!;
    final now = DateTime.now();

    final newStreak =
        GamificationService.calculateStreak(user.lastLogin, now, user.streak);
    final newXP = user.xp + result.ecoPointsEarned;
    final newLevel = GamificationService.calculateLevel(newXP);

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
      'lastLogin': now.toIso8601String(),
    });

    state = AsyncData(user.copyWith(
      xp: newXP,
      level: newLevel,
      streak: newStreak,
      badges: newBadges,
      lastLogin: now,
    ));
  }
}
