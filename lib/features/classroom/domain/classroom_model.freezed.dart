// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'classroom_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Classroom _$ClassroomFromJson(Map<String, dynamic> json) {
  return _Classroom.fromJson(json);
}

/// @nodoc
mixin _$Classroom {
  String get classroomId => throw _privateConstructorUsedError;
  String get classroomName => throw _privateConstructorUsedError;
  String get classroomCode => throw _privateConstructorUsedError;
  String get teacherId => throw _privateConstructorUsedError;
  String get teacherName => throw _privateConstructorUsedError;
  int get studentCount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ClassroomCopyWith<Classroom> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassroomCopyWith<$Res> {
  factory $ClassroomCopyWith(Classroom value, $Res Function(Classroom) then) =
      _$ClassroomCopyWithImpl<$Res, Classroom>;
  @useResult
  $Res call(
      {String classroomId,
      String classroomName,
      String classroomCode,
      String teacherId,
      String teacherName,
      int studentCount,
      DateTime createdAt});
}

/// @nodoc
class _$ClassroomCopyWithImpl<$Res, $Val extends Classroom>
    implements $ClassroomCopyWith<$Res> {
  _$ClassroomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classroomId = null,
    Object? classroomName = null,
    Object? classroomCode = null,
    Object? teacherId = null,
    Object? teacherName = null,
    Object? studentCount = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      classroomId: null == classroomId
          ? _value.classroomId
          : classroomId // ignore: cast_nullable_to_non_nullable
              as String,
      classroomName: null == classroomName
          ? _value.classroomName
          : classroomName // ignore: cast_nullable_to_non_nullable
              as String,
      classroomCode: null == classroomCode
          ? _value.classroomCode
          : classroomCode // ignore: cast_nullable_to_non_nullable
              as String,
      teacherId: null == teacherId
          ? _value.teacherId
          : teacherId // ignore: cast_nullable_to_non_nullable
              as String,
      teacherName: null == teacherName
          ? _value.teacherName
          : teacherName // ignore: cast_nullable_to_non_nullable
              as String,
      studentCount: null == studentCount
          ? _value.studentCount
          : studentCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClassroomImplCopyWith<$Res>
    implements $ClassroomCopyWith<$Res> {
  factory _$$ClassroomImplCopyWith(
          _$ClassroomImpl value, $Res Function(_$ClassroomImpl) then) =
      __$$ClassroomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String classroomId,
      String classroomName,
      String classroomCode,
      String teacherId,
      String teacherName,
      int studentCount,
      DateTime createdAt});
}

