// lib/features/auth/domain/usecases/get_legal_document.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/domain/entities/legal_document.dart';
import 'package:wap_app/features/auth/domain/repositories/auth_repository.dart';

class GetLegalDocumentUseCase {
  final AuthRepository repository;

  GetLegalDocumentUseCase(this.repository);

  /// Obtiene el documento legal (términos o privacidad) del repositorio.
  ///
  /// [type] puede ser 'terms' o 'privacy'
  /// [lang] puede ser 'es', 'en', 'pt', etc.
  Future<Either<Failure, LegalDocument>> call({
    required String type,
    required String lang,
  }) async {
    return await repository.getLegalDocument(type, lang);
  }
}
