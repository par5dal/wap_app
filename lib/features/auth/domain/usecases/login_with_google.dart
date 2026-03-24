// lib/features/auth/domain/usecases/login_with_google.dart
// Nota: Este archivo contiene el caso de uso del callback OAuth de Google.
// Para obtener la URL de autorización, ver get_google_auth_url.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/domain/entities/token_entity.dart';
import 'package:wap_app/features/auth/domain/repositories/auth_repository.dart';

class GoogleCallbackParams extends Equatable {
  final String supabaseAccessToken;
  final String supabaseRefreshToken;
  final String lang;
  final String? role;

  const GoogleCallbackParams({
    required this.supabaseAccessToken,
    required this.supabaseRefreshToken,
    required this.lang,
    this.role,
  });

  @override
  List<Object?> get props => [
    supabaseAccessToken,
    supabaseRefreshToken,
    lang,
    role,
  ];
}

class LoginWithGoogleCallbackUseCase {
  final AuthRepository repository;

  LoginWithGoogleCallbackUseCase(this.repository);

  Future<Either<Failure, TokenEntity>> call(GoogleCallbackParams params) async {
    return await repository.loginWithGoogleCallback(
      supabaseAccessToken: params.supabaseAccessToken,
      supabaseRefreshToken: params.supabaseRefreshToken,
      lang: params.lang,
      role: params.role,
    );
  }
}
