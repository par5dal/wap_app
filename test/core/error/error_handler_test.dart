// test/core/error/error_handler_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wap_app/core/error/app_exception.dart';
import 'package:wap_app/core/error/error_handler.dart';
import 'package:wap_app/core/error/failures.dart';

void main() {
  group('ErrorHandler', () {
    // ─────────────────────────────────────────────────────────────────────────
    // AppException handling
    // ─────────────────────────────────────────────────────────────────────────

    test('handleException with ServerException returns ServerFailure', () {
      final exception = ServerException(
        message: 'Not found',
        statusCode: 404,
        code: 'not_found',
      );

      final failure = ErrorHandler.handleException(exception);

      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'Not found');
      expect((failure as ServerFailure).statusCode, 404);
      expect(failure.code, 'not_found');
    });

    test(
      'handleException with AuthenticationException returns AuthenticationFailure',
      () {
        final exception = const AuthenticationException(
          message: 'Invalid token',
          code: 'invalid_token',
        );

        final failure = ErrorHandler.handleException(exception);

        expect(failure, isA<AuthenticationFailure>());
        expect(failure.message, 'Invalid token');
        expect(failure.code, 'invalid_token');
      },
    );

    test(
      'handleException with ValidationException returns ValidationFailure',
      () {
        final fieldErrors = {
          'email': ['Invalid email'],
          'password': ['Too short'],
        };
        final exception = ValidationException(
          message: 'Validation failed',
          fieldErrors: fieldErrors,
          code: 'validation_error',
        );

        final failure = ErrorHandler.handleException(exception);

        expect(failure, isA<ValidationFailure>());
        final vf = failure as ValidationFailure;
        expect(vf.fieldErrors.length, 2);
        expect(vf.fieldErrors['email'], ['Invalid email']);
      },
    );

    test('handleException with NetworkException returns NetworkFailure', () {
      final exception = const NetworkException(
        message: 'Connection timed out',
        code: 'timeout',
      );

      final failure = ErrorHandler.handleException(exception);

      expect(failure, isA<NetworkFailure>());
      expect(failure.message, 'Connection timed out');
      expect(failure.code, 'timeout');
    });

    test('handleException with LocationException returns LocationFailure', () {
      final exception = const LocationException(
        message: 'Location service disabled',
        errorType: LocationErrorType.serviceDisabled,
        code: 'location_disabled',
      );

      final failure = ErrorHandler.handleException(exception);

      expect(failure, isA<LocationFailure>());
      expect(failure.code, 'service_disabled');
    });

    test('handleException with StorageException returns CacheFailure', () {
      final exception = const StorageException(
        message: 'Storage error',
        code: 'read_error',
      );

      final failure = ErrorHandler.handleException(exception);

      expect(failure, isA<CacheFailure>());
    });

    test(
      'handleException with PermissionException returns PermissionFailure',
      () {
        final exception = const PermissionException(
          message: 'Permission denied',
          permission: 'CAMERA',
          code: 'denied',
        );

        final failure = ErrorHandler.handleException(exception);

        expect(failure, isA<PermissionFailure>());
        final pf = failure as PermissionFailure;
        expect(pf.permission, 'CAMERA');
      },
    );

    test('handleException with TimeoutException returns NetworkFailure', () {
      final exception = TimeoutException(
        message: 'Timeout',
        timeout: const Duration(seconds: 30),
        code: 'timeout',
      );

      final failure = ErrorHandler.handleException(exception);

      expect(failure, isA<NetworkFailure>());
      expect(failure.code, 'timeout');
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Dio Exception handling
    // ─────────────────────────────────────────────────────────────────────────

    test(
      'handleException with DioException connectionTimeout returns NetworkFailure',
      () {
        final dioEx = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timeout',
        );

        final failure = ErrorHandler.handleException(dioEx);

        expect(failure, isA<NetworkFailure>());
        expect(failure.code, 'timeout');
      },
    );

    test(
      'handleException with DioException receiveTimeout returns NetworkFailure',
      () {
        final dioEx = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.receiveTimeout,
        );

        final failure = ErrorHandler.handleException(dioEx);

        expect(failure, isA<NetworkFailure>());
        expect(failure.code, 'timeout');
      },
    );

    test(
      'handleException with DioException connectionError returns NetworkFailure',
      () {
        final dioEx = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionError,
        );

        final failure = ErrorHandler.handleException(dioEx);

        expect(failure, isA<NetworkFailure>());
        expect(failure.code, 'no_internet');
      },
    );

    test('handleException with DioException cancel returns NetworkFailure', () {
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.cancel,
      );

      final failure = ErrorHandler.handleException(dioEx);

      expect(failure, isA<NetworkFailure>());
      expect(failure.code, 'cancelled');
    });

    test(
      'handleException with DioException badCertificate returns NetworkFailure',
      () {
        final dioEx = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.badCertificate,
        );

        final failure = ErrorHandler.handleException(dioEx);

        expect(failure, isA<NetworkFailure>());
        expect(failure.code, 'bad_certificate');
      },
    );

    test(
      'handleException with DioException unknown returns NetworkFailure',
      () {
        final dioEx = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.unknown,
          message: 'Unknown error',
        );

        final failure = ErrorHandler.handleException(dioEx);

        expect(failure, isA<NetworkFailure>());
        expect(failure.code, 'unknown');
      },
    );

    // ─────────────────────────────────────────────────────────────────────────
    // Dio bad response (4xx/5xx)
    // ─────────────────────────────────────────────────────────────────────────

    test('handleException with 401 response returns AuthenticationFailure', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 401,
        data: {'message': 'Unauthorized', 'error': 'unauthorized'},
      );
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: response,
        type: DioExceptionType.badResponse,
      );

      final failure = ErrorHandler.handleException(dioEx);

      expect(failure, isA<AuthenticationFailure>());
      expect(failure.code, 'unauthorized');
    });

    test(
      'handleException with 400 + validation errors returns ValidationFailure',
      () {
        final response = Response<dynamic>(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
          data: {
            'message': ['email must be a string', 'password must be longer'],
            'error': 'validation_error',
          },
        );
        final dioEx = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: response,
          type: DioExceptionType.badResponse,
        );

        final failure = ErrorHandler.handleException(dioEx);

        expect(failure, isA<ValidationFailure>());
        final vf = failure as ValidationFailure;
        expect(vf.fieldErrors.containsKey('general'), true);
      },
    );

    test('handleException with 500 returns ServerFailure', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 500,
        data: {'message': 'Internal server error'},
      );
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: response,
        type: DioExceptionType.badResponse,
      );

      final failure = ErrorHandler.handleException(dioEx);

      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 500);
    });

    test('handleException with null response data returns ServerFailure', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 503,
        data: null,
      );
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: response,
        type: DioExceptionType.badResponse,
      );

      final failure = ErrorHandler.handleException(dioEx);

      expect(failure, isA<ServerFailure>());
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Generic exception handling
    // ─────────────────────────────────────────────────────────────────────────

    test('handleException with generic Exception returns UnknownFailure', () {
      final exception = Exception('Something went wrong');

      final failure = ErrorHandler.handleException(exception);

      expect(failure, isA<UnknownFailure>());
      expect(failure.message, contains('Something went wrong'));
    });

    test('handleException with String error returns UnknownFailure', () {
      final failure = ErrorHandler.handleException('String error');

      expect(failure, isA<UnknownFailure>());
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Location error code mapping
    // ─────────────────────────────────────────────────────────────────────────

    test('LocationErrorType.serviceDisabled maps to service_disabled', () {
      final ex = const LocationException(
        message: 'Service disabled',
        errorType: LocationErrorType.serviceDisabled,
      );
      final failure = ErrorHandler.handleException(ex);
      expect((failure as LocationFailure).code, 'service_disabled');
    });

    test('LocationErrorType.permissionDenied maps to permission_denied', () {
      final ex = const LocationException(
        message: 'Permission denied',
        errorType: LocationErrorType.permissionDenied,
      );
      final failure = ErrorHandler.handleException(ex);
      expect((failure as LocationFailure).code, 'permission_denied');
    });

    test(
      'LocationErrorType.permissionDeniedForever maps to permission_denied_forever',
      () {
        final ex = const LocationException(
          message: 'Permission denied forever',
          errorType: LocationErrorType.permissionDeniedForever,
        );
        final failure = ErrorHandler.handleException(ex);
        expect((failure as LocationFailure).code, 'permission_denied_forever');
      },
    );

    test(
      'LocationErrorType.positionUnavailable maps to position_unavailable',
      () {
        final ex = const LocationException(
          message: 'Position unavailable',
          errorType: LocationErrorType.positionUnavailable,
        );
        final failure = ErrorHandler.handleException(ex);
        expect((failure as LocationFailure).code, 'position_unavailable');
      },
    );

    // ─────────────────────────────────────────────────────────────────────────
    // Validation error parsing
    // ─────────────────────────────────────────────────────────────────────────

    test('_parseValidationErrors handles string error list', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 400,
        data: {
          'message': ['email is required', 'password must be 8+ chars'],
          'error': 'validation_error',
        },
      );
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: response,
        type: DioExceptionType.badResponse,
      );

      final failure = ErrorHandler.handleException(dioEx) as ValidationFailure;

      expect(failure.fieldErrors.containsKey('general'), true);
      expect(failure.fieldErrors['general']!.length, 2);
    });

    test('_parseValidationErrors handles object error list', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 400,
        data: {
          'message': [
            {'field': 'email', 'message': 'Invalid email'},
            {'field': 'password', 'message': 'Too short'},
          ],
        },
      );
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: response,
        type: DioExceptionType.badResponse,
      );

      final failure = ErrorHandler.handleException(dioEx) as ValidationFailure;

      expect(failure.fieldErrors.containsKey('email'), true);
      expect(failure.fieldErrors.containsKey('password'), true);
    });

    test('_parseValidationErrors handles mixed error list', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 400,
        data: {
          'message': [
            'general error',
            {'field': 'email', 'message': 'Invalid'},
          ],
        },
      );
      final dioEx = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: response,
        type: DioExceptionType.badResponse,
      );

      final failure = ErrorHandler.handleException(dioEx) as ValidationFailure;

      expect(failure.fieldErrors.containsKey('general'), true);
      expect(failure.fieldErrors.containsKey('email'), true);
    });
  });
}
