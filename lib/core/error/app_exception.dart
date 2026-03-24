// lib/core/error/app_exception.dart

/// Excepción base de la aplicación
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'AppException(message: $message, code: $code)';
  }
}

/// Excepción de red
class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException({
    required super.message,
    super.code,
    this.statusCode,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    return 'NetworkException(message: $message, statusCode: $statusCode, code: $code)';
  }
}

/// Excepción de autenticación
class AuthenticationException extends AppException {
  const AuthenticationException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Excepción de validación (errores de formulario)
class ValidationException extends AppException {
  final Map<String, List<String>> fieldErrors;

  const ValidationException({
    required super.message,
    required this.fieldErrors,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    return 'ValidationException(message: $message, errors: $fieldErrors)';
  }
}

/// Excepción de timeout
class TimeoutException extends AppException {
  final Duration timeout;

  const TimeoutException({
    required super.message,
    required this.timeout,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Excepción de permisos
class PermissionException extends AppException {
  final String permission;

  const PermissionException({
    required super.message,
    required this.permission,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Excepción de caché/almacenamiento
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Excepción de ubicación
class LocationException extends AppException {
  final LocationErrorType errorType;

  const LocationException({
    required super.message,
    required this.errorType,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

enum LocationErrorType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  positionUnavailable,
}

/// Excepción de servidor (errores del backend)
class ServerException extends AppException {
  final int? statusCode;
  final Map<String, dynamic>? responseData;

  const ServerException({
    required super.message,
    this.statusCode,
    this.responseData,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() {
    return 'ServerException(message: $message, statusCode: $statusCode, code: $code)';
  }
}

/// Excepción desconocida
class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}
