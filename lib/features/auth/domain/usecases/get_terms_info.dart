// lib/features/auth/domain/usecases/get_terms_info.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/domain/repositories/auth_repository.dart';

class GetTermsInfoUseCase {
  final AuthRepository repository;

  GetTermsInfoUseCase(this.repository);

  Future<Either<Failure, String>> call() async {
    return await repository.getTermsInfo();
  }
}
