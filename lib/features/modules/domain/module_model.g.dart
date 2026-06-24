// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EcoModuleImpl _$$EcoModuleImplFromJson(Map<String, dynamic> json) =>
    _$EcoModuleImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      order: (json['order'] as num?)?.toInt() ?? 0,
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((e) => Lesson.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$EcoModuleImplToJson(_$EcoModuleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'icon': instance.icon,
      'order': instance.order,
      'lessons': instance.lessons,
      'questions': instance.questions,
    };

_$LessonImpl _$$LessonImplFromJson(Map<String, dynamic> json) => _$LessonImpl(
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$LessonImplToJson(_$LessonImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
    };

_$QuizQuestionImpl _$$QuizQuestionImplFromJson(Map<String, dynamic> json) =>
    _$QuizQuestionImpl(
      id: json['id'] as String,
      question: json['question'] as String,
      options:
          (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      correctIndex: (json['correctIndex'] as num).toInt(),
      explanation: json['explanation'] as String,
    );

Map<String, dynamic> _$$QuizQuestionImplToJson(_$QuizQuestionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'options': instance.options,
      'correctIndex': instance.correctIndex,
      'explanation': instance.explanation,
    };
