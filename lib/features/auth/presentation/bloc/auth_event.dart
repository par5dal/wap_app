// lib/features/auth/presentation/bloc/auth_event.dart
part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class LoginButtonPressed extends AuthEvent {
  final String email;
  final String password;
  const LoginButtonPressed({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

class RegisterButtonPressed extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  const RegisterButtonPressed({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });
  @override
  List<Object> get props => [email, password, firstName, lastName];
}

class GoogleSignInPressed extends AuthEvent {
  const GoogleSignInPressed();
}

class AppleSignInPressed extends AuthEvent {
  const AppleSignInPressed();
}

/// Emitido desde main.dart cuando llega el deep link del callback OAuth de Google.
class GoogleCallbackReceived extends AuthEvent {
  final String supabaseAccessToken;
  final String supabaseRefreshToken;

  const GoogleCallbackReceived({
    required this.supabaseAccessToken,
    required this.supabaseRefreshToken,
  });

  @override
  List<Object> get props => [supabaseAccessToken, supabaseRefreshToken];
}

/// Emitido desde main.dart cuando llega el deep link del callback OAuth de Apple.
class AppleCallbackReceived extends AuthEvent {
  final String supabaseAccessToken;
  final String supabaseRefreshToken;

  const AppleCallbackReceived({
    required this.supabaseAccessToken,
    required this.supabaseRefreshToken,
  });

  @override
  List<Object> get props => [supabaseAccessToken, supabaseRefreshToken];
}
