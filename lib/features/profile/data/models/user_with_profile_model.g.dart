// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_with_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserWithProfileModel _$UserWithProfileModelFromJson(
  Map<String, dynamic> json,
) => _UserWithProfileModel(
  id: json['id'] as String,
  email: json['email'] as String,
  role: json['role'] as String?,
  isActive: json['isActive'] as bool?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  profile: json['profile'] == null
      ? null
      : ProfileModel.fromJson(json['profile'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserWithProfileModelToJson(
  _UserWithProfileModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'role': instance.role,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'profile': instance.profile,
};
