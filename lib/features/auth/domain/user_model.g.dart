// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DateTime _dateTimeFromJson(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  if (value is String) return DateTime.parse(value);
  if (value is Timestamp) return value.toDate();
  return DateTime.now();
}

_$EcoUserImpl _$$EcoUserImplFromJson(Map<String, dynamic> json) =>
    _$EcoUserImpl(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'student',
      schoolName: json['schoolName'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      profilePicture: json['profilePicture'] as String? ?? '',
      institutionName: json['institutionName'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      experience: json['experience'] as String? ?? '',
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      totalQuizzes: (json['totalQuizzes'] as num?)?.toInt() ?? 0,
      totalQuizCorrect: (json['totalQuizCorrect'] as num?)?.toInt() ?? 0,
      averageQuizScore: (json['averageQuizScore'] as num?)?.toDouble() ?? 0.0,
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
      createdAt: _dateTimeFromJson(json['createdAt']),
      lastLogin: _dateTimeFromJson(json['lastLogin']),
    );

Map<String, dynamic> _$$EcoUserImplToJson(_$EcoUserImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'email': instance.email,
      'role': instance.role,
      'schoolName': instance.schoolName,
      'city': instance.city,
      'state': instance.state,
      'grade': instance.grade,
      'profilePicture': instance.profilePicture,
      'institutionName': instance.institutionName,
      'subject': instance.subject,
      'experience': instance.experience,
      'xp': instance.xp,
      'level': instance.level,
      'streak': instance.streak,
      'totalQuizzes': instance.totalQuizzes,
      'totalQuizCorrect': instance.totalQuizCorrect,
      'averageQuizScore': instance.averageQuizScore,
      'badges': instance.badges,
      'completedLessons': instance.completedLessons,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastLogin': instance.lastLogin.toIso8601String(),
    };
