// lib/features/auth/data/datasources/auth_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wap_app/core/config/env_config.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:wap_app/core/constants/api_constants.dart';
import 'package:wap_app/core/error/app_exception.dart';
import 'package:wap_app/features/auth/data/models/token_model.dart';
import 'package:wap_app/features/auth/data/models/legal_document_model.dart';

abstract class AuthRemoteDataSource {
  /// Login con email y contraseña.
  Future<TokenModel> login(String email, String password);

  /// Registro con email y contraseña + nombre.
  Future<TokenModel> register(
    String email,
    String password,
    String firstName,
    String lastName, {
    String role = 'CONSUMER',
  });

  /// Login nativo con Google. No requiere parámetros.
  Future<TokenModel> loginWithGoogle();

  /// Login nativo con Apple. No requiere parámetros.
  Future<TokenModel> loginWithApple();

  Future<bool> checkEmailExists(String email);

  Future<void> logout();

  /// Obtiene la versión de los Términos y Condiciones requerida por el backend.
  Future<String> getTermsInfo();

  /// Acepta los Términos y Condiciones de la versión indicada.
  Future<void> acceptTerms(String version);

  /// Crea el perfil del usuario tras aceptar los T&C.
  Future<void> createProfile(String firstName, String lastName);

  /// Comprueba el estado del usuario en el servidor.
  Future<void> checkUserStatus();

