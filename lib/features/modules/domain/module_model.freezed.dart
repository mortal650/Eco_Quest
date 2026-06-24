// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'module_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EcoModule _$EcoModuleFromJson(Map<String, dynamic> json) {
  return _EcoModule.fromJson(json);
}

/// @nodoc
mixin _$EcoModule {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  List<Lesson> get lessons => throw _privateConstructorUsedError;
  List<QuizQuestion> get questions => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EcoModuleCopyWith<EcoModule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EcoModuleCopyWith<$Res> {
  factory $EcoModuleCopyWith(EcoModule value, $Res Function(EcoModule) then) =
      _$EcoModuleCopyWithImpl<$Res, EcoModule>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String icon,
      int order,
      List<Lesson> lessons,
      List<QuizQuestion> questions});
}

/// @nodoc
class _$EcoModuleCopyWithImpl<$Res, $Val extends EcoModule>
    implements $EcoModuleCopyWith<$Res> {
  _$EcoModuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? icon = null,
    Object? order = null,
    Object? lessons = null,
    Object? questions = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      lessons: null == lessons
          ? _value.lessons
          : lessons // ignore: cast_nullable_to_non_nullable
              as List<Lesson>,
      questions: null == questions
          ? _value.questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<QuizQuestion>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EcoModuleImplCopyWith<$Res>
    implements $EcoModuleCopyWith<$Res> {
  factory _$$EcoModuleImplCopyWith(
          _$EcoModuleImpl value, $Res Function(_$EcoModuleImpl) then) =
      __$$EcoModuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String icon,
      int order,
      List<Lesson> lessons,
      List<QuizQuestion> questions});
}

/// @nodoc
class __$$EcoModuleImplCopyWithImpl<$Res>
    extends _$EcoModuleCopyWithImpl<$Res, _$EcoModuleImpl>
    implements _$$EcoModuleImplCopyWith<$Res> {
  __$$EcoModuleImplCopyWithImpl(
      _$EcoModuleImpl _value, $Res Function(_$EcoModuleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? icon = null,
    Object? order = null,
    Object? lessons = null,
    Object? questions = null,
  }) {
    return _then(_$EcoModuleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      lessons: null == lessons
          ? _value._lessons
          : lessons // ignore: cast_nullable_to_non_nullable
              as List<Lesson>,
      questions: null == questions
          ? _value._questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<QuizQuestion>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EcoModuleImpl implements _EcoModule {
  const _$EcoModuleImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.icon,
      this.order = 0,
      final List<Lesson> lessons = const [],
      final List<QuizQuestion> questions = const []})
      : _lessons = lessons,
        _questions = questions;

  factory _$EcoModuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$EcoModuleImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String icon;
  @override
  @JsonKey()
  final int order;
  final List<Lesson> _lessons;
  @override
  @JsonKey()
  List<Lesson> get lessons {
    if (_lessons is EqualUnmodifiableListView) return _lessons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lessons);
  }

  final List<QuizQuestion> _questions;
  @override
  @JsonKey()
  List<QuizQuestion> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  @override
  String toString() {
    return 'EcoModule(id: $id, title: $title, description: $description, icon: $icon, order: $order, lessons: $lessons, questions: $questions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EcoModuleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.order, order) || other.order == order) &&
            const DeepCollectionEquality().equals(other._lessons, _lessons) &&
            const DeepCollectionEquality()
                .equals(other._questions, _questions));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      icon,
      order,
      const DeepCollectionEquality().hash(_lessons),
      const DeepCollectionEquality().hash(_questions));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EcoModuleImplCopyWith<_$EcoModuleImpl> get copyWith =>
      __$$EcoModuleImplCopyWithImpl<_$EcoModuleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EcoModuleImplToJson(
      this,
    );
  }
}

abstract class _EcoModule implements EcoModule {
  const factory _EcoModule(
      {required final String id,
      required final String title,
      required final String description,
      required final String icon,
      final int order,
      final List<Lesson> lessons,
      final List<QuizQuestion> questions}) = _$EcoModuleImpl;

