// lib/core/error/error_handler.dart

import 'package:dio/dio.dart';
import 'package:wap_app/core/error/app_exception.dart';
import 'package:wap_app/core/error/failures.dart';

/// Handler centralizado para convertir excepciones en failures
class ErrorHandler {
  /// Convierte una excepción en un Failure
  static Failure handleException(Object error, [StackTrace? stackTrace]) {
    // Excepciones de la app
    if (error is ServerException) {
      return ServerFailure(
        message: error.message,
        statusCode: error.statusCode,
        code: error.code,
      );
    }

    if (error is AuthenticationException) {
      return AuthenticationFailure(message: error.message, code: error.code);
    }

    if (error is ValidationException) {
      return ValidationFailure(
        message: error.message,
        fieldErrors: error.fieldErrors,
        code: error.code,
      );
    }

    if (error is NetworkException) {
      return NetworkFailure(
        message: error.message,
        code: error.code ?? 'network_error',
      );
    }

    if (error is LocationException) {
      return LocationFailure(
        message: error.message,
        code: _getLocationErrorCode(error.errorType),
      );
    }

    if (error is StorageException) {
      return CacheFailure(message: error.message, code: error.code);
    }

    if (error is PermissionException) {
      return PermissionFailure(
        message: error.message,
        permission: error.permission,
        code: error.code,
      );
    }

    if (error is TimeoutException) {
      return const NetworkFailure(
        message: 'La solicitud tardó demasiado tiempo',
        code: 'timeout',
      );
    }

    // Excepciones de Dio
    if (error is DioException) {
      return _handleDioException(error);
    }

    // Excepción desconocida
    return UnknownFailure(message: error.toString());
  }

  /// Maneja errores de Dio específicamente
  static Failure _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          message: 'Tiempo de espera agotado',
          code: 'timeout',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return const NetworkFailure(
          message: 'Solicitud cancelada',
          code: 'cancelled',
        );

      case DioExceptionType.connectionError:
        return const NetworkFailure(
          message: 'Error de conexión. Verifica tu internet.',
          code: 'no_internet',
        );

      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          message: 'Certificado de seguridad inválido',
          code: 'bad_certificate',
        );

      case DioExceptionType.unknown:
        return NetworkFailure(
          message: error.message ?? 'Error de red desconocido',
          code: 'unknown',
        );
    }
  }

  /// Maneja respuestas HTTP con error
  static Failure _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    String message = 'Error del servidor';
    String? code;
    Map<String, List<String>>? fieldErrors;

    // Intentar extraer el mensaje del backend
    if (responseData is Map<String, dynamic>) {
      // NestJS suele enviar {message: string | string[], error: string, statusCode: number}
      final backendMessage = responseData['message'];

      if (backendMessage is String) {
        message = backendMessage;
      } else if (backendMessage is List) {
        // Errores de validación de class-validator
        message = 'Errores de validación';
        fieldErrors = _parseValidationErrors(backendMessage);
      }

      code = responseData['error'] as String?;
    }

    // Casos especiales por código de estado
    if (statusCode == 401) {
      return AuthenticationFailure(
        message: message.isEmpty ? 'No autorizado' : message,
        code: code ?? 'unauthorized',
      );
    }

    if (statusCode == 400 && fieldErrors != null) {
      return ValidationFailure(
        message: message,
        fieldErrors: fieldErrors,
        code: code ?? 'validation_error',
      );
    }

    return ServerFailure(message: message, statusCode: statusCode, code: code);
  }

  /// Parsea errores de validación del backend
  static Map<String, List<String>> _parseValidationErrors(
    List<dynamic> errors,
  ) {
    final Map<String, List<String>> fieldErrors = {};

    for (final error in errors) {
      if (error is String) {
        // Si es un string simple, lo asignamos a un campo genérico
        fieldErrors.putIfAbsent('general', () => []).add(error);
      } else if (error is Map) {
        // Si es un objeto con estructura {field: string, message: string}
        final field = error['field'] as String? ?? 'general';
        final message = error['message'] as String? ?? error.toString();
        fieldErrors.putIfAbsent(field, () => []).add(message);
      }
    }

    return fieldErrors;
  }

  /// Obtiene el código de error para LocationException
  static String _getLocationErrorCode(LocationErrorType type) {
    switch (type) {
      case LocationErrorType.serviceDisabled:
        return 'service_disabled';
      case LocationErrorType.permissionDenied:
        return 'permission_denied';
      case LocationErrorType.permissionDeniedForever:
        return 'permission_denied_forever';
      case LocationErrorType.positionUnavailable:
        return 'position_unavailable';
    }
  }
}
