// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EcoChallengeImpl _$$EcoChallengeImplFromJson(Map<String, dynamic> json) =>
    _$EcoChallengeImpl(
      challengeId: json['challengeId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      xpReward: (json['xpReward'] as num).toInt(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      createdBy: json['createdBy'] as String,
      classroomId: json['classroomId'] as String,
      completions: (json['completions'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$EcoChallengeImplToJson(_$EcoChallengeImpl instance) =>
    <String, dynamic>{
      'challengeId': instance.challengeId,
      'title': instance.title,
      'description': instance.description,
      'type': instance.type,
      'xpReward': instance.xpReward,
      'dueDate': instance.dueDate.toIso8601String(),
      'createdBy': instance.createdBy,
      'classroomId': instance.classroomId,
      'completions': instance.completions,
      'createdAt': instance.createdAt.toIso8601String(),
    };
