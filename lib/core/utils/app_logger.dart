// lib/core/utils/app_logger.dart

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Log de debug (solo en desarrollo)
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log de información
  static void info(String message, [Map<String, dynamic>? data]) {
    _logger.i(message, error: data);
  }

  /// Log de advertencia
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);

    // En producción, enviar warnings importantes a Sentry
    if (kReleaseMode && error != null) {
      Sentry.captureMessage(message, level: SentryLevel.warning);
    }
  }

  /// Log de error
  static void error(String message, dynamic error, [StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);

    // Enviar a Sentry en producción
    if (kReleaseMode) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({'message': message}),
      );
    }
  }

  /// Log de evento (analytics)
  static void event(String eventName, [Map<String, dynamic>? parameters]) {
    if (kDebugMode) {
      _logger.i('📊 EVENT: $eventName', error: parameters);
    }
    // Aquí puedes integrar con Firebase Analytics, Mixpanel, etc.
  }

  /// Log de navegación
  static void navigation(String from, String to) {
    if (kDebugMode) {
      _logger.i('🗺️ NAVIGATION: $from → $to');
    }
  }

  /// Log de network request
  static void network(String method, String url, {int? statusCode}) {
    if (kDebugMode) {
      final emoji = statusCode != null && statusCode >= 200 && statusCode < 300
          ? '✅'
          : '❌';
      _logger.i('$emoji NETWORK: $method $url (${statusCode ?? "pending"})');
    }
  }
}