/// @nodoc
class __$$ClassroomImplCopyWithImpl<$Res>
    extends _$ClassroomCopyWithImpl<$Res, _$ClassroomImpl>
    implements _$$ClassroomImplCopyWith<$Res> {
  __$$ClassroomImplCopyWithImpl(
      _$ClassroomImpl _value, $Res Function(_$ClassroomImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classroomId = null,
    Object? classroomName = null,
    Object? classroomCode = null,
    Object? teacherId = null,
    Object? teacherName = null,
    Object? studentCount = null,
    Object? createdAt = null,
  }) {
    return _then(_$ClassroomImpl(
      classroomId: null == classroomId
          ? _value.classroomId
          : classroomId // ignore: cast_nullable_to_non_nullable
              as String,
      classroomName: null == classroomName
          ? _value.classroomName
          : classroomName // ignore: cast_nullable_to_non_nullable
              as String,
      classroomCode: null == classroomCode
          ? _value.classroomCode
          : classroomCode // ignore: cast_nullable_to_non_nullable
              as String,
      teacherId: null == teacherId
          ? _value.teacherId
          : teacherId // ignore: cast_nullable_to_non_nullable
              as String,
      teacherName: null == teacherName
          ? _value.teacherName
          : teacherName // ignore: cast_nullable_to_non_nullable
              as String,
      studentCount: null == studentCount
          ? _value.studentCount
          : studentCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassroomImpl implements _Classroom {
  const _$ClassroomImpl(
      {required this.classroomId,
      required this.classroomName,
      required this.classroomCode,
      required this.teacherId,
      required this.teacherName,
      this.studentCount = 0,
      required this.createdAt});

  factory _$ClassroomImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassroomImplFromJson(json);

  @override
  final String classroomId;
  @override
  final String classroomName;
  @override
  final String classroomCode;
  @override
  final String teacherId;
  @override
  final String teacherName;
  @override
  @JsonKey()
  final int studentCount;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Classroom(classroomId: $classroomId, classroomName: $classroomName, classroomCode: $classroomCode, teacherId: $teacherId, teacherName: $teacherName, studentCount: $studentCount, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassroomImpl &&
            (identical(other.classroomId, classroomId) ||
                other.classroomId == classroomId) &&
            (identical(other.classroomName, classroomName) ||
                other.classroomName == classroomName) &&
            (identical(other.classroomCode, classroomCode) ||
                other.classroomCode == classroomCode) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.teacherName, teacherName) ||
                other.teacherName == teacherName) &&
            (identical(other.studentCount, studentCount) ||
                other.studentCount == studentCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, classroomId, classroomName,
      classroomCode, teacherId, teacherName, studentCount, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassroomImplCopyWith<_$ClassroomImpl> get copyWith =>
      __$$ClassroomImplCopyWithImpl<_$ClassroomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassroomImplToJson(
      this,
    );
  }
}

abstract class _Classroom implements Classroom {
  const factory _Classroom(
      {required final String classroomId,
      required final String classroomName,
      required final String classroomCode,
      required final String teacherId,
      required final String teacherName,
      final int studentCount,
      required final DateTime createdAt}) = _$ClassroomImpl;

  factory _Classroom.fromJson(Map<String, dynamic> json) =
      _$ClassroomImpl.fromJson;

  @override
  String get classroomId;
  @override
  String get classroomName;
  @override
  String get classroomCode;
  @override
  String get teacherId;
  @override
  String get teacherName;
  @override
  int get studentCount;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$ClassroomImplCopyWith<_$ClassroomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ClassroomMember _$ClassroomMemberFromJson(Map<String, dynamic> json) {
  return _ClassroomMember.fromJson(json);
}

/// @nodoc
mixin _$ClassroomMember {
  String get classroomId => throw _privateConstructorUsedError;
  String get studentId => throw _privateConstructorUsedError;
  String get studentName => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ClassroomMemberCopyWith<ClassroomMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassroomMemberCopyWith<$Res> {
  factory $ClassroomMemberCopyWith(
          ClassroomMember value, $Res Function(ClassroomMember) then) =
      _$ClassroomMemberCopyWithImpl<$Res, ClassroomMember>;
  @useResult
  $Res call(
      {String classroomId,
      String studentId,
      String studentName,
      DateTime joinedAt});
}

/// @nodoc
class _$ClassroomMemberCopyWithImpl<$Res, $Val extends ClassroomMember>
    implements $ClassroomMemberCopyWith<$Res> {
  _$ClassroomMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classroomId = null,
    Object? studentId = null,
    Object? studentName = null,
    Object? joinedAt = null,
  }) {
    return _then(_value.copyWith(
      classroomId: null == classroomId
          ? _value.classroomId
          : classroomId // ignore: cast_nullable_to_non_nullable
              as String,
      studentId: null == studentId
          ? _value.studentId
          : studentId // ignore: cast_nullable_to_non_nullable
              as String,
      studentName: null == studentName
          ? _value.studentName
          : studentName // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClassroomMemberImplCopyWith<$Res>
    implements $ClassroomMemberCopyWith<$Res> {
  factory _$$ClassroomMemberImplCopyWith(_$ClassroomMemberImpl value,
          $Res Function(_$ClassroomMemberImpl) then) =
      __$$ClassroomMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String classroomId,
      String studentId,
      String studentName,
      DateTime joinedAt});
}

/// @nodoc
class __$$ClassroomMemberImplCopyWithImpl<$Res>
    extends _$ClassroomMemberCopyWithImpl<$Res, _$ClassroomMemberImpl>
    implements _$$ClassroomMemberImplCopyWith<$Res> {
  __$$ClassroomMemberImplCopyWithImpl(
      _$ClassroomMemberImpl _value, $Res Function(_$ClassroomMemberImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classroomId = null,
    Object? studentId = null,
    Object? studentName = null,
    Object? joinedAt = null,
  }) {
    return _then(_$ClassroomMemberImpl(
      classroomId: null == classroomId
          ? _value.classroomId
          : classroomId // ignore: cast_nullable_to_non_nullable
              as String,
      studentId: null == studentId
          ? _value.studentId
          : studentId // ignore: cast_nullable_to_non_nullable
              as String,
      studentName: null == studentName
          ? _value.studentName
          : studentName // ignore: cast_nullable_to_non_nullable
              as String,
      joinedAt: null == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClassroomMemberImpl implements _ClassroomMember {
  const _$ClassroomMemberImpl(
      {required this.classroomId,
      required this.studentId,
      required this.studentName,
      required this.joinedAt});

  factory _$ClassroomMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassroomMemberImplFromJson(json);

  @override
  final String classroomId;
  @override
  final String studentId;
  @override
  final String studentName;
  @override
  final DateTime joinedAt;

  @override
  String toString() {
    return 'ClassroomMember(classroomId: $classroomId, studentId: $studentId, studentName: $studentName, joinedAt: $joinedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassroomMemberImpl &&
            (identical(other.classroomId, classroomId) ||
                other.classroomId == classroomId) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.studentName, studentName) ||
                other.studentName == studentName) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, classroomId, studentId, studentName, joinedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassroomMemberImplCopyWith<_$ClassroomMemberImpl> get copyWith =>
      __$$ClassroomMemberImplCopyWithImpl<_$ClassroomMemberImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassroomMemberImplToJson(
      this,
    );
  }
}

abstract class _ClassroomMember implements ClassroomMember {
  const factory _ClassroomMember(
      {required final String classroomId,
      required final String studentId,
      required final String studentName,
      required final DateTime joinedAt}) = _$ClassroomMemberImpl;

  factory _ClassroomMember.fromJson(Map<String, dynamic> json) =
      _$ClassroomMemberImpl.fromJson;

  @override
  String get classroomId;
  @override
  String get studentId;
  @override
  String get studentName;
  @override
  DateTime get joinedAt;
  @override
  @JsonKey(ignore: true)
  _$$ClassroomMemberImplCopyWith<_$ClassroomMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
