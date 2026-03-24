// lib/features/auth/domain/usecases/register_user.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/domain/entities/token_entity.dart';
import 'package:wap_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:wap_app/features/auth/domain/usecases/login_user.dart';

class RegisterUserUseCase implements UseCase<TokenEntity, RegisterParams> {
  final AuthRepository repository;

  RegisterUserUseCase(this.repository);

  @override
  Future<Either<Failure, TokenEntity>> call(RegisterParams params) async {
    return await repository.register(
      params.email,
      params.password,
      params.firstName,
      params.lastName,
    );
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName];
}
