// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classroom_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClassroomImpl _$$ClassroomImplFromJson(Map<String, dynamic> json) =>
    _$ClassroomImpl(
      classroomId: json['classroomId'] as String,
      classroomName: json['classroomName'] as String,
      classroomCode: json['classroomCode'] as String,
      teacherId: json['teacherId'] as String,
      teacherName: json['teacherName'] as String,
      studentCount: (json['studentCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ClassroomImplToJson(_$ClassroomImpl instance) =>
    <String, dynamic>{
      'classroomId': instance.classroomId,
      'classroomName': instance.classroomName,
      'classroomCode': instance.classroomCode,
      'teacherId': instance.teacherId,
      'teacherName': instance.teacherName,
      'studentCount': instance.studentCount,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$ClassroomMemberImpl _$$ClassroomMemberImplFromJson(
        Map<String, dynamic> json) =>
    _$ClassroomMemberImpl(
      classroomId: json['classroomId'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$$ClassroomMemberImplToJson(
        _$ClassroomMemberImpl instance) =>
    <String, dynamic>{
      'classroomId': instance.classroomId,
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };
