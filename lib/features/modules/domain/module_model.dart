import 'package:freezed_annotation/freezed_annotation.dart';

part 'module_model.freezed.dart';
part 'module_model.g.dart';

enum QuestionDifficulty { easy, medium, hard }

@freezed
class EcoModule with _$EcoModule {
  const factory EcoModule({
    required String id,
    required String title,
    required String description,
    required String icon,
    @Default(0) int order,
    @Default([]) List<Lesson> lessons,
    @Default([]) List<QuizQuestion> questions,
  }) = _EcoModule;

  factory EcoModule.fromJson(Map<String, dynamic> json) =>
      _$EcoModuleFromJson(json);
}

@freezed
class Lesson with _$Lesson {
  const factory Lesson({
    required String title,
    required String content,
    String? imageUrl,
  }) = _Lesson;

  factory Lesson.fromJson(Map<String, dynamic> json) =>
      _$LessonFromJson(json);
}

@freezed
class QuizQuestion with _$QuizQuestion {
  const factory QuizQuestion({
    required String id,
    required String question,
    required List<String> options,
    required int correctIndex,
    required String explanation,
    @Default(QuestionDifficulty.medium) QuestionDifficulty difficulty,
  }) = _QuizQuestion;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionFromJson(json);
}
