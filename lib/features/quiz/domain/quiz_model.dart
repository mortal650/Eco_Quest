import 'package:freezed_annotation/freezed_annotation.dart';

part 'quiz_model.freezed.dart';
part 'quiz_model.g.dart';

@freezed
class QuizResult with _$QuizResult {
  const factory QuizResult({
    required String moduleId,
    required int score,
    required int totalQuestions,
    required int ecoPointsEarned,
    required DateTime completedAt,
  }) = _QuizResult;

  factory QuizResult.fromJson(Map<String, dynamic> json) =>
      _$QuizResultFromJson(json);
}
