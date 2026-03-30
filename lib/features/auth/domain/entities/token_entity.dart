// lib/features/auth/domain/entities/token_entity.dart
import 'package:equatable/equatable.dart';
import 'package:wap_app/features/auth/domain/entities/auth_user_entity.dart';

/// Resultado de autenticación devuelto por POST /auth/session.
/// No contiene tokens: Firebase SDK gestiona el ID token automáticamente.
class TokenEntity extends Equatable {
  /// Usuario autenticado devuelto por el backend.
  final AuthUserEntity? user;

  /// True si el usuario acaba de crearse (primer acceso).
  final bool isNewUser;

  const TokenEntity({this.user, this.isNewUser = false});

  @override
  List<Object?> get props => [user, isNewUser];
}
