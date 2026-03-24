// lib/core/network/dio_interceptor.dart

import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wap_app/core/constants/api_constants.dart';
import 'package:wap_app/core/services/auth_token_service.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/presentation/bloc/app/app_bloc.dart';

class DioInterceptor extends Interceptor {
  final Dio dio;
  final FlutterSecureStorage secureStorage;
  final AppBloc appBloc;
  final AuthTokenService tokenService;

  // Completer usado como mutex para el refresh proactivo.
  // Si otra petición llega mientras se refresca, espera el resultado
  // en lugar de continuar sin token (lo que causaba isFollowing: false).
  Completer<String?>? _proactiveRefreshCompleter;

  DioInterceptor({
    required this.dio,
    required this.secureStorage,
    required this.appBloc,
    required this.tokenService,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 🌍 Añadir header de idioma para internacionalización
    // Obtener el locale del dispositivo (formato: es_ES, en_US)
    final locale = Platform.localeName; // ej: 'es_ES'
    final languageCode = locale.split('_').first; // ej: 'es'
    options.headers['Accept-Language'] = locale.replaceAll('_', '-'); // 'es-ES'
    options.headers['x-lang'] = languageCode; // 'es'

    // Lista de endpoints que NO requieren autenticación (públicos)
    final publicEndpoints = [
      // Auth endpoints
      ApiConstants.loginEndpoint,
      ApiConstants.registerEndpoint,
      ApiConstants.googleGetUrlEndpoint,
      ApiConstants.googleCallbackEndpoint,
      ApiConstants.appleGetUrlEndpoint,
      ApiConstants.appleCallbackEndpoint,
      ApiConstants.checkEmailExistsEndpoint,
    ];

    // Lista de prefijos de rutas públicas (eventos públicos)
    final publicPathPrefixes = [
      '/events', // GET /events (lista paginada)
      '/categories', // GET /categories
      // Nota: /promoters/:id NO está aquí. Aunque el endpoint es público desde
      // el punto de vista del servidor, necesita el token para devolver
      // isFollowing correctamente. Al clasificarlo como privado, el interceptor
      // hará un refresh proactivo si es necesario antes de enviar la petición.
    ];

    // Lista de rutas que NO son públicas aunque empiecen con prefijos públicos
    final privateEndpoints = [
      '/events/favorites', // Favoritos del usuario
      '/events/attended', // Eventos a los que ha asistido el usuario
      '/events/created', // Eventos creados por el usuario
      '/promoters/following/list', // Promotores que sigue el usuario
    ];

    // Lista de patrones de endpoints privados (que requieren autenticación)
    final privateEndpointPatterns = [
      RegExp(r'^/events/[^/]+/favorite$'), // POST/DELETE /events/:id/favorite
      RegExp(r'^/promoters/[^/]+/follow$'), // POST/DELETE /promoters/:id/follow
    ];

    // Obtener solo el path sin query parameters
    final pathWithoutQuery = options.path.split('?').first;

    // Verificar si el path es público
    final isPublic =
        publicEndpoints.contains(pathWithoutQuery) ||
        (publicPathPrefixes.any(
              (prefix) => pathWithoutQuery.startsWith(prefix),
            ) &&
            !privateEndpoints.contains(pathWithoutQuery) &&
            !privateEndpointPatterns.any(
              (pattern) => pattern.hasMatch(pathWithoutQuery),
            ));

    // Si el endpoint NO es público, añadir access token
    if (!isPublic) {
      // Todos los endpoints protegidos (incluido logout) usan el accessToken en memoria
      var accessToken = tokenService.accessToken;

      // Refresh proactivo: si no hay accessToken en memoria pero sí refreshToken
      // en disco (ej. tras hot restart o relanzar la app), obtener uno nuevo
      // antes de hacer la petición para evitar el round-trip 401 → refresh → retry.
      if (accessToken == null) {
        if (_proactiveRefreshCompleter != null) {
          // Otro request ya está haciendo el refresh: esperar su resultado.
          accessToken = await _proactiveRefreshCompleter!.future;
        } else {
          final storedRefresh = await secureStorage.read(key: 'refreshToken');
          if (storedRefresh != null) {
            // Double-checked locking: entre el primer check y el await de
            // secureStorage.read() otro request pudo haber creado ya el
            // Completer. Si es así, esperamos su resultado en lugar de lanzar
            // un segundo refresh (que además fallaría con token rotado).
            if (_proactiveRefreshCompleter != null) {
              accessToken = await _proactiveRefreshCompleter!.future;
            } else {
              final completer = Completer<String?>();
              _proactiveRefreshCompleter = completer;
              try {
                final refreshDio = Dio(dio.options);
                final response = await refreshDio.post(
                  ApiConstants.refreshEndpoint,
                  data: {'refreshToken': storedRefresh},
                  options: Options(
                    headers: {'Content-Type': 'application/json'},
                    validateStatus: (status) => status! < 500,
                  ),
                );
                if (response.statusCode == 200 || response.statusCode == 201) {
                  final newAccessToken = response.data['accessToken'] as String;
                  final newRefreshToken =
                      response.data['refreshToken'] as String;
                  tokenService.setAccessToken(newAccessToken);
                  await secureStorage.write(
                    key: 'refreshToken',
                    value: newRefreshToken,
                  );
                  accessToken = newAccessToken;
                  completer.complete(newAccessToken);
                  AppLogger.info('🔄 Proactive token refresh successful');
                } else if (response.statusCode == 401) {
                  completer.complete(null);
                  await _logout();
                } else {
                  completer.complete(null);
                }
              } catch (e) {
                AppLogger.warning('⚠️ Proactive refresh failed: $e');
                completer.complete(null);
              } finally {
                _proactiveRefreshCompleter = null;
              }
            }
          }
        }
      }

      if (kDebugMode) {
        AppLogger.info(
          '🔑 onRequest: Adding access token to $pathWithoutQuery (token exists: ${accessToken != null})',
        );
      }
      if (accessToken != null) {
        if (kDebugMode) {
          AppLogger.info(
            '  Token (primeros 20 chars): ${accessToken.substring(0, 20)}...',
          );
        }
        options.headers['Authorization'] = 'Bearer $accessToken';
      } else {
        AppLogger.warning(
          '⚠️ No access token available for $pathWithoutQuery, continuing without auth',
        );
      }
    } else {
      // Endpoint público: enviar token si está disponible (auth opcional).
      // El backend devuelve datos personalizados (is_favorite, is_following, etc.)
      // cuando recibe un token válido, aunque el endpoint no lo requiera.
      //
      // EXCEPCIÓN: /events/promoter/:id no debe enviar token aunque esté disponible.
      // El backend filtra los eventos de promotores bloqueados cuando recibe auth,
      // y en la página de perfil del promotor el usuario SÍ debe poder ver sus eventos
      // aunque lo tenga bloqueado.
      final isPromoterEventsPath = pathWithoutQuery.startsWith(
        '/events/promoter/',
      );

      if (!isPromoterEventsPath) {
        final accessToken = tokenService.accessToken;
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
          if (kDebugMode) {
            AppLogger.info(
              '🌐 Public endpoint $pathWithoutQuery — token añadido (opcional)',
            );
          }
        } else {
          if (kDebugMode) {
            AppLogger.info(
              '🌐 Public endpoint $pathWithoutQuery — sin token (usuario no autenticado)',
            );
          }
        }
      } else {
        if (kDebugMode) {
          AppLogger.info(
            '🌐 Public endpoint $pathWithoutQuery — sin token (perfil de promotor, sin filtro de bloqueo)',
          );
        }
      }
    }
    return super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 🚫 Manejar 403 Forbidden (T&C no aceptados o cuenta suspendida)
    if (err.response?.statusCode == 403) {
      final data = err.response?.data;
      String? code;
      if (data is Map) {
        // El servidor devuelve {"code":"TERMS_NOT_ACCEPTED","message":"...","requiredVersion":"..."}
        // Leer el campo 'code' directamente del body de la respuesta.
        final codeValue = data['code'];
        if (codeValue is String) {
          code = codeValue;
        } else {
          // Fallback para formatos anidados { message: { code: "..." } }
          final msg = data['message'];
          if (msg is Map) {
            code = msg['code'] as String?;
          }
        }
      }
      if (code == 'TERMS_NOT_ACCEPTED') {
        // Evitar re-encolar el evento si ya estamos en estado termsNotAccepted
        // (p.ej. cuando se llama a logout y el servidor devuelve 403).
        if (appBloc.state.status != AuthStatus.termsNotAccepted) {
          final responseData = err.response!.data as Map;
          final version = responseData['requiredVersion'] as String? ?? '';
          appBloc.add(AppTermsNotAccepted(requiredVersion: version));
        }
      } else if (code == 'ACCOUNT_SUSPENDED') {
        final responseData = err.response!.data as Map;
        final reason = responseData['reason'] as String?;
        appBloc.add(AppAccountSuspended(reason: reason));
      }
      return handler.reject(err);
    }

    // ⚡ Manejar Rate Limiting (429 Too Many Requests)
    if (err.response?.statusCode == 429) {
      final retryAfterHeader = err.response?.headers['Retry-After'];
      final retryAfterSeconds =
          retryAfterHeader != null && retryAfterHeader.isNotEmpty
          ? int.tryParse(retryAfterHeader.first) ?? 60
          : 60;

      if (kDebugMode) {
        AppLogger.warning(
          '⚠️ Rate limit exceeded (429), retry after ${retryAfterSeconds}s',
        );
      }

      // Reintentar automáticamente después del delay
      await Future.delayed(Duration(seconds: retryAfterSeconds));

      try {
        final retryResponse = await dio.fetch(err.requestOptions);
        return handler.resolve(retryResponse);
      } catch (retryError) {
        // Si falla el retry, rechazar el error original
        return handler.reject(err);
      }
    }

    // Si el error es un 401 Unauthorized y NO es de la ruta de refresh o logout...
    if (err.response?.statusCode == 401 &&
        err.requestOptions.path != ApiConstants.refreshEndpoint &&
        err.requestOptions.path != ApiConstants.logoutEndpoint) {
      // 🔍 LOG: Información sobre el 401
      if (kDebugMode) {
        AppLogger.warning('❌ 401 Unauthorized for ${err.requestOptions.path}');
        AppLogger.info('🔍 Error response: ${err.response?.data}');
      }

      final refreshToken = await secureStorage.read(key: 'refreshToken');

      // 🔍 LOG: Verificar qué refresh token tenemos guardado (solo en desarrollo)
      if (kDebugMode) {
        if (refreshToken != null) {
          AppLogger.info(
            '📖 Reading refresh token from storage (primeros 20 chars): ${refreshToken.substring(0, 20)}...',
          );
        } else {
          AppLogger.warning('⚠️ No refresh token found in storage!');
        }
      }

      if (refreshToken != null) {
        // Si ya hay un refresh en proceso (Completer activo), esperar su resultado.
        if (_proactiveRefreshCompleter != null) {
          AppLogger.info('⏳ Refresh already in progress, waiting...');
          final newAccessToken = await _proactiveRefreshCompleter!.future;
          if (newAccessToken != null) {
            if (kDebugMode) {
              AppLogger.info('🔄 Retrying request with refreshed token');
            }
            err.requestOptions.headers['Authorization'] =
                'Bearer $newAccessToken';
            return handler.resolve(await dio.fetch(err.requestOptions));
          } else {
            AppLogger.warning('⚠️ No access token after refresh, logging out');
            await _logout();
            return handler.reject(err);
          }
        }

        final completer = Completer<String?>();
        _proactiveRefreshCompleter = completer;
        try {
          if (kDebugMode) {
            AppLogger.info('🔄 Attempting token refresh...');
            AppLogger.info(
              '📤 Refresh token (primeros 20 chars): ${refreshToken.substring(0, 20)}...',
            );
          }

          // ⚠️ CRÍTICO: Crear una nueva instancia de Dio SIN interceptors
          // para evitar loops infinitos y conflictos con onRequest
          final refreshDio = Dio(dio.options);

          if (kDebugMode) {
            AppLogger.info(
              '🌐 Making refresh request to: ${dio.options.baseUrl}${ApiConstants.refreshEndpoint}',
            );
            AppLogger.info(
              '📋 Body: refreshToken ${refreshToken.substring(0, 20)}...',
            );
          }

          // ⚠️ IMPORTANTE: El refresh token va en el BODY (no en header)
          final response = await refreshDio.post(
            ApiConstants.refreshEndpoint,
            data: {'refreshToken': refreshToken},
            options: Options(
              headers: {'Content-Type': 'application/json'},
              validateStatus: (status) =>
                  status! < 500, // No lanzar excepción para 401
            ),
          );

          if (kDebugMode) {
            AppLogger.info(
              '📨 Refresh response status: ${response.statusCode}',
            );
            AppLogger.info('📨 Refresh response data: ${response.data}');
          }

          if (response.statusCode == 200 || response.statusCode == 201) {
            // ✅ El backend retorna accessToken y refreshToken (camelCase)
            final newAccessToken = response.data['accessToken'] as String;
            final newRefreshToken = response.data['refreshToken'] as String;

            // 🔍 LOG: Tokens recibidos (solo en desarrollo)
            if (kDebugMode) {
              AppLogger.info('✅ Token refresh successful!');
              AppLogger.info(
                '📥 New access token (primeros 20 chars): ${newAccessToken.substring(0, 20)}...',
              );
              AppLogger.info(
                '📥 New refresh token (primeros 20 chars): ${newRefreshToken.substring(0, 20)}...',
              );
              AppLogger.info(
                '🔄 ¿Tokens cambiaron? Access: ${refreshToken.substring(0, 20) != newAccessToken.substring(0, 20)}, Refresh: ${refreshToken.substring(0, 20) != newRefreshToken.substring(0, 20)}',
              );
            }

            // ✅ Guardar tokens: accessToken en memoria, refreshToken en disco
            tokenService.setAccessToken(newAccessToken);
            await secureStorage.write(
              key: 'refreshToken',
              value: newRefreshToken,
            );
            if (kDebugMode) {
              AppLogger.info(
                '💾 New refresh token saved; access token updated in memory',
              );
            }

            completer.complete(newAccessToken);
            _proactiveRefreshCompleter = null;

            // Actualizar el header de la request original con el nuevo access token
            err.requestOptions.headers['Authorization'] =
                'Bearer $newAccessToken';

            // Reintentar la request original con el nuevo token
            return handler.resolve(await dio.fetch(err.requestOptions));
          } else if (response.statusCode == 401) {
            completer.complete(null);
            _proactiveRefreshCompleter = null;
            // SOLO cerrar sesión si el refresh token es inválido (401)
            AppLogger.warning('❌ Refresh token rejected (401) - logging out');
            await _logout();
            return handler.reject(err);
          } else {
            completer.complete(null);
            _proactiveRefreshCompleter = null;
            // Otro código de error del refresh - no cerrar sesión, solo propagar error
            return handler.reject(err);
          }
        } on DioException catch (refreshError) {
          completer.complete(null);
          _proactiveRefreshCompleter = null;
          // Si el error del refresh es 401, cerrar sesión
          if (refreshError.response?.statusCode == 401) {
            AppLogger.warning(
              '❌ Refresh token rejected with DioException (401) - logging out',
            );
            await _logout();
            return handler.reject(err);
          }
          // Para otros errores (network, timeout, etc.) - NO cerrar sesión
          // El usuario podría estar sin internet temporalmente
          AppLogger.error(
            'Refresh error (not 401)',
            refreshError,
            StackTrace.current,
          );
          return handler.reject(err);
        } catch (e) {
          completer.complete(null);
          _proactiveRefreshCompleter = null;
          // Error inesperado - NO cerrar sesión automáticamente
          // Podría ser un error de parsing u otro problema temporal
          AppLogger.error('Unexpected refresh error', e, StackTrace.current);
          return handler.reject(err);
        }
      }
      // Si no hay refresh token, NO cerramos sesión automáticamente
      // Dejamos que la app maneje el error de autenticación
      return handler.reject(err);
    }

    // Si es un error 401 en logout, simplemente limpiamos los tokens localmente
    if (err.response?.statusCode == 401 &&
        err.requestOptions.path == ApiConstants.logoutEndpoint) {
      await _logout();
      return handler.next(err);
    }

    return super.onError(err, handler);
  }

  Future<void> _logout() async {
    tokenService.clear();
    await secureStorage.delete(key: 'refreshToken');
    // Por compatibilidad con versiones anteriores
    await secureStorage.delete(key: 'accessToken');
    // Disparar evento al AppBloc
    appBloc.add(const AppAuthStatusChanged(AuthStatus.unauthenticated));
  }
}
