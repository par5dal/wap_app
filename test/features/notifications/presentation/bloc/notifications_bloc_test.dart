// test/features/notifications/presentation/bloc/notifications_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/notifications/domain/entities/user_notification.dart';
import 'package:wap_app/features/notifications/domain/usecases/delete_all_notifications.dart';
import 'package:wap_app/features/notifications/domain/usecases/delete_notification.dart';
import 'package:wap_app/features/notifications/domain/usecases/get_notifications.dart';
import 'package:wap_app/features/notifications/domain/usecases/get_unread_count.dart';
import 'package:wap_app/features/notifications/domain/usecases/mark_all_notifications_read.dart';
import 'package:wap_app/features/notifications/domain/usecases/mark_notification_read.dart';
import 'package:wap_app/features/notifications/presentation/bloc/notifications_bloc.dart';

class MockGetNotifications extends Mock implements GetNotificationsUseCase {}

class MockGetUnreadCount extends Mock implements GetUnreadCountUseCase {}

class MockMarkRead extends Mock implements MarkNotificationReadUseCase {}

class MockMarkAllRead extends Mock implements MarkAllNotificationsReadUseCase {}

class MockDeleteNotification extends Mock
    implements DeleteNotificationUseCase {}

class MockDeleteAll extends Mock implements DeleteAllNotificationsUseCase {}

// ── Helpers ──────────────────────────────────────────────────────────────────

UserNotification makeNotif({required String id, bool isRead = false}) =>
    UserNotification(
      id: id,
      title: 'Notif $id',
      body: 'Body $id',
      isRead: isRead,
      createdAt: DateTime(2026, 1, 1),
    );

const tFailure = ServerFailure(message: 'Network error');