  factory _EcoModule.fromJson(Map<String, dynamic> json) =
      _$EcoModuleImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get icon;
  @override
  int get order;
  @override
  List<Lesson> get lessons;
  @override
  List<QuizQuestion> get questions;
  @override
  @JsonKey(ignore: true)
  _$$EcoModuleImplCopyWith<_$EcoModuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Lesson _$LessonFromJson(Map<String, dynamic> json) {
  return _Lesson.fromJson(json);
}

/// @nodoc
mixin _$Lesson {
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LessonCopyWith<Lesson> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LessonCopyWith<$Res> {
  factory $LessonCopyWith(Lesson value, $Res Function(Lesson) then) =
      _$LessonCopyWithImpl<$Res, Lesson>;
  @useResult
  $Res call({String title, String content, String? imageUrl});
}

/// @nodoc
class _$LessonCopyWithImpl<$Res, $Val extends Lesson>
    implements $LessonCopyWith<$Res> {
  _$LessonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? content = null,
    Object? imageUrl = freezed,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LessonImplCopyWith<$Res> implements $LessonCopyWith<$Res> {
  factory _$$LessonImplCopyWith(
          _$LessonImpl value, $Res Function(_$LessonImpl) then) =
      __$$LessonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, String content, String? imageUrl});
}

/// @nodoc
class __$$LessonImplCopyWithImpl<$Res>
    extends _$LessonCopyWithImpl<$Res, _$LessonImpl>
    implements _$$LessonImplCopyWith<$Res> {
  __$$LessonImplCopyWithImpl(
      _$LessonImpl _value, $Res Function(_$LessonImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? content = null,
    Object? imageUrl = freezed,
  }) {
    return _then(_$LessonImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LessonImpl implements _Lesson {
  const _$LessonImpl(
      {required this.title, required this.content, this.imageUrl});

  factory _$LessonImpl.fromJson(Map<String, dynamic> json) =>
      _$$LessonImplFromJson(json);

  @override
  final String title;
  @override
  final String content;
  @override
  final String? imageUrl;

  @override
  String toString() {
    return 'Lesson(title: $title, content: $content, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LessonImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, title, content, imageUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LessonImplCopyWith<_$LessonImpl> get copyWith =>
      __$$LessonImplCopyWithImpl<_$LessonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LessonImplToJson(
      this,
    );
  }
}

abstract class _Lesson implements Lesson {
  const factory _Lesson(
      {required final String title,
      required final String content,
      final String? imageUrl}) = _$LessonImpl;

  factory _Lesson.fromJson(Map<String, dynamic> json) = _$LessonImpl.fromJson;

  @override
  String get title;
  @override
  String get content;
  @override
  String? get imageUrl;
  @override
  @JsonKey(ignore: true)
  _$$LessonImplCopyWith<_$LessonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

QuizQuestion _$QuizQuestionFromJson(Map<String, dynamic> json) {
  return _QuizQuestion.fromJson(json);
}

/// @nodoc
mixin _$QuizQuestion {
  String get id => throw _privateConstructorUsedError;
  String get question => throw _privateConstructorUsedError;
  List<String> get options => throw _privateConstructorUsedError;
  int get correctIndex => throw _privateConstructorUsedError;
  String get explanation => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuizQuestionCopyWith<QuizQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizQuestionCopyWith<$Res> {
  factory $QuizQuestionCopyWith(
          QuizQuestion value, $Res Function(QuizQuestion) then) =
      _$QuizQuestionCopyWithImpl<$Res, QuizQuestion>;
  @useResult
  $Res call(
      {String id,
      String question,
      List<String> options,
      int correctIndex,
      String explanation});
}

/// @nodoc
class _$QuizQuestionCopyWithImpl<$Res, $Val extends QuizQuestion>
    implements $QuizQuestionCopyWith<$Res> {
  _$QuizQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? question = null,
    Object? options = null,
    Object? correctIndex = null,
    Object? explanation = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<String>,
      correctIndex: null == correctIndex
          ? _value.correctIndex
          : correctIndex // ignore: cast_nullable_to_non_nullable
              as int,
      explanation: null == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuizQuestionImplCopyWith<$Res>
    implements $QuizQuestionCopyWith<$Res> {
  factory _$$QuizQuestionImplCopyWith(
          _$QuizQuestionImpl value, $Res Function(_$QuizQuestionImpl) then) =
      __$$QuizQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String question,
      List<String> options,
      int correctIndex,
      String explanation});
}

/// @nodoc
class __$$QuizQuestionImplCopyWithImpl<$Res>
    extends _$QuizQuestionCopyWithImpl<$Res, _$QuizQuestionImpl>
    implements _$$QuizQuestionImplCopyWith<$Res> {
  __$$QuizQuestionImplCopyWithImpl(
      _$QuizQuestionImpl _value, $Res Function(_$QuizQuestionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? question = null,
    Object? options = null,
    Object? correctIndex = null,
    Object? explanation = null,
  }) {
    return _then(_$QuizQuestionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as List<String>,
      correctIndex: null == correctIndex
          ? _value.correctIndex
          : correctIndex // ignore: cast_nullable_to_non_nullable
              as int,
      explanation: null == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuizQuestionImpl implements _QuizQuestion {
  const _$QuizQuestionImpl(
      {required this.id,
      required this.question,
      required final List<String> options,
      required this.correctIndex,
      required this.explanation})
      : _options = options;

  factory _$QuizQuestionImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuizQuestionImplFromJson(json);

  @override
  final String id;
  @override
  final String question;
  final List<String> _options;
  @override
  List<String> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  final int correctIndex;
  @override
  final String explanation;

  @override
  String toString() {
    return 'QuizQuestion(id: $id, question: $question, options: $options, correctIndex: $correctIndex, explanation: $explanation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizQuestionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.question, question) ||
                other.question == question) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.correctIndex, correctIndex) ||
                other.correctIndex == correctIndex) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, question,
      const DeepCollectionEquality().hash(_options), correctIndex, explanation);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizQuestionImplCopyWith<_$QuizQuestionImpl> get copyWith =>
      __$$QuizQuestionImplCopyWithImpl<_$QuizQuestionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuizQuestionImplToJson(
      this,
    );
  }
}

abstract class _QuizQuestion implements QuizQuestion {
  const factory _QuizQuestion(
      {required final String id,
      required final String question,
      required final List<String> options,
      required final int correctIndex,
      required final String explanation}) = _$QuizQuestionImpl;

  factory _QuizQuestion.fromJson(Map<String, dynamic> json) =
      _$QuizQuestionImpl.fromJson;

  @override
  String get id;
  @override
  String get question;
  @override
  List<String> get options;
  @override
  int get correctIndex;
  @override
  String get explanation;
  @override
  @JsonKey(ignore: true)
  _$$QuizQuestionImplCopyWith<_$QuizQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
