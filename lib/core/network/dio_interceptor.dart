// lib/core/network/dio_interceptor.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wap_app/core/constants/api_constants.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/presentation/bloc/app/app_bloc.dart';

class DioInterceptor extends Interceptor {
  final Dio dio;
  final AppBloc appBloc;

  DioInterceptor({required this.dio, required this.appBloc});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final locale = Platform.localeName;
    final languageCode = locale.split('_').first;
    options.headers['Accept-Language'] = locale.replaceAll('_', '-');
    options.headers['x-lang'] = languageCode;

    final publicEndpoints = [
      ApiConstants.sessionEndpoint,
      ApiConstants.registerEndpoint,
      ApiConstants.checkEmailExistsEndpoint,
    ];

    final publicPathPrefixes = ['/events', '/categories'];
    final privateEndpoints = [
      '/events/favorites',
      '/events/attended',
      '/events/created',
      '/promoters/following/list',
    ];
    final privateEndpointPatterns = [
      RegExp(r'^/events/[^/]+/favorite$'),
      RegExp(r'^/promoters/[^/]+/follow$'),
    ];

    final pathWithoutQuery = options.path.split('?').first;
    final isPublic =
        publicEndpoints.contains(pathWithoutQuery) ||
        (publicPathPrefixes.any((p) => pathWithoutQuery.startsWith(p)) &&
            !privateEndpoints.contains(pathWithoutQuery) &&
            !privateEndpointPatterns.any((p) => p.hasMatch(pathWithoutQuery)));

    final user = FirebaseAuth.instance.currentUser;

    if (!isPublic) {
      if (user != null) {
        try {
          final idToken = await user.getIdToken();
          options.headers['Authorization'] = 'Bearer $idToken';
        } catch (e) {
          AppLogger.warning('âš ï¸ No se pudo obtener Firebase ID token: $e');
        }
      }
    } else {
      final isPromoterEventsPath = pathWithoutQuery.startsWith(
        '/events/promoter/',
      );
      if (!isPromoterEventsPath && user != null) {
        try {
          final idToken = await user.getIdToken();
          options.headers['Authorization'] = 'Bearer $idToken';
        } catch (_) {
          // token opcional en endpoints pÃºblicos
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
    if (err.response?.statusCode == 403) {
      final data = err.response?.data;
      String? code;
      if (data is Map) {
        final codeValue = data['code'];
        if (codeValue is String) {
          code = codeValue;
        } else {
          final msg = data['message'];
          if (msg is Map) code = msg['code'] as String?;
        }
      }
      if (code == 'TERMS_NOT_ACCEPTED') {
        if (appBloc.state.status != AuthStatus.termsNotAccepted) {
          final version =
              (err.response!.data as Map)['requiredVersion'] as String? ?? '';
          appBloc.add(AppTermsNotAccepted(requiredVersion: version));
        }
      } else if (code == 'ACCOUNT_SUSPENDED') {
        final reason = (err.response!.data as Map)['reason'] as String?;
        appBloc.add(AppAccountSuspended(reason: reason));
      }
      return handler.reject(err);
    }

    if (err.response?.statusCode == 429) {
      final retryAfterHeader = err.response?.headers['Retry-After'];
      final retryAfterSeconds =
          retryAfterHeader != null && retryAfterHeader.isNotEmpty
          ? int.tryParse(retryAfterHeader.first) ?? 60
          : 60;
      await Future.delayed(Duration(seconds: retryAfterSeconds));
      try {
        return handler.resolve(await dio.fetch(err.requestOptions));
      } catch (_) {
        return handler.reject(err);
      }
    }

    if (err.response?.statusCode == 401) {
      // Solo cerrar sesión si la petición llevaba un token de autenticación.
      // Un 401 en una petición sin token simplemente significa "se requiere auth",
      // no que la sesión haya expirado.
      final hadAuthHeader = err.requestOptions.headers.containsKey(
        'Authorization',
      );
      if (hadAuthHeader) {
        AppLogger.warning(
          '❌ 401 con token para ${err.requestOptions.path} – cerrando sesión',
        );
        await _signOut();
      } else {
        AppLogger.warning(
          '⚠️ 401 sin token para ${err.requestOptions.path} – ignorando',
        );
      }
      return handler.reject(err);
    }

    return super.onError(err, handler);
  }

  Future<void> _signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    appBloc.add(const AppAuthStatusChanged(AuthStatus.unauthenticated));
  }
}
