import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class EcoUser with _$EcoUser {
  const factory EcoUser({
    required String uid,
    required String displayName,
    required String email,
    @Default(0) int xp,
    @Default(1) int level,
    @Default(0) int streak,
    @Default([]) List<String> badges,
    @Default({}) Map<String, List<int>> completedLessons,
    required DateTime createdAt,
    required DateTime lastLogin,
  }) = _EcoUser;

  factory EcoUser.fromJson(Map<String, dynamic> json) =>
      _$EcoUserFromJson(json);
}
