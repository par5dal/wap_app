// test/core/services/blocked_users_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/services/blocked_users_service.dart';
import 'package:wap_app/features/user_actions/data/datasources/user_actions_remote_data_source.dart';

class MockUserActionsRemoteDataSource extends Mock
    implements UserActionsRemoteDataSource {}

void main() {
  late BlockedUsersService service;
  late MockUserActionsRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockUserActionsRemoteDataSource();
    service = BlockedUsersService(dataSource: mockDataSource);
  });

  tearDown(() {
    service.dispose();
  });

  group('loadFromRemote', () {
    test('populates blockedIds on success', () async {
      when(
        () => mockDataSource.getBlockedUsers(),
      ).thenAnswer((_) async => ['user1', 'user2']);

      await service.loadFromRemote();

      expect(service.blockedIds, equals({'user1', 'user2'}));
      expect(service.isBlocked('user1'), isTrue);
      expect(service.isBlocked('user3'), isFalse);
    });

    test('replaces previous list on reload', () async {
      when(
        () => mockDataSource.getBlockedUsers(),
      ).thenAnswer((_) async => ['user1']);
      await service.loadFromRemote();

      when(
        () => mockDataSource.getBlockedUsers(),
      ).thenAnswer((_) async => ['user2', 'user3']);
      await service.loadFromRemote();

      expect(service.blockedIds, equals({'user2', 'user3'}));
      expect(service.isBlocked('user1'), isFalse);
    });

    test('swallows exception without throwing', () async {
      when(
        () => mockDataSource.getBlockedUsers(),
      ).thenThrow(Exception('Network error'));

      await expectLater(service.loadFromRemote(), completes);
      expect(service.blockedIds, isEmpty);
    });

    test('notifies listeners on success', () async {
      when(
        () => mockDataSource.getBlockedUsers(),
      ).thenAnswer((_) async => ['user1']);

      int notifyCount = 0;
      service.addListener(() => notifyCount++);

      await service.loadFromRemote();

      expect(notifyCount, 1);
    });
  });

  group('addBlocked', () {
    test('adds userId and notifies listeners', () {
      int notifyCount = 0;
      service.addListener(() => notifyCount++);

      service.addBlocked('user1');

      expect(service.isBlocked('user1'), isTrue);
      expect(notifyCount, 1);
    });

    test('does not notify if userId already blocked', () {
      service.addBlocked('user1');

      int notifyCount = 0;
      service.addListener(() => notifyCount++);

      service.addBlocked('user1'); // duplicate

      expect(notifyCount, 0);
    });
  });

  group('removeBlocked', () {
    test('removes userId and notifies listeners', () {
      service.addBlocked('user1');

      int notifyCount = 0;
      service.addListener(() => notifyCount++);

      service.removeBlocked('user1');

      expect(service.isBlocked('user1'), isFalse);
      expect(notifyCount, 1);
    });

    test('does not notify if userId was not blocked', () {
      int notifyCount = 0;
      service.addListener(() => notifyCount++);

      service.removeBlocked('unknown');

      expect(notifyCount, 0);
    });
  });

  group('clear', () {
    test('clears all ids and notifies', () {
      service.addBlocked('user1');
      service.addBlocked('user2');

      int notifyCount = 0;
      service.addListener(() => notifyCount++);

      service.clear();

      expect(service.blockedIds, isEmpty);
      expect(notifyCount, 1);
    });

    test('does not notify when already empty', () {
      int notifyCount = 0;
      service.addListener(() => notifyCount++);

      service.clear();

      expect(notifyCount, 0);
    });
  });

  group('blockedIds', () {
    test('returns unmodifiable set', () {
      service.addBlocked('user1');

      expect(() => service.blockedIds.add('user2'), throwsUnsupportedError);
    });
  });
}
