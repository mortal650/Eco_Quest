import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/profile/data/user_profile_notifier.dart';
import '../features/quiz/domain/quiz_model.dart';

final userProgressServiceProvider = Provider<UserProgressService>((ref) {
  return UserProgressService(ref);
});

class UserProgressService {
  const UserProgressService(this._ref);
  final Ref _ref;

  Future<void> applyQuizResult(QuizResult result) async {
    await _ref.read(userProfileProvider.notifier).applyQuizResult(result);
  }

  Future<void> updateStreakOnLogin() async {
    await _ref.read(userProfileProvider.notifier).incrementStreak();
  }
}
