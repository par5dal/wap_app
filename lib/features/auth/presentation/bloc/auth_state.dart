// lib/features/auth/presentation/bloc/auth_state.dart
part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object> get props => [];
}

class AuthFormInitial extends AuthState {}

class AuthFormLoading extends AuthState {}

/// Login/registro completado correctamente (usuario existente con perfil completo).
class AuthFormSuccess extends AuthState {}

/// Nuevo usuario recién registrado (muestra bienvenida/onboarding).
class AuthFormSuccessNewUser extends AuthState {}

/// Usuario autenticado pero con perfil incompleto (redirigir a completar perfil).
class AuthFormSuccessProfileIncomplete extends AuthState {}

class AuthFormFailure extends AuthState {
  final String message;
  const AuthFormFailure(this.message);
  @override
  List<Object> get props => [message];
}

/// El registro fue exitoso pero Supabase requiere confirmación de email.
class AuthRegisterEmailVerificationRequired extends AuthState {
  final String email;
  const AuthRegisterEmailVerificationRequired(this.email);
  @override
  List<Object> get props => [email];
}
