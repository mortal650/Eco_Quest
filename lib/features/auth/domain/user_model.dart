import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class EcoUser with _$EcoUser {
  const factory EcoUser({
    required String uid,
    required String displayName,
    required String email,
    required String role,
    @Default('') String schoolName,
    @Default('') String city,
    @Default('') String state,
    @Default('') String grade,
    @Default('') String profilePicture,
    @Default('') String institutionName,
    @Default('') String subject,
    @Default('') String experience,
    @Default(0) int xp,
    @Default(1) int level,
    @Default(0) int streak,
    @Default(0) int totalQuizzes,
    @Default(0) int totalQuizCorrect,
    @Default(0.0) double averageQuizScore,
    @Default([]) List<String> badges,
    @Default({}) Map<String, List<int>> completedLessons,
    required DateTime createdAt,
    required DateTime lastLogin,
  }) = _EcoUser;

  factory EcoUser.fromJson(Map<String, dynamic> json) =>
      _$EcoUserFromJson(json);
}
