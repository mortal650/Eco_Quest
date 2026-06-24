// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EcoUser _$EcoUserFromJson(Map<String, dynamic> json) {
  return _EcoUser.fromJson(json);
}

/// @nodoc
mixin _$EcoUser {
  String get uid => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  int get xp => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  int get streak => throw _privateConstructorUsedError;
  List<String> get badges => throw _privateConstructorUsedError;
  Map<String, List<int>> get completedLessons =>
      throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get lastLogin => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EcoUserCopyWith<EcoUser> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EcoUserCopyWith<$Res> {
  factory $EcoUserCopyWith(EcoUser value, $Res Function(EcoUser) then) =
      _$EcoUserCopyWithImpl<$Res, EcoUser>;
  @useResult
  $Res call(
      {String uid,
      String displayName,
      String email,
      int xp,
      int level,
      int streak,
      List<String> badges,
      Map<String, List<int>> completedLessons,
      DateTime createdAt,
      DateTime lastLogin});
}

/// @nodoc
class _$EcoUserCopyWithImpl<$Res, $Val extends EcoUser>
    implements $EcoUserCopyWith<$Res> {
  _$EcoUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? displayName = null,
    Object? email = null,
    Object? xp = null,
    Object? level = null,
    Object? streak = null,
    Object? badges = null,
    Object? completedLessons = null,
    Object? createdAt = null,
    Object? lastLogin = null,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      xp: null == xp
          ? _value.xp
          : xp // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as int,
      badges: null == badges
          ? _value.badges
          : badges // ignore: cast_nullable_to_non_nullable
              as List<String>,
      completedLessons: null == completedLessons
          ? _value.completedLessons
          : completedLessons // ignore: cast_nullable_to_non_nullable
              as Map<String, List<int>>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastLogin: null == lastLogin
          ? _value.lastLogin
          : lastLogin // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EcoUserImplCopyWith<$Res> implements $EcoUserCopyWith<$Res> {
  factory _$$EcoUserImplCopyWith(
          _$EcoUserImpl value, $Res Function(_$EcoUserImpl) then) =
      __$$EcoUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uid,
      String displayName,
      String email,
      int xp,
      int level,
      int streak,
      List<String> badges,
      Map<String, List<int>> completedLessons,
      DateTime createdAt,
      DateTime lastLogin});
}

/// @nodoc
class __$$EcoUserImplCopyWithImpl<$Res>
    extends _$EcoUserCopyWithImpl<$Res, _$EcoUserImpl>
    implements _$$EcoUserImplCopyWith<$Res> {
  __$$EcoUserImplCopyWithImpl(
      _$EcoUserImpl _value, $Res Function(_$EcoUserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? displayName = null,
    Object? email = null,
    Object? xp = null,
    Object? level = null,
    Object? streak = null,
    Object? badges = null,
    Object? completedLessons = null,
    Object? createdAt = null,
    Object? lastLogin = null,
  }) {
    return _then(_$EcoUserImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      xp: null == xp
          ? _value.xp
          : xp // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as int,
      badges: null == badges
          ? _value._badges
          : badges // ignore: cast_nullable_to_non_nullable
              as List<String>,
      completedLessons: null == completedLessons
          ? _value._completedLessons
          : completedLessons // ignore: cast_nullable_to_non_nullable
              as Map<String, List<int>>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastLogin: null == lastLogin
          ? _value.lastLogin
          : lastLogin // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EcoUserImpl implements _EcoUser {
  const _$EcoUserImpl(
      {required this.uid,
      required this.displayName,
      required this.email,
      this.xp = 0,
      this.level = 1,
      this.streak = 0,
      final List<String> badges = const [],
      final Map<String, List<int>> completedLessons = const {},
      required this.createdAt,
      required this.lastLogin})
      : _badges = badges,
        _completedLessons = completedLessons;

  factory _$EcoUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$EcoUserImplFromJson(json);

  @override
  final String uid;
  @override
  final String displayName;
  @override
  final String email;
  @override
  @JsonKey()
  final int xp;
  @override
  @JsonKey()
  final int level;
  @override
  @JsonKey()
  final int streak;
  final List<String> _badges;
  @override
  @JsonKey()
  List<String> get badges {
    if (_badges is EqualUnmodifiableListView) return _badges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_badges);
  }

  final Map<String, List<int>> _completedLessons;
  @override
  @JsonKey()
  Map<String, List<int>> get completedLessons {
    if (_completedLessons is EqualUnmodifiableMapView) return _completedLessons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_completedLessons);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime lastLogin;

  @override
  String toString() {
    return 'EcoUser(uid: $uid, displayName: $displayName, email: $email, xp: $xp, level: $level, streak: $streak, badges: $badges, completedLessons: $completedLessons, createdAt: $createdAt, lastLogin: $lastLogin)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EcoUserImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.xp, xp) || other.xp == xp) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.streak, streak) || other.streak == streak) &&
            const DeepCollectionEquality().equals(other._badges, _badges) &&
            const DeepCollectionEquality()
                .equals(other._completedLessons, _completedLessons) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastLogin, lastLogin) ||
                other.lastLogin == lastLogin));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uid,
      displayName,
      email,
      xp,
      level,
      streak,
      const DeepCollectionEquality().hash(_badges),
      const DeepCollectionEquality().hash(_completedLessons),
      createdAt,
      lastLogin);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EcoUserImplCopyWith<_$EcoUserImpl> get copyWith =>
      __$$EcoUserImplCopyWithImpl<_$EcoUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EcoUserImplToJson(
      this,
    );
  }
}

abstract class _EcoUser implements EcoUser {
  const factory _EcoUser(
      {required final String uid,
      required final String displayName,
      required final String email,
      final int xp,
      final int level,
      final int streak,
      final List<String> badges,
      final Map<String, List<int>> completedLessons,
      required final DateTime createdAt,
      required final DateTime lastLogin}) = _$EcoUserImpl;

  factory _EcoUser.fromJson(Map<String, dynamic> json) = _$EcoUserImpl.fromJson;

  @override
  String get uid;
  @override
  String get displayName;
  @override
  String get email;
  @override
  int get xp;
  @override
  int get level;
  @override
  int get streak;
  @override
  List<String> get badges;
  @override
  Map<String, List<int>> get completedLessons;
  @override
  DateTime get createdAt;
  @override
  DateTime get lastLogin;
  @override
  @JsonKey(ignore: true)
  _$$EcoUserImplCopyWith<_$EcoUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
