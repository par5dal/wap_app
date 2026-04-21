// test/features/notifications/data/repositories/notifications_repository_impl_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:wap_app/features/notifications/data/models/user_notification_model.dart';
import 'package:wap_app/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:wap_app/features/notifications/domain/entities/user_notification.dart';

class MockNotificationsRemoteDataSource extends Mock
    implements NotificationsRemoteDataSource {}

// ── Helpers ───────────────────────────────────────────────────────────────────

UserNotificationModel makeModel({required String id, bool isRead = false}) =>
    UserNotificationModel(
      id: id,
      title: 'T$id',
      body: 'B$id',
      isRead: isRead,
      createdAt: DateTime(2026),
    );

final tServerException = ServerException(message: 'Server error');
final tNetworkException = NetworkException(message: 'No internet');

void main() {
  late NotificationsRepositoryImpl repo;
  late MockNotificationsRemoteDataSource mockDs;

  setUp(() {
    mockDs = MockNotificationsRemoteDataSource();
    repo = NotificationsRepositoryImpl(remoteDataSource: mockDs);
  });

  // ── getNotifications ───────────────────────────────────────────────────────
  group('getNotifications', () {
    final tModels = [makeModel(id: '1'), makeModel(id: '2', isRead: true)];
    final tResult = (items: tModels, unreadCount: 1, hasMore: false);

    test('returns Right with mapped data on success', () async {
      when(
        () => mockDs.getNotifications(page: 1, limit: 20),
      ).thenAnswer((_) async => tResult);

      final result = await repo.getNotifications();

      expect(result.isRight(), isTrue);
      result.fold((_) {}, (data) {
        expect(data.items.length, 2);
        expect(data.unreadCount, 1);
        expect(data.hasMore, isFalse);
        expect(data.items.first, isA<UserNotification>());
      });
    });

    test('returns Left(ServerFailure) on ServerException', () async {
      when(
        () => mockDs.getNotifications(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(tServerException);

      final result = await repo.getNotifications();
      expect(result, isA<Left<Failure, dynamic>>());
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('returns Left(NetworkFailure) on NetworkException', () async {
      when(
        () => mockDs.getNotifications(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(tNetworkException);

      final result = await repo.getNotifications();
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('returns Left(UnknownFailure) on unexpected exception', () async {
      when(
        () => mockDs.getNotifications(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('Boom'));

      final result = await repo.getNotifications();
      result.fold(
        (f) => expect(f, isA<UnknownFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  // ── getUnreadCount ─────────────────────────────────────────────────────────
  group('getUnreadCount', () {
    test('returns Right(count) on success', () async {
      when(() => mockDs.getUnreadCount()).thenAnswer((_) async => 5);
      final result = await repo.getUnreadCount();
      expect(result, const Right(5));
    });

    test('returns Left on ServerException', () async {
      when(() => mockDs.getUnreadCount()).thenThrow(tServerException);
      final result = await repo.getUnreadCount();
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  // ── markRead ───────────────────────────────────────────────────────────────
  group('markRead', () {
    test('returns Right(null) on success', () async {
      when(() => mockDs.markRead('1')).thenAnswer((_) async {});
      final result = await repo.markRead('1');
      expect(result, const Right(null));
    });

    test('returns Left on ServerException', () async {
      when(() => mockDs.markRead(any())).thenThrow(tServerException);
      final result = await repo.markRead('1');
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  // ── markAllRead ────────────────────────────────────────────────────────────
  group('markAllRead', () {
    test('returns Right(null) on success', () async {
      when(() => mockDs.markAllRead()).thenAnswer((_) async {});
      expect(await repo.markAllRead(), const Right(null));
    });

    test('returns Left on NetworkException', () async {
      when(() => mockDs.markAllRead()).thenThrow(tNetworkException);
      final result = await repo.markAllRead();
      result.fold(
        (f) => expect(f, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  // ── deleteOne ──────────────────────────────────────────────────────────────
  group('deleteOne', () {
    test('returns Right(null) on success', () async {
      when(() => mockDs.deleteOne('42')).thenAnswer((_) async {});
      expect(await repo.deleteOne('42'), const Right(null));
    });

    test('returns Left on ServerException', () async {
      when(() => mockDs.deleteOne(any())).thenThrow(tServerException);
      final result = await repo.deleteOne('42');
      result.fold(
        (f) => expect(f, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  // ── deleteAll ──────────────────────────────────────────────────────────────
  group('deleteAll', () {
    test('returns Right(null) on success', () async {
      when(() => mockDs.deleteAll()).thenAnswer((_) async {});
      expect(await repo.deleteAll(), const Right(null));
    });

    test('returns Left on unexpected exception', () async {
      when(() => mockDs.deleteAll()).thenThrow(Exception('boom'));
      final result = await repo.deleteAll();
      result.fold(
        (f) => expect(f, isA<UnknownFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
