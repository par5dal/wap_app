// lib/features/profile/data/models/user_with_profile_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wap_app/features/profile/data/models/profile_model.dart';
import 'package:wap_app/features/profile/domain/entities/user_with_profile_entity.dart';

part 'user_with_profile_model.freezed.dart';
part 'user_with_profile_model.g.dart';

@Freezed(fromJson: true, toJson: true)
sealed class UserWithProfileModel with _$UserWithProfileModel {
  const factory UserWithProfileModel({
    required String id,
    required String email,
    String? role,
    bool? isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    ProfileModel? profile,
  }) = _UserWithProfileModel;

  // Custom fromJson para transformar snake_case a camelCase
  factory UserWithProfileModel.fromJson(Map<String, dynamic> json) {
    return UserWithProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String?,
      isActive: json['is_active'] as bool?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      profile: json['profile'] != null
          ? ProfileModel.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }

  // Custom toJson
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'profile': profile?.toJson(),
    };
  }
}

extension UserWithProfileModelX on UserWithProfileModel {
  // Método para convertir a Entity
  UserWithProfileEntity toEntity() {
    return UserWithProfileEntity(
      id: id,
      email: email,
      role: role,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      profile: profile?.toEntity(),
    );
  }
}
