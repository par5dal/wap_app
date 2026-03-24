// lib/features/auth/domain/usecases/check_email_exists.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/domain/repositories/auth_repository.dart';

class CheckEmailExistsUseCase {
  final AuthRepository repository;

  CheckEmailExistsUseCase(this.repository);

  Future<Either<Failure, bool>> call(String email) async {
    return await repository.checkEmailExists(email);
  }
}
