// lib/features/auth/data/models/auth_user_model.dart

import 'package:wap_app/features/auth/domain/entities/auth_user_entity.dart';

class AuthUserModel extends AuthUserEntity {
  const AuthUserModel({
    required super.id,
    required super.email,
    required super.role,
    required super.profileComplete,
    super.firstName,
    super.lastName,
    super.subscriptionStatus,
    super.avatarUrl,
    required super.emailVerified,
    required super.authProvider,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'CONSUMER',
      profileComplete: json['profileComplete'] as bool? ?? false,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      subscriptionStatus: json['subscriptionStatus'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      authProvider: json['authProvider'] as String? ?? 'email',
    );
  }
}
