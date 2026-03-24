// lib/features/notifications/presentation/bloc/notifications_event.dart

part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationsEvent {
  const LoadNotifications();
}

class LoadMoreNotifications extends NotificationsEvent {
  const LoadMoreNotifications();
}

class RefreshUnreadCount extends NotificationsEvent {
  const RefreshUnreadCount();
}

class MarkNotificationRead extends NotificationsEvent {
  final String id;
  const MarkNotificationRead(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkAllNotificationsRead extends NotificationsEvent {
  const MarkAllNotificationsRead();
}

class DeleteNotification extends NotificationsEvent {
  final String id;
  const DeleteNotification(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteAllNotifications extends NotificationsEvent {
  const DeleteAllNotifications();
}
