// lib/features/notifications/presentation/bloc/notifications_bloc.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/notifications/domain/entities/user_notification.dart';
import 'package:wap_app/features/notifications/domain/usecases/delete_all_notifications.dart';
import 'package:wap_app/features/notifications/domain/usecases/delete_notification.dart';
import 'package:wap_app/features/notifications/domain/usecases/get_notifications.dart';
import 'package:wap_app/features/notifications/domain/usecases/get_unread_count.dart';
import 'package:wap_app/features/notifications/domain/usecases/mark_all_notifications_read.dart';
import 'package:wap_app/features/notifications/domain/usecases/mark_notification_read.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationsUseCase getNotifications;
  final GetUnreadCountUseCase getUnreadCount;
  final MarkNotificationReadUseCase markNotificationRead;
  final MarkAllNotificationsReadUseCase markAllNotificationsRead;
  final DeleteNotificationUseCase deleteNotification;
  final DeleteAllNotificationsUseCase deleteAllNotifications;

  static const int _pageSize = 20;

  NotificationsBloc({
    required this.getNotifications,
    required this.getUnreadCount,
    required this.markNotificationRead,
    required this.markAllNotificationsRead,
    required this.deleteNotification,
    required this.deleteAllNotifications,
  }) : super(const NotificationsInitial()) {
    on<LoadNotifications>(_onLoad);
    on<LoadMoreNotifications>(_onLoadMore);
    on<RefreshUnreadCount>(_onRefreshUnreadCount);
    on<MarkNotificationRead>(_onMarkRead);
    on<MarkAllNotificationsRead>(_onMarkAllRead);
    on<DeleteNotification>(_onDelete);
    on<DeleteAllNotifications>(_onDeleteAll);
  }

  Future<void> _onLoad(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());
    final result = await getNotifications(page: 1, limit: _pageSize);
    result.fold(
      (failure) {
        AppLogger.error('LoadNotifications failure', failure, null);
        emit(NotificationsError(message: failure.message));
      },
      (data) => emit(
        NotificationsLoaded(
          items: data.items,
          unreadCount: data.unreadCount,
          hasMore: data.hasMore,
          currentPage: 1,
        ),
      ),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state;
    if (current is! NotificationsLoaded || !current.hasMore) return;
    if (current is NotificationsLoadingMore) return;

    emit(
      NotificationsLoadingMore(
        items: current.items,
        unreadCount: current.unreadCount,
        hasMore: current.hasMore,
        currentPage: current.currentPage,
      ),
    );

    final nextPage = current.currentPage + 1;
    final result = await getNotifications(page: nextPage, limit: _pageSize);
    result.fold(
      (failure) {
        AppLogger.error('LoadMoreNotifications failure', failure, null);
        emit(
          NotificationsError(
            message: failure.message,
            items: current.items,
            unreadCount: current.unreadCount,
          ),
        );
      },
      (data) => emit(
        NotificationsLoaded(
          items: [...current.items, ...data.items],
          unreadCount: data.unreadCount,
          hasMore: data.hasMore,
          currentPage: nextPage,
        ),
      ),
    );
  }

  Future<void> _onRefreshUnreadCount(
    RefreshUnreadCount event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await getUnreadCount();
    result.fold(
      (failure) => AppLogger.error('RefreshUnreadCount failure', failure, null),
      (count) {
        final current = state;
        if (current is NotificationsLoaded) {
          emit(current.copyWith(unreadCount: count));
        } else {
          // State is Initial or Error — emit a minimal loaded state so the
          // badge in the toolbar and profile page reflects the real count
          // before the user ever opens the notifications page.
          emit(
            NotificationsLoaded(
              items: current.items,
              unreadCount: count,
              hasMore: current.hasMore,
              currentPage: current.currentPage,
            ),
          );
        }
      },
    );
  }

  Future<void> _onMarkRead(
    MarkNotificationRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state;
    final result = await markNotificationRead(event.id);
    result.fold(
      (failure) =>
          AppLogger.error('MarkNotificationRead failure', failure, null),
      (_) {
        if (current is NotificationsLoaded) {
          final updated = current.items.map((n) {
            return n.id == event.id ? n.copyWith(isRead: true) : n;
          }).toList();
          final newUnread = updated.where((n) => !n.isRead).length;
          emit(current.copyWith(items: updated, unreadCount: newUnread));
        }
      },
    );
  }

  Future<void> _onMarkAllRead(
    MarkAllNotificationsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state;
    final result = await markAllNotificationsRead();
    result.fold(
      (failure) =>
          AppLogger.error('MarkAllNotificationsRead failure', failure, null),
      (_) {
        if (current is NotificationsLoaded) {
          final updated = current.items
              .map((n) => n.copyWith(isRead: true))
              .toList();
          emit(current.copyWith(items: updated, unreadCount: 0));
        }
      },
    );
  }

  Future<void> _onDelete(
    DeleteNotification event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state;
    final result = await deleteNotification(event.id);
    result.fold(
      (failure) => AppLogger.error('DeleteNotification failure', failure, null),
      (_) {
        if (current is NotificationsLoaded) {
          final updated = current.items.where((n) => n.id != event.id).toList();
          final newUnread = updated.where((n) => !n.isRead).length;
          emit(current.copyWith(items: updated, unreadCount: newUnread));
        }
      },
    );
  }

  Future<void> _onDeleteAll(
    DeleteAllNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await deleteAllNotifications();
    result.fold(
      (failure) =>
          AppLogger.error('DeleteAllNotifications failure', failure, null),
      (_) => emit(
        const NotificationsLoaded(
          items: [],
          unreadCount: 0,
          hasMore: false,
          currentPage: 1,
        ),
      ),
    );
  }
}
