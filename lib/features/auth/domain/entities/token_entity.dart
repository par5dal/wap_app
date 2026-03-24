// lib/features/auth/domain/entities/token_entity.dart
import 'package:equatable/equatable.dart';
import 'package:wap_app/features/auth/domain/entities/auth_user_entity.dart';

class TokenEntity extends Equatable {
  final String accessToken;
  final String refreshToken;

  /// Usuario autenticado devuelto por el backend (login, register, OAuth).
  final AuthUserEntity? user;

  /// Solo viene en el flujo OAuth cuando el usuario acaba de crearse.
  final bool isNewUser;

  const TokenEntity({
    required this.accessToken,
    required this.refreshToken,
    this.user,
    this.isNewUser = false,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, user, isNewUser];
}
