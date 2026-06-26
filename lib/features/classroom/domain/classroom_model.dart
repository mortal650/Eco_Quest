import 'package:freezed_annotation/freezed_annotation.dart';

part 'classroom_model.freezed.dart';
part 'classroom_model.g.dart';

@freezed
class Classroom with _$Classroom {
  const factory Classroom({
    required String classroomId,
    required String classroomName,
    required String classroomCode,
    required String teacherId,
    required String teacherName,
    @Default(0) int studentCount,
    required DateTime createdAt,
  }) = _Classroom;

  factory Classroom.fromJson(Map<String, dynamic> json) =>
      _$ClassroomFromJson(json);
}

@freezed
class ClassroomMember with _$ClassroomMember {
  const factory ClassroomMember({
    required String classroomId,
    required String studentId,
    required String studentName,
    required DateTime joinedAt,
  }) = _ClassroomMember;

  factory ClassroomMember.fromJson(Map<String, dynamic> json) =>
      _$ClassroomMemberFromJson(json);
}
