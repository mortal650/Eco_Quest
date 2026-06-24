// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EcoUserImpl _$$EcoUserImplFromJson(Map<String, dynamic> json) =>
    _$EcoUserImpl(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      completedLessons: (json['completedLessons'] as Map<String, dynamic>?)
              ?.map(
            (k, e) => MapEntry(k,
                (e as List<dynamic>).map((e) => (e as num).toInt()).toList()),
          ) ??
          const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: DateTime.parse(json['lastLogin'] as String),
    );

Map<String, dynamic> _$$EcoUserImplToJson(_$EcoUserImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'email': instance.email,
      'xp': instance.xp,
      'level': instance.level,
      'streak': instance.streak,
      'badges': instance.badges,
      'completedLessons': instance.completedLessons,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastLogin': instance.lastLogin.toIso8601String(),
    };
