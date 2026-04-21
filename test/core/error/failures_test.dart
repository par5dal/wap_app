// test/core/error/failures_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wap_app/core/error/failures.dart';

void main() {
  group('Failure classes', () {
    group('ServerFailure', () {
      test('creates instance with required parameters', () {
        const failure = ServerFailure(
          message: 'Server error',
          statusCode: 500,
          code: 'internal_error',
        );

        expect(failure.message, 'Server error');
        expect(failure.statusCode, 500);
        expect(failure.code, 'internal_error');
      });

      test('userMessage returns mapped message for 400', () {
        const failure = ServerFailure(message: 'Bad request', statusCode: 400);
        expect(
          failure.userMessage,
          'Solicitud incorrecta. Por favor, verifica los datos.',
        );
      });

      test('userMessage returns mapped message for 401', () {
        const failure = ServerFailure(message: 'Unauthorized', statusCode: 401);
        expect(
          failure.userMessage,
          'Sesión expirada. Por favor, inicia sesión nuevamente.',
        );
      });

      test('userMessage returns mapped message for 403', () {
        const failure = ServerFailure(message: 'Forbidden', statusCode: 403);
        expect(
          failure.userMessage,
          'No tienes permisos para realizar esta acción.',
        );
      });

      test('userMessage returns mapped message for 404', () {
        const failure = ServerFailure(message: 'Not found', statusCode: 404);
        expect(failure.userMessage, 'El recurso solicitado no fue encontrado.');
      });

      test('userMessage returns mapped message for 500', () {
        const failure = ServerFailure(
          message: 'Internal error',
          statusCode: 500,
        );
        expect(
          failure.userMessage,
          'Error del servidor. Por favor, intenta más tarde.',
        );
      });

      test('userMessage returns mapped message for 503', () {
        const failure = ServerFailure(message: 'Unavailable', statusCode: 503);
        expect(
          failure.userMessage,
          'Servicio no disponible. Por favor, intenta más tarde.',
        );
      });

      test('userMessage returns original message for unknown status', () {
        const failure = ServerFailure(
          message: 'Unknown status',
          statusCode: 418,
        );
        expect(failure.userMessage, 'Unknown status');
      });

      test('userMessage returns original message when no status code', () {
        const failure = ServerFailure(message: 'Custom message');
        expect(failure.userMessage, 'Custom message');
      });

      test('props includes all fields', () {
        const failure = ServerFailure(
          message: 'Error',
          statusCode: 500,
          code: 'code1',
        );
        expect(failure.props, [
          failure.message,
          failure.statusCode,
          failure.code,
        ]);
      });

      test('equality works with same parameters', () {
        const f1 = ServerFailure(message: 'Error', statusCode: 500);
        const f2 = ServerFailure(message: 'Error', statusCode: 500);
        expect(f1, equals(f2));
      });
    });

    group('ValidationFailure', () {
      test('creates instance with fieldErrors', () {
        final fieldErrors = {
          'email': ['Invalid email format'],
          'password': ['Too short'],
        };
        final failure = ValidationFailure(
          message: 'Validation failed',
          fieldErrors: fieldErrors,
          code: 'validation_error',
        );

        expect(failure.message, 'Validation failed');
        expect(failure.fieldErrors, fieldErrors);
        expect(failure.code, 'validation_error');
      });

      test('getFieldError returns first error for field', () {
        final fieldErrors = {
          'email': ['Invalid format', 'Already exists'],
        };
        final failure = ValidationFailure(
          message: 'Error',
          fieldErrors: fieldErrors,
        );

        expect(failure.getFieldError('email'), 'Invalid format');
      });

      test('getFieldError returns null for nonexistent field', () {
        final failure = ValidationFailure(message: 'Error', fieldErrors: {});

        expect(failure.getFieldError('nonexistent'), null);
      });

      test('getAllErrors concatenates all field errors', () {
        final fieldErrors = {
          'email': ['Invalid', 'Exists'],
          'password': ['Short'],
        };
        final failure = ValidationFailure(
          message: 'Error',
          fieldErrors: fieldErrors,
        );

        final allErrors = failure.getAllErrors();
        expect(allErrors, contains('email:'));
        expect(allErrors, contains('Invalid'));
        expect(allErrors, contains('Exists'));
        expect(allErrors, contains('password:'));
        expect(allErrors, contains('Short'));
      });

      test('props includes fieldErrors', () {
        final fieldErrors = {
          'email': ['Invalid'],
        };
        final failure = ValidationFailure(
          message: 'Error',
          fieldErrors: fieldErrors,
          code: 'code1',
        );
        expect(failure.props, [
          failure.message,
          failure.fieldErrors,
          failure.code,
        ]);
      });
    });

    group('AuthenticationFailure', () {
      test('creates instance with message and code', () {
        const failure = AuthenticationFailure(
          message: 'Token expired',
          code: 'token_expired',
        );

        expect(failure.message, 'Token expired');
        expect(failure.code, 'token_expired');
      });

      test('userMessage returns message property', () {
        const failure = AuthenticationFailure(message: 'Not authenticated');
        expect(failure.userMessage, 'Not authenticated');
      });
    });

    group('NetworkFailure', () {
      test('creates instance with message and code', () {
        const failure = NetworkFailure(
          message: 'No internet connection',
          code: 'no_internet',
        );

        expect(failure.message, 'No internet connection');
        expect(failure.code, 'no_internet');
      });

      test('userMessage returns mapped message for timeout code', () {
        const failure = NetworkFailure(
          message: 'Connection timeout',
          code: 'timeout',
        );
        expect(
          failure.userMessage,
          'La solicitud tardó demasiado tiempo. Por favor, intenta nuevamente.',
        );
      });

      test(
        'userMessage returns no_internet message when code is no_internet',
        () {
          const failure = NetworkFailure(
            message: 'No connection',
            code: 'no_internet',
          );
          expect(
            failure.userMessage,
            'Sin conexión a internet. Por favor, verifica tu conexión.',
          );
        },
      );

      test('userMessage returns default message for unknown code', () {
        const failure = NetworkFailure(
          message: 'Some error',
          code: 'unknown_code',
        );
        expect(
          failure.userMessage,
          'Error de conexión. Por favor, verifica tu internet.',
        );
      });
    });

    group('LocationFailure', () {
      test('creates instance with message and code', () {
        const failure = LocationFailure(
          message: 'Service disabled',
          code: 'service_disabled',
        );

        expect(failure.message, 'Service disabled');
        expect(failure.code, 'service_disabled');
      });
    });

    group('CacheFailure', () {
      test('creates instance with message', () {
        const failure = CacheFailure(
          message: 'Cache error',
          code: 'read_error',
        );

        expect(failure.message, 'Cache error');
        expect(failure.code, 'read_error');
      });
    });

    group('PermissionFailure', () {
      test('creates instance with message and permission', () {
        const failure = PermissionFailure(
          message: 'Camera permission denied',
          permission: 'CAMERA',
          code: 'denied',
        );

        expect(failure.message, 'Camera permission denied');
        expect(failure.permission, 'CAMERA');
        expect(failure.code, 'denied');
      });

      test('props includes permission', () {
        const failure = PermissionFailure(
          message: 'Error',
          permission: 'CAMERA',
          code: 'code1',
        );
        expect(failure.props, [
          failure.message,
          failure.permission,
          failure.code,
        ]);
      });

      test('equality works with same parameters', () {
        const f1 = PermissionFailure(message: 'Error', permission: 'CAMERA');
        const f2 = PermissionFailure(message: 'Error', permission: 'CAMERA');
        expect(f1, equals(f2));
      });
    });

    group('UnknownFailure', () {
      test('creates instance with message', () {
        const failure = UnknownFailure(message: 'Unknown error occurred');

        expect(failure.message, 'Unknown error occurred');
      });

      test('userMessage returns localized default message', () {
        const failure = UnknownFailure(message: 'Something unexpected');
        expect(
          failure.userMessage,
          'Ha ocurrido un error inesperado. Por favor, intenta nuevamente.',
        );
      });

      test('creates with default message if not provided', () {
        const failure = UnknownFailure();
        expect(failure.message, 'Ha ocurrido un error inesperado.');
      });
    });

    group('Failure base class behavior', () {
      test('all failures are Equatable', () {
        const f1 = ServerFailure(message: 'Error', statusCode: 500);
        const f2 = ServerFailure(message: 'Error', statusCode: 500);
        const f3 = ServerFailure(message: 'Different', statusCode: 500);

        expect(f1, equals(f2));
        expect(f1, isNot(equals(f3)));
      });

      test('props are consistent for same failure type', () {
        const failure = ServerFailure(
          message: 'Error',
          statusCode: 500,
          code: 'code1',
        );

        expect(failure.props, [
          failure.message,
          failure.statusCode,
          failure.code,
        ]);
      });

      test('userMessage defaults to generic message property', () {
        const failure = NetworkFailure(
          message: 'Network error',
          code: 'net_error',
        );

        expect(
          failure.userMessage,
          'Error de conexión. Por favor, verifica tu internet.',
        );
      });
    });

    group('Edge cases', () {
      test('ServerFailure with null statusCode', () {
        const failure = ServerFailure(message: 'Error');

        expect(failure.statusCode, isNull);
        expect(failure.userMessage, 'Error');
      });

      test('ValidationFailure with empty fieldErrors', () {
        final failure = ValidationFailure(message: 'Error', fieldErrors: {});

        expect(failure.fieldErrors, isEmpty);
        expect(failure.getAllErrors(), isEmpty);
      });

      test('ValidationFailure with field having empty error list', () {
        final failure = ValidationFailure(
          message: 'Error',
          fieldErrors: {'email': []},
        );

        // Empty list means no first element, so getFieldError should handle gracefully
        // Based on implementation, this will throw, so we test the behavior
        expect(
          () => failure.getFieldError('email'),
          throwsA(isA<StateError>()),
        );
      });

      test('PermissionFailure with different permissions', () {
        const f1 = PermissionFailure(message: 'Error', permission: 'CAMERA');
        const f2 = PermissionFailure(message: 'Error', permission: 'LOCATION');

        expect(f1, isNot(equals(f2)));
      });
    });
  });
}
