// lib/features/auth/domain/entities/auth_user_entity.dart

import 'package:equatable/equatable.dart';

/// Entidad de usuario autenticado devuelta por el backend en login/register/OAuth.
/// El campo [role] es el rol real de la app (CONSUMER | PROMOTER | ADMIN);
/// ignorar el campo interno de Supabase "authenticated".
class AuthUserEntity extends Equatable {
  final String id;
  final String email;
  final String role; // CONSUMER | PROMOTER | ADMIN
  final bool profileComplete;
  final String? firstName;
  final String? lastName;
  final String? subscriptionStatus;
  final String? avatarUrl;
  final bool emailVerified;
  final String authProvider; // email | google | apple

  const AuthUserEntity({
    required this.id,
    required this.email,
    required this.role,
    required this.profileComplete,
    this.firstName,
    this.lastName,
    this.subscriptionStatus,
    this.avatarUrl,
    required this.emailVerified,
    required this.authProvider,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    role,
    profileComplete,
    firstName,
    lastName,
    subscriptionStatus,
    avatarUrl,
    emailVerified,
    authProvider,
  ];
}
