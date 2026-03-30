// lib/features/auth/domain/usecases/login_with_apple.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/domain/entities/token_entity.dart';
import 'package:wap_app/features/auth/domain/repositories/auth_repository.dart';

class LoginWithAppleUseCase {
  final AuthRepository repository;

  LoginWithAppleUseCase(this.repository);

  Future<Either<Failure, TokenEntity>> call() async {
    return await repository.loginWithApple();
  }
}
