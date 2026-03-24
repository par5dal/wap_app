// lib/features/auth/data/models/token_model.dart

import 'package:wap_app/features/auth/data/models/auth_user_model.dart';
import 'package:wap_app/features/auth/domain/entities/token_entity.dart';

class TokenModel extends TokenEntity {
  const TokenModel({
    required super.accessToken,
    required super.refreshToken,
    super.user,
    super.isNewUser,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'];
    return TokenModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: userData != null
          ? AuthUserModel.fromJson(userData as Map<String, dynamic>)
          : null,
      isNewUser: json['isNewUser'] as bool? ?? false,
    );
  }
}
