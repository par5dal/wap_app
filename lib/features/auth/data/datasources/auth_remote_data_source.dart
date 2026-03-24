// lib/features/auth/data/datasources/auth_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wap_app/core/constants/api_constants.dart';
import 'package:wap_app/core/error/app_exception.dart';
import 'package:wap_app/core/services/auth_token_service.dart';
import 'package:wap_app/features/auth/data/models/token_model.dart';
import 'package:wap_app/features/auth/data/models/legal_document_model.dart';

abstract class AuthRemoteDataSource {
  /// Login con email y contraseña. Persiste refreshToken; guarda accessToken en memoria.
  Future<TokenModel> login(String email, String password);

  /// Registro con email y contraseña + nombre.
  /// Internamente llama a POST /users/profile con los datos del perfil.
  Future<TokenModel> register(
    String email,
    String password,
    String firstName,
    String lastName,
  );

  /// Paso 1 del flujo OAuth Google: obtiene la URL de autorización del backend.
  Future<String> getGoogleAuthUrl({required String lang, String role});

  /// Paso 2 del flujo OAuth Google: intercambia los tokens de Supabase con el backend.
  Future<TokenModel> loginWithGoogleCallback({
    required String supabaseAccessToken,
    required String supabaseRefreshToken,
    required String lang,
    String? role,
  });

  /// Paso 1 del flujo OAuth Apple: obtiene la URL de autorización del backend.
  Future<String> getAppleAuthUrl({required String lang, String role});

  /// Paso 2 del flujo OAuth Apple: intercambia los tokens de Supabase con el backend.
  Future<TokenModel> loginWithAppleCallback({
    required String supabaseAccessToken,
    required String supabaseRefreshToken,
    required String lang,
    String? role,
  });

  Future<bool> checkEmailExists(String email);

  /// Persiste refreshToken en disco; almacena accessToken en [AuthTokenService].
  Future<void> saveTokens(TokenModel tokens);

  Future<String?> getRefreshToken();

  Future<void> logout();

  /// Obtiene la versión de los Términos y Condiciones requerida por el backend.
  Future<String> getTermsInfo();

  /// Acepta los Términos y Condiciones de la versión indicada.
  Future<void> acceptTerms(String version);

  /// Crea el perfil del usuario tras aceptar los T&C.
  Future<void> createProfile(String firstName, String lastName);

  /// Comprueba el estado del usuario en el servidor (T&C aceptados, perfil, etc.).
  /// Lanza [ServerException] con code='TERMS_NOT_ACCEPTED' si los T&C no están aceptados.
  Future<void> checkUserStatus();

  /// Obtiene el documento legal (términos o privacidad) del backend.
  /// [type] puede ser 'terms' o 'privacy'
  /// [lang] puede ser 'es', 'en', 'pt', etc.
  Future<LegalDocumentModel> getLegalDocument(String type, String lang);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;
  final AuthTokenService tokenService;