void main() {
  late NotificationsBloc bloc;
  late MockGetNotifications mockGet;
  late MockGetUnreadCount mockUnread;
  late MockMarkRead mockMarkRead;
  late MockMarkAllRead mockMarkAllRead;
  late MockDeleteNotification mockDelete;
  late MockDeleteAll mockDeleteAll;

  setUp(() {
    mockGet = MockGetNotifications();
    mockUnread = MockGetUnreadCount();
    mockMarkRead = MockMarkRead();
    mockMarkAllRead = MockMarkAllRead();
    mockDelete = MockDeleteNotification();
    mockDeleteAll = MockDeleteAll();

    bloc = NotificationsBloc(
      getNotifications: mockGet,
      getUnreadCount: mockUnread,
      markNotificationRead: mockMarkRead,
      markAllNotificationsRead: mockMarkAllRead,
      deleteNotification: mockDelete,
      deleteAllNotifications: mockDeleteAll,
    );
  });

  tearDown(() => bloc.close());

  // ── LoadNotifications ─────────────────────────────────────────────────────

  group('LoadNotifications', () {
    final tItems = [makeNotif(id: '1'), makeNotif(id: '2', isRead: true)];

    blocTest<NotificationsBloc, NotificationsState>(
      'emits [Loading, Loaded] on success',
      build: () {
        when(() => mockGet(page: 1, limit: 20)).thenAnswer(
          (_) async => Right((items: tItems, unreadCount: 1, hasMore: false)),
        );
        return bloc;
      },
      act: (b) => b.add(const LoadNotifications()),
      expect: () => [
        const NotificationsLoading(),
        NotificationsLoaded(
          items: tItems,
          unreadCount: 1,
          hasMore: false,
          currentPage: 1,
        ),
      ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'emits [Loading, Error] on failure',
      build: () {
        when(
          () => mockGet(page: 1, limit: 20),
        ).thenAnswer((_) async => const Left(tFailure));
        return bloc;
      },
      act: (b) => b.add(const LoadNotifications()),
      expect: () => [
        const NotificationsLoading(),
        const NotificationsError(message: 'Network error'),
      ],
    );
  });

  // ── RefreshUnreadCount ────────────────────────────────────────────────────

  group('RefreshUnreadCount', () {
    blocTest<NotificationsBloc, NotificationsState>(
      'updates unreadCount when state is Loaded',
      build: () {
        when(() => mockUnread()).thenAnswer((_) async => const Right(5));
        return bloc;
      },
      seed: () => const NotificationsLoaded(
        items: [],
        unreadCount: 0,
        hasMore: false,
        currentPage: 1,
      ),
      act: (b) => b.add(const RefreshUnreadCount()),
      expect: () => [
        const NotificationsLoaded(
          items: [],
          unreadCount: 5,
          hasMore: false,
          currentPage: 1,
        ),
      ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'emits Loaded with count when state is Initial (badge on startup)',
      build: () {
        when(() => mockUnread()).thenAnswer((_) async => const Right(3));
        return bloc;
      },
      // No seed → starts in NotificationsInitial
      act: (b) => b.add(const RefreshUnreadCount()),
      expect: () => [
        const NotificationsLoaded(
          items: [],
          unreadCount: 3,
          hasMore: false,
          currentPage: 0, // inherited from NotificationsInitial base state
        ),
      ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'does not emit when getUnreadCount fails',
      build: () {
        when(() => mockUnread()).thenAnswer((_) async => const Left(tFailure));
        return bloc;
      },
      act: (b) => b.add(const RefreshUnreadCount()),
      expect: () => [], // no state change
    );
  });

  // ── MarkNotificationRead ─────────────────────────────────────────────────

  group('MarkNotificationRead', () {
    final tItems = [makeNotif(id: '1'), makeNotif(id: '2')];

    blocTest<NotificationsBloc, NotificationsState>(
      'marks item as read and updates unreadCount',
      build: () {
        when(
          () => mockMarkRead('1'),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => NotificationsLoaded(
        items: tItems,
        unreadCount: 2,
        hasMore: false,
        currentPage: 1,
      ),
      act: (b) => b.add(const MarkNotificationRead('1')),
      expect: () => [
        NotificationsLoaded(
          items: [
            makeNotif(id: '1', isRead: true),
            makeNotif(id: '2'),
          ],
          unreadCount: 1,
          hasMore: false,
          currentPage: 1,
        ),
      ],
    );
  });

  // ── MarkAllNotificationsRead ─────────────────────────────────────────────

  group('MarkAllNotificationsRead', () {
    final tItems = [makeNotif(id: '1'), makeNotif(id: '2')];

    blocTest<NotificationsBloc, NotificationsState>(
      'marks all items read and sets unreadCount to 0',
      build: () {
        when(
          () => mockMarkAllRead(),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => NotificationsLoaded(
        items: tItems,
        unreadCount: 2,
        hasMore: false,
        currentPage: 1,
      ),
      act: (b) => b.add(const MarkAllNotificationsRead()),
      expect: () => [
        NotificationsLoaded(
          items: [
            makeNotif(id: '1', isRead: true),
            makeNotif(id: '2', isRead: true),
          ],
          unreadCount: 0,
          hasMore: false,
          currentPage: 1,
        ),
      ],
    );
  });

  // ── DeleteNotification ───────────────────────────────────────────────────

  group('DeleteNotification', () {
    final tItems = [makeNotif(id: '1'), makeNotif(id: '2')];

    blocTest<NotificationsBloc, NotificationsState>(
      'removes the notification from the list',
      build: () {
        when(() => mockDelete('1')).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => NotificationsLoaded(
        items: tItems,
        unreadCount: 2,
        hasMore: false,
        currentPage: 1,
      ),
      act: (b) => b.add(const DeleteNotification('1')),
      expect: () => [
        NotificationsLoaded(
          items: [makeNotif(id: '2')],
          unreadCount: 1,
          hasMore: false,
          currentPage: 1,
        ),
      ],
    );
  });

  // ── DeleteAllNotifications ───────────────────────────────────────────────

  group('DeleteAllNotifications', () {
    blocTest<NotificationsBloc, NotificationsState>(
      'emits empty Loaded state',
      build: () {
        when(() => mockDeleteAll()).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      seed: () => NotificationsLoaded(
        items: [
          makeNotif(id: '1'),
          makeNotif(id: '2'),
        ],
        unreadCount: 2,
        hasMore: false,
        currentPage: 1,
      ),
      act: (b) => b.add(const DeleteAllNotifications()),
      expect: () => [
        const NotificationsLoaded(
          items: [],
          unreadCount: 0,
          hasMore: false,
          currentPage: 1,
        ),
      ],
    );
  });

  // ── LoadMoreNotifications ────────────────────────────────────────────────

  group('LoadMoreNotifications', () {
    final page1 = [makeNotif(id: '1'), makeNotif(id: '2')];
    final page2 = [makeNotif(id: '3')];

    blocTest<NotificationsBloc, NotificationsState>(
      'appends second page and sets hasMore=false',
      build: () {
        when(() => mockGet(page: 2, limit: 20)).thenAnswer(
          (_) async => Right((items: page2, unreadCount: 0, hasMore: false)),
        );
        return bloc;
      },
      seed: () => NotificationsLoaded(
        items: page1,
        unreadCount: 0,
        hasMore: true,
        currentPage: 1,
      ),
      act: (b) => b.add(const LoadMoreNotifications()),
      expect: () => [
        NotificationsLoadingMore(
          items: page1,
          unreadCount: 0,
          hasMore: true,
          currentPage: 1,
        ),
        NotificationsLoaded(
          items: [...page1, ...page2],
          unreadCount: 0,
          hasMore: false,
          currentPage: 2,
        ),
      ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'does nothing when hasMore is false',
      build: () => bloc,
      seed: () => const NotificationsLoaded(
        items: [],
        unreadCount: 0,
        hasMore: false,
        currentPage: 1,
      ),
      act: (b) => b.add(const LoadMoreNotifications()),
      expect: () => [],
    );
  });
}
