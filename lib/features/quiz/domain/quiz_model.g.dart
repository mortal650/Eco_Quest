// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuizResultImpl _$$QuizResultImplFromJson(Map<String, dynamic> json) =>
    _$QuizResultImpl(
      moduleId: json['moduleId'] as String,
      score: (json['score'] as num).toInt(),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      ecoPointsEarned: (json['ecoPointsEarned'] as num).toInt(),
      completedAt: DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$QuizResultImplToJson(_$QuizResultImpl instance) =>
    <String, dynamic>{
      'moduleId': instance.moduleId,
      'score': instance.score,
      'totalQuestions': instance.totalQuestions,
      'ecoPointsEarned': instance.ecoPointsEarned,
      'completedAt': instance.completedAt.toIso8601String(),
    };