  /// Obtiene el documento legal (términos o privacidad) del backend.
  Future<LegalDocumentModel> getLegalDocument(String type, String lang);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      final message = e.response!.data['message'];
      if (message is List) return message.join('\n');
      if (message is String) return message;
    }
    return 'Error de comunicación con el servidor.';
  }

  /// Intercambia el Firebase ID token por datos del perfil del backend.
  Future<TokenModel> _postSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const ServerException(
        message: 'No hay sesión de Firebase activa',
        code: 'no_firebase_user',
      );
    }
    final idToken = await user.getIdToken();
    final response = await dio.post(
      ApiConstants.sessionEndpoint,
      data: {'idToken': idToken},
    );
    return TokenModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TokenModel> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _postSession();
    } on FirebaseAuthException catch (e, stackTrace) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        throw AuthenticationException(
          message: 'Credenciales incorrectas',
          code: 'invalid_credentials',
          originalError: e,
          stackTrace: stackTrace,
        );
      }
      throw ServerException(
        message: e.message ?? 'Error de autenticación',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } on DioException catch (e, stackTrace) {
      throw ServerException(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        code: 'server_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ServerException(
        message: 'Error inesperado durante el login',
        code: 'unknown_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<TokenModel> register(
    String email,
    String password,
    String firstName,
    String lastName, {
    String role = 'CONSUMER',
  }) async {
    try {
      // 1. El backend crea el usuario en Firebase + BD
      await dio.post(
        ApiConstants.registerEndpoint,
        data: {'email': email, 'password': password, 'role': role},
      );

      // 2. Iniciar sesión local con Firebase SDK
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 3. Crear perfil (firstName/lastName) — fallo no bloquea el registro
      try {
        await dio.post(
          ApiConstants.createProfileEndpoint,
          data: {'first_name': firstName, 'last_name': lastName},
        );
      } on DioException {
        // No crítico: el usuario puede completar el perfil más tarde
      }

      // 4. Devolver datos de sesión desde el backend
      return await _postSession();
    } on DioException catch (e, stackTrace) {
      throw ServerException(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        code: 'register_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    } on FirebaseAuthException catch (e, stackTrace) {
      throw ServerException(
        message: e.message ?? 'Error de autenticación en registro',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ServerException(
        message: 'Error inesperado durante el registro',
        code: 'unknown_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<TokenModel> loginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn(
        serverClientId:
            dotenv.env['GOOGLE_SERVER_CLIENT_ID_${EnvConfig.suffix}'],
      ).signIn();
      if (googleUser == null) {
        throw const ServerException(
          message: 'Inicio de sesión con Google cancelado',
          code: 'google_cancelled',
        );
      }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw const ServerException(
          message:
              'No se pudo obtener el ID token de Google. Verifica que el serverClientId sea el Web Client ID correcto del proyecto Firebase.',
          code: 'google_no_id_token',
        );
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      return await _postSession();
    } on ServerException {
      rethrow;
    } on FirebaseAuthException catch (e, stackTrace) {
      throw ServerException(
        message: e.message ?? 'Error de autenticación con Google',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } on PlatformException catch (e, stackTrace) {
      throw ServerException(
        message:
            e.message ?? 'Error de plataforma durante autenticación con Google',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } on DioException catch (e, stackTrace) {
      throw ServerException(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        code: 'google_session_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ServerException(
        message: 'Error inesperado durante autenticación con Google',
        code: 'unknown_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<TokenModel> loginWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      return await _postSession();
    } on SignInWithAppleAuthorizationException catch (e, stackTrace) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const ServerException(
          message: 'Inicio de sesión con Apple cancelado',
          code: 'apple_cancelled',
        );
      }
      throw ServerException(
        message:
            'Error de autorización de Apple [code=${e.code.name}]: ${e.message}',
        code: 'apple_auth_error_${e.code.name}',
        originalError: e,
        stackTrace: stackTrace,
      );
    } on FirebaseAuthException catch (e, stackTrace) {
      throw ServerException(
        message: e.message ?? 'Error de autenticación con Apple',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } on DioException catch (e, stackTrace) {
      throw ServerException(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        code: 'apple_session_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    } on PlatformException catch (e, stackTrace) {
      throw ServerException(
        message:
            e.message ?? 'Error de plataforma durante autenticación con Apple',
        code: e.code,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ServerException(
        message: 'Error inesperado durante autenticación con Apple',
        code: 'unknown_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> checkEmailExists(String email) async {
    try {
      final response = await dio.post(
        ApiConstants.checkEmailExistsEndpoint,
        data: {'email': email},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['exists'] as bool;
      }
      throw ServerException(
        message: 'Error al verificar email',
        statusCode: response.statusCode,
        code: 'check_email_error',
      );
    } on DioException catch (e, stackTrace) {
      throw ServerException(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        code: 'check_email_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post(ApiConstants.logoutEndpoint, data: {});
    } on DioException catch (e) {
      // 401/403 son aceptables en logout: la sesión local se limpia igualmente
      if (e.response?.statusCode != 401 && e.response?.statusCode != 403) {
        rethrow;
      }
    } finally {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    }
  }

  @override
  Future<String> getTermsInfo() async {
    try {
      final response = await dio.get(ApiConstants.termsInfoEndpoint);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        return data['requiredVersion'] as String? ?? '1.0';
      }
      throw ServerException(
        message: 'Error al obtener información de Términos',
        statusCode: response.statusCode,
        code: 'terms_info_error',
      );
    } on DioException catch (e, stackTrace) {
      throw ServerException(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        code: 'terms_info_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> acceptTerms(String version) async {
    try {
      final response = await dio.post(
        ApiConstants.acceptTermsEndpoint,
        data: {'version': version},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          message: 'Error al aceptar Términos',
          statusCode: response.statusCode,
          code: 'accept_terms_error',
        );
      }
    } on DioException catch (e, stackTrace) {
      throw ServerException(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        code: 'accept_terms_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<LegalDocumentModel> getLegalDocument(String type, String lang) async {
    try {
      final response = await dio.get(
        '/legal/$type',
        queryParameters: {'lang': lang},
        options: Options(
          extra: CacheOptions(
            store: MemCacheStore(),
            policy: CachePolicy.forceCache,
            maxStale: const Duration(days: 7),
          ).toExtra(),
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 304) {
        return LegalDocumentModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw ServerException(
        message: 'Error al obtener documento legal',
        statusCode: response.statusCode,
        code: 'legal_document_error',
      );
    } on DioException catch (e, stackTrace) {
      throw ServerException(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        code: 'legal_document_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ServerException(
        message: 'Error inesperado al obtener documento legal',
        code: 'legal_document_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> createProfile(String firstName, String lastName) async {
    try {
      await dio.post(
        ApiConstants.createProfileEndpoint,
        data: {'first_name': firstName, 'last_name': lastName},
      );
    } on DioException catch (e, stackTrace) {
      throw ServerException(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        code: 'create_profile_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ServerException(
        message: 'Error inesperado al crear el perfil',
        code: 'create_profile_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> checkUserStatus() async {
    try {
      await dio.get(ApiConstants.myProfileEndpoint);
    } on DioException catch (e, stackTrace) {
      final responseCode = e.response?.data is Map
          ? (e.response!.data['code'] as String? ?? 'check_status_error')
          : 'check_status_error';
      throw ServerException(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        code: responseCode,
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is AppException) rethrow;
      throw ServerException(
        message: 'Error al verificar el estado del usuario',
        code: 'check_status_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
