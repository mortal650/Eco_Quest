import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_model.freezed.dart';
part 'challenge_model.g.dart';

@freezed
class EcoChallenge with _$EcoChallenge {
  const factory EcoChallenge({
    required String challengeId,
    required String title,
    required String description,
    required String type,
    required int xpReward,
    required DateTime dueDate,
    required String createdBy,
    required String classroomId,
    @Default(0) int completions,
    required DateTime createdAt,
  }) = _EcoChallenge;

  factory EcoChallenge.fromJson(Map<String, dynamic> json) =>
      _$EcoChallengeFromJson(json);
}
