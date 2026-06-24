// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

QuizResult _$QuizResultFromJson(Map<String, dynamic> json) {
  return _QuizResult.fromJson(json);
}

/// @nodoc
mixin _$QuizResult {
  String get moduleId => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  int get totalQuestions => throw _privateConstructorUsedError;
  int get ecoPointsEarned => throw _privateConstructorUsedError;
  DateTime get completedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuizResultCopyWith<QuizResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizResultCopyWith<$Res> {
  factory $QuizResultCopyWith(
          QuizResult value, $Res Function(QuizResult) then) =
      _$QuizResultCopyWithImpl<$Res, QuizResult>;
  @useResult
  $Res call(
      {String moduleId,
      int score,
      int totalQuestions,
      int ecoPointsEarned,
      DateTime completedAt});
}

/// @nodoc
class _$QuizResultCopyWithImpl<$Res, $Val extends QuizResult>
    implements $QuizResultCopyWith<$Res> {
  _$QuizResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? moduleId = null,
    Object? score = null,
    Object? totalQuestions = null,
    Object? ecoPointsEarned = null,
    Object? completedAt = null,
  }) {
    return _then(_value.copyWith(
      moduleId: null == moduleId
          ? _value.moduleId
          : moduleId // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      totalQuestions: null == totalQuestions
          ? _value.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int,
      ecoPointsEarned: null == ecoPointsEarned
          ? _value.ecoPointsEarned
          : ecoPointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuizResultImplCopyWith<$Res>
    implements $QuizResultCopyWith<$Res> {
  factory _$$QuizResultImplCopyWith(
          _$QuizResultImpl value, $Res Function(_$QuizResultImpl) then) =
      __$$QuizResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String moduleId,
      int score,
      int totalQuestions,
      int ecoPointsEarned,
      DateTime completedAt});
}

/// @nodoc
class __$$QuizResultImplCopyWithImpl<$Res>
    extends _$QuizResultCopyWithImpl<$Res, _$QuizResultImpl>
    implements _$$QuizResultImplCopyWith<$Res> {
  __$$QuizResultImplCopyWithImpl(
      _$QuizResultImpl _value, $Res Function(_$QuizResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? moduleId = null,
    Object? score = null,
    Object? totalQuestions = null,
    Object? ecoPointsEarned = null,
    Object? completedAt = null,
  }) {
    return _then(_$QuizResultImpl(
      moduleId: null == moduleId
          ? _value.moduleId
          : moduleId // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      totalQuestions: null == totalQuestions
          ? _value.totalQuestions
          : totalQuestions // ignore: cast_nullable_to_non_nullable
              as int,
      ecoPointsEarned: null == ecoPointsEarned
          ? _value.ecoPointsEarned
          : ecoPointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QuizResultImpl implements _QuizResult {
  const _$QuizResultImpl(
      {required this.moduleId,
      required this.score,
      required this.totalQuestions,
      required this.ecoPointsEarned,
      required this.completedAt});

  factory _$QuizResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuizResultImplFromJson(json);

  @override
  final String moduleId;
  @override
  final int score;
  @override
  final int totalQuestions;
  @override
  final int ecoPointsEarned;
  @override
  final DateTime completedAt;

  @override
  String toString() {
    return 'QuizResult(moduleId: $moduleId, score: $score, totalQuestions: $totalQuestions, ecoPointsEarned: $ecoPointsEarned, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizResultImpl &&
            (identical(other.moduleId, moduleId) ||
                other.moduleId == moduleId) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.totalQuestions, totalQuestions) ||
                other.totalQuestions == totalQuestions) &&
            (identical(other.ecoPointsEarned, ecoPointsEarned) ||
                other.ecoPointsEarned == ecoPointsEarned) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, moduleId, score, totalQuestions,
      ecoPointsEarned, completedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizResultImplCopyWith<_$QuizResultImpl> get copyWith =>
      __$$QuizResultImplCopyWithImpl<_$QuizResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QuizResultImplToJson(
      this,
    );
  }
}

abstract class _QuizResult implements QuizResult {
  const factory _QuizResult(
      {required final String moduleId,
      required final int score,
      required final int totalQuestions,
      required final int ecoPointsEarned,
      required final DateTime completedAt}) = _$QuizResultImpl;

  factory _QuizResult.fromJson(Map<String, dynamic> json) =
      _$QuizResultImpl.fromJson;

  @override
  String get moduleId;
  @override
  int get score;
  @override
  int get totalQuestions;
  @override
  int get ecoPointsEarned;
  @override
  DateTime get completedAt;
  @override
  @JsonKey(ignore: true)
  _$$QuizResultImplCopyWith<_$QuizResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
