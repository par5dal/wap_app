// lib/features/auth/domain/usecases/login_user.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/domain/entities/token_entity.dart';
import 'package:wap_app/features/auth/domain/repositories/auth_repository.dart';

// Clase base para todos los casos de uso (buena práctica)
abstract class UseCase<ReturnType, Params> {
  Future<Either<Failure, ReturnType>> call(Params params);
}

// Nuestro caso de uso específico para el login
class LoginUser implements UseCase<TokenEntity, LoginParams> {
  final AuthRepository repository;

  LoginUser(this.repository);

  @override
  Future<Either<Failure, TokenEntity>> call(LoginParams params) async {
    return await repository.login(params.email, params.password);
  }
}

// Clase para encapsular los parámetros que necesita este caso de uso
class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
