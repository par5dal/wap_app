// lib/features/auth/domain/usecases/accept_terms.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/domain/repositories/auth_repository.dart';

class AcceptTermsUseCase {
  final AuthRepository repository;

  AcceptTermsUseCase(this.repository);

  Future<Either<Failure, void>> call(String version) async {
    return await repository.acceptTerms(version);
  }
}
