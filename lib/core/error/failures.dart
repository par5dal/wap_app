// lib/core/error/failures.dart

import 'package:equatable/equatable.dart';

/// Failure base abstracta
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];

  /// Método helper para obtener un mensaje user-friendly
  String get userMessage => message;
}

/// Failure de red/servidor
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({required super.message, this.statusCode, super.code});

  @override
  List<Object?> get props => [message, statusCode, code];

  @override
  String get userMessage {
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return 'Solicitud incorrecta. Por favor, verifica los datos.';
        case 401:
          return 'Sesión expirada. Por favor, inicia sesión nuevamente.';
        case 403:
          return 'No tienes permisos para realizar esta acción.';
        case 404:
          return 'El recurso solicitado no fue encontrado.';
        case 500:
          return 'Error del servidor. Por favor, intenta más tarde.';
        case 503:
          return 'Servicio no disponible. Por favor, intenta más tarde.';
        default:
          return message;
      }
    }
    return message;
  }
}

/// Failure de validación
class ValidationFailure extends Failure {
  final Map<String, List<String>> fieldErrors;

  const ValidationFailure({
    required super.message,
    required this.fieldErrors,
    super.code,
  });

  @override
  List<Object?> get props => [message, fieldErrors, code];

  /// Obtener el primer error de un campo específico
  String? getFieldError(String fieldName) {
    return fieldErrors[fieldName]?.first;
  }

  /// Obtener todos los errores de todos los campos
  String getAllErrors() {
    return fieldErrors.entries
        .map((entry) => '${entry.key}: ${entry.value.join(", ")}')
        .join('\n');
  }
}

/// Failure de autenticación
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required super.message, super.code});

  @override
  String get userMessage {
    if (code == 'invalid_credentials') {
      return 'Email o contraseña incorrectos.';
    } else if (code == 'email_already_exists') {
      return 'Este email ya está registrado.';
    } else if (code == 'session_expired') {
      return 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.';
    }
    return message;
  }
}

/// Failure de red (sin conexión, timeout, etc.)
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});

  @override
  String get userMessage {
    if (code == 'no_internet') {
      return 'Sin conexión a internet. Por favor, verifica tu conexión.';
    } else if (code == 'timeout') {
      return 'La solicitud tardó demasiado tiempo. Por favor, intenta nuevamente.';
    }
    return 'Error de conexión. Por favor, verifica tu internet.';
  }
}

/// Failure de caché/almacenamiento
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});

  @override
  String get userMessage => 'Error al acceder al almacenamiento local.';
}

/// Failure de ubicación
class LocationFailure extends Failure {
  const LocationFailure({required super.message, super.code});

  @override
  String get userMessage {
    if (code == 'service_disabled') {
      return 'Los servicios de ubicación están desactivados.';
    } else if (code == 'permission_denied') {
      return 'Permisos de ubicación denegados.';
    } else if (code == 'permission_denied_forever') {
      return 'Permisos de ubicación permanentemente denegados. Actívalos en ajustes.';
    }
    return message;
  }
}

/// Failure de permisos
class PermissionFailure extends Failure {
  final String permission;

  const PermissionFailure({
    required super.message,
    required this.permission,
    super.code,
  });

  @override
  List<Object?> get props => [message, permission, code];

  @override
  String get userMessage =>
      'Se requiere permiso de $permission para continuar.';
}

/// Failure desconocido
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Ha ocurrido un error inesperado.',
    super.code,
  });

  @override
  String get userMessage =>
      'Ha ocurrido un error inesperado. Por favor, intenta nuevamente.';
}
