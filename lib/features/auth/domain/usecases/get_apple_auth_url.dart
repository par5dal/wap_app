// lib/features/auth/domain/usecases/get_apple_auth_url.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/domain/repositories/auth_repository.dart';

class GetAppleAuthUrlUseCase {
  final AuthRepository repository;

  GetAppleAuthUrlUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String lang,
    String role = 'CONSUMER',
  }) async {
    return await repository.getAppleAuthUrl(lang: lang, role: role);
  }
}
