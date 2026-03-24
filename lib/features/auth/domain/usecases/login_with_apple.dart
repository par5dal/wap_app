// lib/features/auth/domain/usecases/login_with_apple.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/domain/entities/token_entity.dart';
import 'package:wap_app/features/auth/domain/repositories/auth_repository.dart';

class AppleCallbackParams extends Equatable {
  final String supabaseAccessToken;
  final String supabaseRefreshToken;
  final String lang;
  final String? role;

  const AppleCallbackParams({
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

class LoginWithAppleCallbackUseCase {
  final AuthRepository repository;

  LoginWithAppleCallbackUseCase(this.repository);

  Future<Either<Failure, TokenEntity>> call(AppleCallbackParams params) async {
    return await repository.loginWithAppleCallback(
      supabaseAccessToken: params.supabaseAccessToken,
      supabaseRefreshToken: params.supabaseRefreshToken,
      lang: params.lang,
      role: params.role,
    );
  }
}
