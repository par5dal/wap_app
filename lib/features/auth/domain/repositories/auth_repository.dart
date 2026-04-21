// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/auth/domain/entities/token_entity.dart';
import 'package:wap_app/features/auth/domain/entities/legal_document.dart';

abstract class AuthRepository {
  Future<Either<Failure, TokenEntity>> login(String email, String password);

  Future<Either<Failure, TokenEntity>> register(
    String email,
    String password,
    String firstName,
    String lastName, {
    String role = 'CONSUMER',
  });

  /// Login nativo con Google (sin redirección al navegador).
  Future<Either<Failure, TokenEntity>> loginWithGoogle();

  /// Login nativo con Apple (sin redirección al navegador).
  Future<Either<Failure, TokenEntity>> loginWithApple();

  Future<Either<Failure, void>> logout();
  Future<Either<Failure, bool>> checkEmailExists(String email);

  /// Obtiene la versión actual requerida de los Términos y Condiciones.
  Future<Either<Failure, String>> getTermsInfo();

  /// Acepta los Términos y Condiciones de la versión indicada.
  Future<Either<Failure, void>> acceptTerms(String version);

  /// Obtiene el documento legal (términos o privacidad) en el idioma especificado.
  Future<Either<Failure, LegalDocument>> getLegalDocument(
    String type,
    String lang,
  );

  /// Crea el perfil del usuario tras aceptar los T&C.
  Future<Either<Failure, void>> createProfile(
    String firstName,
    String lastName,
  );

  /// Comprueba el estado del usuario en el servidor.
  /// Devuelve Left con code='TERMS_NOT_ACCEPTED' si los T&C no están aceptados.
  Future<Either<Failure, void>> checkUserStatus();
}
