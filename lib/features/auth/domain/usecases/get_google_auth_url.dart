// lib/features/auth/domain/usecases/get_google_auth_url.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/domain/repositories/auth_repository.dart';

class GetGoogleAuthUrlUseCase {
  final AuthRepository repository;

  GetGoogleAuthUrlUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String lang,
    String role = 'CONSUMER',
  }) async {
    return await repository.getGoogleAuthUrl(lang: lang, role: role);
  }
}
