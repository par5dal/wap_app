// test/features/user_actions/data/datasources/user_actions_remote_data_source_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/features/user_actions/data/datasources/user_actions_remote_data_source.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response {}

void main() {
  late UserActionsRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = UserActionsRemoteDataSourceImpl(dio: mockDio);
  });

  DioException dioError({int? statusCode, dynamic message}) => DioException(
    requestOptions: RequestOptions(path: ''),
    response: statusCode != null
        ? Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: statusCode,
            data: message != null ? {'message': message} : null,
          )
        : null,
  );

  // ---------------------------------------------------------------------------
  // addEventToFavorites
  // ---------------------------------------------------------------------------
  group('addEventToFavorites', () {
    test('completes on 201', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(201);
      when(() => mockDio.post(any())).thenAnswer((_) async => r);

      await expectLater(dataSource.addEventToFavorites('evt-1'), completes);
    });

    test('skips silently on 409 (already favorited)', () async {
      when(() => mockDio.post(any())).thenThrow(dioError(statusCode: 409));

      await expectLater(dataSource.addEventToFavorites('evt-1'), completes);
    });

    test('throws ServerException on 404', () async {
      when(() => mockDio.post(any())).thenThrow(dioError(statusCode: 404));

      expect(
        () => dataSource.addEventToFavorites('evt-1'),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws ServerException on other DioException', () async {
      when(
        () => mockDio.post(any()),
      ).thenThrow(dioError(statusCode: 500, message: 'Server error'));

      expect(
        () => dataSource.addEventToFavorites('evt-1'),
        throwsA(isA<ServerException>()),
      );
    });

    test(
      'throws ServerException on non-201 status code from response',
      () async {
        final r = MockResponse();
        when(() => r.statusCode).thenReturn(400);
        when(() => mockDio.post(any())).thenAnswer((_) async => r);

        expect(
          () => dataSource.addEventToFavorites('evt-1'),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });

  // ---------------------------------------------------------------------------
  // removeEventFromFavorites
  // ---------------------------------------------------------------------------
  group('removeEventFromFavorites', () {
    test('completes on 204', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(204);
      when(() => mockDio.delete(any())).thenAnswer((_) async => r);

      await expectLater(
        dataSource.removeEventFromFavorites('evt-1'),
        completes,
      );
    });

    test('skips silently on 404 (not in favorites)', () async {
      when(() => mockDio.delete(any())).thenThrow(dioError(statusCode: 404));

      await expectLater(
        dataSource.removeEventFromFavorites('evt-1'),
        completes,
      );
    });

    test('throws ServerException on other DioException', () async {
      when(
        () => mockDio.delete(any()),
      ).thenThrow(dioError(statusCode: 500, message: 'Server error'));

      expect(
        () => dataSource.removeEventFromFavorites('evt-1'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // followPromoter
  // ---------------------------------------------------------------------------
  group('followPromoter', () {
    test('completes on 201', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(201);
      when(() => mockDio.post(any())).thenAnswer((_) async => r);

      await expectLater(dataSource.followPromoter('p-1'), completes);
    });

    test('skips silently on 409 (already following)', () async {
      when(() => mockDio.post(any())).thenThrow(dioError(statusCode: 409));

      await expectLater(dataSource.followPromoter('p-1'), completes);
    });

    test('throws ServerException on 404 promoter not found', () async {
      when(() => mockDio.post(any())).thenThrow(dioError(statusCode: 404));

      expect(
        () => dataSource.followPromoter('p-1'),
        throwsA(
          isA<ServerException>().having((e) => e.statusCode, 'statusCode', 404),
        ),
      );
    });

    test('throws ServerException on other DioException', () async {
      when(
        () => mockDio.post(any()),
      ).thenThrow(dioError(statusCode: 500, message: 'error'));

      expect(
        () => dataSource.followPromoter('p-1'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // unfollowPromoter
  // ---------------------------------------------------------------------------
  group('unfollowPromoter', () {
    test('completes on 204', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(204);
      when(() => mockDio.delete(any())).thenAnswer((_) async => r);

      await expectLater(dataSource.unfollowPromoter('p-1'), completes);
    });

    test('skips silently on 404 (not following)', () async {
      when(() => mockDio.delete(any())).thenThrow(dioError(statusCode: 404));

      await expectLater(dataSource.unfollowPromoter('p-1'), completes);
    });

    test('throws ServerException on other DioException', () async {
      when(
        () => mockDio.delete(any()),
      ).thenThrow(dioError(statusCode: 500, message: 'err'));

      expect(
        () => dataSource.unfollowPromoter('p-1'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getBlockedUsers
  // ---------------------------------------------------------------------------
  group('getBlockedUsers', () {
    test('returns list of ids on 200 with nested user format', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(200);
      when(() => r.data).thenReturn({
        'blocked': [
          {
            'user': {'id': 'u-1'},
          },
          {
            'user': {'id': 'u-2'},
          },
        ],
      });
      when(() => mockDio.get(any())).thenAnswer((_) async => r);

      final result = await dataSource.getBlockedUsers();

      expect(result, ['u-1', 'u-2']);
    });

    test('returns empty list on null body', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(200);
      when(() => r.data).thenReturn(null);
      when(() => mockDio.get(any())).thenAnswer((_) async => r);

      final result = await dataSource.getBlockedUsers();

      expect(result, isEmpty);
    });

    test('returns empty list on 304', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(304);
      when(() => r.data).thenReturn(null);
      when(() => mockDio.get(any())).thenAnswer((_) async => r);

      final result = await dataSource.getBlockedUsers();

      expect(result, isEmpty);
    });

    test('throws ServerException on DioException', () async {
      when(
        () => mockDio.get(any()),
      ).thenThrow(dioError(statusCode: 500, message: 'err'));

      expect(
        () => dataSource.getBlockedUsers(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // blockUser
  // ---------------------------------------------------------------------------
  group('blockUser', () {
    test('completes on 201', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(201);
      when(() => mockDio.post(any())).thenAnswer((_) async => r);

      await expectLater(dataSource.blockUser('u-1'), completes);
    });

    test('completes on 204', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(204);
      when(() => mockDio.post(any())).thenAnswer((_) async => r);

      await expectLater(dataSource.blockUser('u-1'), completes);
    });

    test('skips silently on 409 (already blocked)', () async {
      when(() => mockDio.post(any())).thenThrow(dioError(statusCode: 409));

      await expectLater(dataSource.blockUser('u-1'), completes);
    });

    test('throws ServerException on other DioException', () async {
      when(
        () => mockDio.post(any()),
      ).thenThrow(dioError(statusCode: 500, message: 'err'));

      expect(
        () => dataSource.blockUser('u-1'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // unblockUser
  // ---------------------------------------------------------------------------
  group('unblockUser', () {
    test('completes on 204', () async {
      final r = MockResponse();
      when(() => r.statusCode).thenReturn(204);
      when(() => mockDio.delete(any())).thenAnswer((_) async => r);

      await expectLater(dataSource.unblockUser('u-1'), completes);
    });

    test('skips silently on 404 (not blocked)', () async {
      when(() => mockDio.delete(any())).thenThrow(dioError(statusCode: 404));

      await expectLater(dataSource.unblockUser('u-1'), completes);
    });

    test('throws ServerException on other DioException', () async {
      when(
        () => mockDio.delete(any()),
      ).thenThrow(dioError(statusCode: 500, message: 'err'));

      expect(
        () => dataSource.unblockUser('u-1'),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
