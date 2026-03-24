// lib/features/auth/domain/usecases/get_auth_status.dart

import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class GetAuthStatusUseCase {
  final AuthRepository repository;

  GetAuthStatusUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.isAuthenticated();
  }
}