  AuthRemoteDataSourceImpl({
    required this.dio,
    required this.secureStorage,
    required this.tokenService,
  });

  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null && e.response!.data is Map) {
      final message = e.response!.data['message'];

      if (message is List) {
        return message.join('\n');
      }
      if (message is String) {
        return message;
      }
    }
    return 'Error de comunicación con el servidor.';
  }

  @override
  Future<TokenModel> login(String email, String password) async {
    try {
      final response = await dio.post(
        ApiConstants.loginEndpoint,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final tokenModel = TokenModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        await saveTokens(tokenModel);
        return tokenModel;
      } else {
        throw ServerException(
          message: 'Error inesperado del servidor',
          statusCode: response.statusCode,
          code: 'unexpected_error',
        );
      }
    } on DioException catch (e, stackTrace) {
      final errorMessage = _extractErrorMessage(e);
      final statusCode = e.response?.statusCode;

      // Si es 401, lanzar AuthenticationException
      if (statusCode == 401) {
        throw AuthenticationException(
          message: errorMessage,
          code: 'invalid_credentials',
          originalError: e,
          stackTrace: stackTrace,
        );
      }

      throw ServerException(
        message: errorMessage,
        statusCode: statusCode,
        code: 'server_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
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
    String lastName,
  ) async {
    try {
      // 1. Crear cuenta
      final response = await dio.post(
        ApiConstants.registerEndpoint,
        data: {'email': email, 'password': password, 'role': 'CONSUMER'},
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw ServerException(
          message: 'Error inesperado al registrar',
          statusCode: response.statusCode,
          code: 'unexpected_error',
        );
      }

      final token = TokenModel.fromJson(response.data as Map<String, dynamic>);
      await saveTokens(token);

      // 2. Crear perfil del usuario (ya no está bloqueado por T&C)
      try {
        await dio.post(
          ApiConstants.createProfileEndpoint,
          data: {'first_name': firstName, 'last_name': lastName},
        );
      } on DioException {
        // El perfil es opcional en este punto: si falla, el usuario puede
        // completarlo más tarde. No bloqueamos el registro.
      }

      return token;
    } on DioException catch (e, stackTrace) {
      throw ServerException(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        code: 'register_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Error inesperado durante el registro',
        code: 'unknown_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ─── GOOGLE OAUTH ─────────────────────────────────────────────────────────

  @override
  Future<String> getGoogleAuthUrl({
    required String lang,
    String role = 'CONSUMER',
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.googleGetUrlEndpoint,
        queryParameters: {
          'lang': lang,
          'role': role,
          // wap:// directo: Supabase emite HTTP 302 a wap://auth/callback tras autenticar.
          // Es un redirect server-side, no JS → ningún browser puede bloquearlo.
          // Requiere que wap://auth/callback esté registrado en Supabase → Auth → Redirect URLs.
          'redirect_to': 'wap://auth/callback?provider=google',
          'prompt': 'select_account', // forzar selector de cuenta de Google
        },
        // noCache = fuerza petición fresca, nunca lee ni guarda caché.
        // Evita que DioCacheInterceptor envíe If-None-Match y reciba un 304 sin body.
        options: Options(
          extra: CacheOptions(
            store: MemCacheStore(),
            policy: CachePolicy.noCache,
          ).toExtra(),
        ),
      );

      if (response.statusCode == 200) {
        final url = response.data['url'] as String?;
        if (url == null || url.isEmpty) {
          throw ServerException(
            message: 'El backend no devolvió URL de autorización',
            code: 'google_url_error',
          );
        }
        // Añadir prompt=select_account para forzar el selector de cuentas
        // cada vez que el usuario inicia sesión (evita que Google auto-seleccione
        // la última cuenta usada en el Chrome Custom Tabs).
        final uri = Uri.parse(url);
        final promptUrl = uri.queryParameters.containsKey('prompt')
            ? url
            : uri
                  .replace(
                    queryParameters: {
                      ...uri.queryParameters,
                      'prompt': 'select_account',
                    },
                  )
                  .toString();
        return promptUrl;
      }
      throw ServerException(
        message: 'Error al obtener URL de Google',
        statusCode: response.statusCode,
        code: 'google_url_error',
      );
    } on DioException catch (e, stackTrace) {
      throw ServerException(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        code: 'google_url_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<TokenModel> loginWithGoogleCallback({
    required String supabaseAccessToken,
    required String supabaseRefreshToken,
    required String lang,
    String? role,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.googleCallbackEndpoint,
        data: {
          'accessToken': supabaseAccessToken,
          'refreshToken': supabaseRefreshToken,
          'lang': lang,
          if (role != null) 'role': role,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = TokenModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        await saveTokens(token);
        return token;
      }
      throw ServerException(
        message: 'Error inesperado del servidor',
        statusCode: response.statusCode,
        code: 'google_callback_error',
      );
    } on DioException catch (e, stackTrace) {
      throw ServerException(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        code: 'google_callback_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Error inesperado durante autenticación con Google',
        code: 'unknown_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ─── APPLE OAUTH ─────────────────────────────────────────────────────────

  @override
  Future<String> getAppleAuthUrl({
    required String lang,
    String role = 'CONSUMER',
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.appleGetUrlEndpoint,
        queryParameters: {
          'lang': lang,
          'role': role,
          // provider=apple en el redirect para que el callback sepa el proveedor
          'redirect_to': 'wap://auth/callback?provider=apple',
        },
        options: Options(
          extra: CacheOptions(
            store: MemCacheStore(),
            policy: CachePolicy.noCache,
          ).toExtra(),
        ),
      );

      if (response.statusCode == 200) {
        final url = response.data['url'] as String?;
        if (url == null || url.isEmpty) {
          throw ServerException(
            message: 'El backend no devolvió URL de autorización de Apple',
            code: 'apple_url_error',
          );
        }
        return url;
      }
      throw ServerException(
        message: 'Error al obtener URL de Apple',
        statusCode: response.statusCode,
        code: 'apple_url_error',
      );
    } on DioException catch (e, stackTrace) {
      throw ServerException(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        code: 'apple_url_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<TokenModel> loginWithAppleCallback({
    required String supabaseAccessToken,
    required String supabaseRefreshToken,
    required String lang,
    String? role,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.appleCallbackEndpoint,
        data: {
          'accessToken': supabaseAccessToken,
          'refreshToken': supabaseRefreshToken,
          'lang': lang,
          if (role != null) 'role': role,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = TokenModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        await saveTokens(token);
        return token;
      }
      throw ServerException(
        message: 'Error inesperado del servidor',
        statusCode: response.statusCode,
        code: 'apple_callback_error',
      );
    } on DioException catch (e, stackTrace) {
      throw ServerException(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        code: 'apple_callback_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is ServerException) rethrow;
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
      } else {
        throw ServerException(
          message: 'Error al verificar email',
          statusCode: response.statusCode,
          code: 'check_email_error',
        );
      }
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
  Future<void> saveTokens(TokenModel tokens) async {
    // accessToken → solo en memoria (no persiste entre reinicios de la app)
    tokenService.setAccessToken(tokens.accessToken);

    // refreshToken → persiste en disco con flutter_secure_storage
    try {
      await secureStorage.write(
        key: 'refreshToken',
        value: tokens.refreshToken,
      );
    } catch (e, stackTrace) {
      throw StorageException(
        message: 'Error al guardar refresh token',
        code: 'token_save_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await secureStorage.read(key: 'refreshToken');
    } catch (e, stackTrace) {
      throw StorageException(
        message: 'Error al leer refresh token',
        code: 'token_read_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      // El DioInterceptor añade automáticamente el accessToken como Bearer.
      // Un 401 significa que el token ya expiró: no es un error crítico.
      // Un 403 TERMS_NOT_ACCEPTED también se ignora: el usuario está intentando
      // salir precisamente porque no acepta los T&C, la sesión local se limpia
      // igualmente en el bloque finally.
      await dio.post(ApiConstants.logoutEndpoint, data: {});
    } on DioException catch (e) {
      if (e.response?.statusCode != 401 && e.response?.statusCode != 403) {
        rethrow;
      }
    } finally {
      tokenService.clear();
      try {
        await secureStorage.delete(key: 'refreshToken');
        // Por compatibilidad con versiones anteriores que guardaban accessToken en disco
        await secureStorage.delete(key: 'accessToken');
      } catch (e, stackTrace) {
        throw StorageException(
          message: 'Error al limpiar tokens',
          code: 'token_clear_error',
          originalError: e,
          stackTrace: stackTrace,
        );
      }
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
      } else {
        throw ServerException(
          message: 'Error al obtener documento legal',
          statusCode: response.statusCode,
          code: 'legal_document_error',
        );
      }
    } on DioException catch (e, stackTrace) {
      throw ServerException(
        message: _extractErrorMessage(e),
        statusCode: e.response?.statusCode,
        code: 'legal_document_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
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
      throw ServerException(
        message: 'Error al verificar el estado del usuario',
        code: 'check_status_error',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
