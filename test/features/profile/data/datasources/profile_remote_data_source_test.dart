// test/features/profile/data/datasources/profile_remote_data_source_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/app_exception.dart';
import 'package:wap_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:wap_app/features/profile/domain/entities/profile_entity.dart';
import 'package:wap_app/features/profile/domain/entities/user_with_profile_entity.dart';

class MockDio extends Mock implements Dio {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockResponse extends Mock implements Response {}

final _tProfileJson = {
  'id': 'prof-1',
  'user_id': 'user-1',
  'first_name': 'Ana',
  'last_name': 'López',
  'display_name': 'Ana',
  'bio': null,
  'avatar_url': null,
  'date_of_birth': null,
  'city': null,
  'country': null,
  'created_at': '2024-01-01T00:00:00.000Z',
  'updated_at': '2024-01-01T00:00:00.000Z',
  'user': {
    'id': 'user-1',
    'email': 'ana@example.com',
    'role': 'CONSUMER',
    'is_active': true,
    'created_at': '2024-01-01T00:00:00.000Z',
    'updated_at': '2024-01-01T00:00:00.000Z',
  },
};

void main() {
  late ProfileRemoteDataSourceImpl dataSource;
  late MockDio mockDio;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockDio = MockDio();
    mockStorage = MockFlutterSecureStorage();
    dataSource = ProfileRemoteDataSourceImpl(
      dio: mockDio,
      secureStorage: mockStorage,
    );
  });

  DioException dioError({int? statusCode}) => DioException(
    requestOptions: RequestOptions(path: ''),
    response: statusCode != null
        ? Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: statusCode,
            data: {'message': 'error'},
          )
        : null,
  );

  // ---------------------------------------------------------------------------
  // getMyProfile
  // ---------------------------------------------------------------------------
  group('getMyProfile', () {
    test('returns UserWithProfileEntity on 200', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(200);
      when(() => r.data).thenReturn(_tProfileJson);
      when(() => mockDio.get(any())).thenAnswer((_) async => r);

      final result = await dataSource.getMyProfile();

      expect(result, isA<UserWithProfileEntity>());
      expect(result.id, 'user-1');
      expect(result.email, 'ana@example.com');
    });

    test('returns UserWithProfileEntity on 304', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(304);
      when(() => r.data).thenReturn(_tProfileJson);
      when(() => mockDio.get(any())).thenAnswer((_) async => r);

      final result = await dataSource.getMyProfile();

      expect(result.id, 'user-1');
    });

    test('throws ServerException on DioException', () async {
      when(() => mockDio.get(any())).thenThrow(dioError(statusCode: 401));

      expect(() => dataSource.getMyProfile(), throwsA(isA<ServerException>()));
    });

    test('throws ServerException on non-200/304 status', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(500);
      when(() => r.data).thenReturn(null);
      when(() => mockDio.get(any())).thenAnswer((_) async => r);

      expect(() => dataSource.getMyProfile(), throwsA(isA<ServerException>()));
    });
  });

  // ---------------------------------------------------------------------------
  // updateMyProfile
  // ---------------------------------------------------------------------------
  group('updateMyProfile', () {
    final tProfileOnlyJson = {
      'id': 'prof-1',
      'user_id': 'user-1',
      'first_name': 'Ana',
      'last_name': 'López',
      'display_name': 'Ana',
      'bio': null,
      'avatar_url': null,
      'date_of_birth': null,
      'city': null,
      'country': null,
      'updated_at': '2024-01-01T00:00:00.000Z',
    };

    test('returns ProfileEntity on 200', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(200);
      when(() => r.data).thenReturn(tProfileOnlyJson);
      when(
        () => mockDio.patch(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => r);

      final result = await dataSource.updateMyProfile({
        'first_name': 'Ana',
        'nullValue': null,
        'empty': '',
      });

      expect(result, isA<ProfileEntity>());
      expect(result.firstName, 'Ana');
    });

    test('filters null and empty values except avatar_url', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(200);
      when(() => r.data).thenReturn(tProfileOnlyJson);

      Map<String, dynamic>? capturedData;
      when(() => mockDio.patch(any(), data: any(named: 'data'))).thenAnswer((
        invocation,
      ) async {
        capturedData =
            invocation.namedArguments[const Symbol('data')]
                as Map<String, dynamic>;
        return r;
      });

      await dataSource.updateMyProfile({
        'first_name': 'Ana',
        'bio': null,
        'avatar_url': null, // should be kept
        'empty_field': '',
      });

      expect(capturedData!.containsKey('bio'), isFalse);
      expect(capturedData!.containsKey('empty_field'), isFalse);
      expect(capturedData!.containsKey('avatar_url'), isTrue);
    });

    test('passes promoter fields company_name, tax_id, website_url', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(200);
      when(() => r.data).thenReturn(tProfileOnlyJson);

      Map<String, dynamic>? capturedData;
      when(() => mockDio.patch(any(), data: any(named: 'data'))).thenAnswer((
        invocation,
      ) async {
        capturedData =
            invocation.namedArguments[const Symbol('data')]
                as Map<String, dynamic>;
        return r;
      });

      await dataSource.updateMyProfile({
        'company_name': 'Acme Events S.L.',
        'tax_id': 'B12345678',
        'website_url': 'https://acmeevents.com',
      });

      expect(capturedData!['company_name'], 'Acme Events S.L.');
      expect(capturedData!['tax_id'], 'B12345678');
      expect(capturedData!['website_url'], 'https://acmeevents.com');
    });

    test('throws ServerException on DioException', () async {
      when(
        () => mockDio.patch(any(), data: any(named: 'data')),
      ).thenThrow(dioError(statusCode: 500));

      expect(
        () => dataSource.updateMyProfile({'first_name': 'x'}),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getUploadSignature
  // ---------------------------------------------------------------------------
  group('getUploadSignature', () {
    final tSigJson = {
      'signature': 'sig123',
      'timestamp': 1700000000,
      'api_key': 'key123',
      'folder': 'avatars',
      'cloud_name': 'mycloud',
    };

    test('returns map with signature data on 201', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(201);
      when(() => r.data).thenReturn(tSigJson);
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => r);

      final result = await dataSource.getUploadSignature(
        preset: 'avatar',
        uploadType: 'AVATAR',
      );

      expect(result['signature'], 'sig123');
      expect(result['timestamp'], 1700000000);
      expect(result['cloud_name'], 'mycloud');
    });

    test(
      'includes optional eventId and transformation when provided',
      () async {
        final r = MockResponse();
        when(() => r.statusCode).thenReturn(200);
        when(() => r.data).thenReturn(tSigJson);

        Map<String, dynamic>? capturedData;
        when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer((
          invocation,
        ) async {
          capturedData =
              invocation.namedArguments[const Symbol('data')]
                  as Map<String, dynamic>;
          return r;
        });

        await dataSource.getUploadSignature(
          preset: 'event',
          uploadType: 'EVENT',
          eventId: 'evt-1',
          transformation: 'c_fill',
        );

        expect(capturedData!['eventId'], 'evt-1');
        expect(capturedData!['transformation'], 'c_fill');
      },
    );

    test('throws ServerException on DioException', () async {
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenThrow(dioError(statusCode: 500));

      expect(
        () => dataSource.getUploadSignature(
          preset: 'avatar',
          uploadType: 'AVATAR',
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // deleteResource
  // ---------------------------------------------------------------------------
  group('deleteResource', () {
    test('completes on 204', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(204);
      when(
        () => mockDio.delete(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => r);

      await expectLater(
        dataSource.deleteResource('https://example.com/img.jpg'),
        completes,
      );
    });

    test('completes on 200', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(200);
      when(
        () => mockDio.delete(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => r);

      await expectLater(
        dataSource.deleteResource('https://example.com/img.jpg'),
        completes,
      );
    });

    test('throws ServerException on DioException', () async {
      when(
        () => mockDio.delete(any(), data: any(named: 'data')),
      ).thenThrow(dioError(statusCode: 500));

      expect(
        () => dataSource.deleteResource('https://example.com/img.jpg'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getFollowedPromoters
  // ---------------------------------------------------------------------------
  group('getFollowedPromoters', () {
    test('returns list of FollowedPromoterModel on 200', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(200);
      when(() => r.data).thenReturn({
        'data': [
          {'id': 'p-1', 'email': 'p1@example.com'},
          {'id': 'p-2', 'email': 'p2@example.com'},
        ],
      });
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => r);

      final result = await dataSource.getFollowedPromoters();

      expect(result.length, 2);
      expect(result.first.id, 'p-1');
    });

    test('returns empty list when data key is missing', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(200);
      when(() => r.data).thenReturn(<String, dynamic>{});
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => r);

      final result = await dataSource.getFollowedPromoters();

      expect(result, isEmpty);
    });

    test('returns empty list on DioException with 204', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 204,
          ),
        ),
      );

      final result = await dataSource.getFollowedPromoters();

      expect(result, isEmpty);
    });

    test('throws ServerException on DioException with 500', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(dioError(statusCode: 500));

      expect(
        () => dataSource.getFollowedPromoters(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getBlockedPromotersFull
  // ---------------------------------------------------------------------------
  group('getBlockedPromotersFull', () {
    test('returns list of BlockedPromoterModel on 200', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(200);
      when(() => r.data).thenReturn({
        'blocked': [
          {
            'blockId': 'b-1',
            'user': {'id': 'u-1', 'email': 'u1@example.com'},
          },
        ],
      });
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => r);

      final result = await dataSource.getBlockedPromotersFull();

      expect(result.length, 1);
      expect(result.first.id, 'u-1');
    });

    test('returns empty list when blocked key is missing', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(200);
      when(() => r.data).thenReturn(<String, dynamic>{});
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => r);

      final result = await dataSource.getBlockedPromotersFull();

      expect(result, isEmpty);
    });

    test('returns empty list on DioException with 204', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 204,
          ),
        ),
      );

      final result = await dataSource.getBlockedPromotersFull();

      expect(result, isEmpty);
    });

    test('throws ServerException on DioException with 500', () async {
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(dioError(statusCode: 500));

      expect(
        () => dataSource.getBlockedPromotersFull(),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
