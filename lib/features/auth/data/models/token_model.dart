// lib/features/auth/data/models/token_model.dart

import 'package:wap_app/features/auth/data/models/auth_user_model.dart';
import 'package:wap_app/features/auth/domain/entities/token_entity.dart';

/// Modelo que parsea la respuesta de POST /auth/session.
/// El backend devuelve {user, isNewUser} — sin tokens JWT propios.
class TokenModel extends TokenEntity {
  const TokenModel({super.user, super.isNewUser});

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'];
    return TokenModel(
      user: userData != null
          ? AuthUserModel.fromJson(userData as Map<String, dynamic>)
          : null,
      isNewUser: json['isNewUser'] as bool? ?? false,
    );
  }
}
