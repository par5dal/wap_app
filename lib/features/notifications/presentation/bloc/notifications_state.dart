// lib/features/notifications/presentation/bloc/notifications_state.dart

part of 'notifications_bloc.dart';

abstract class NotificationsState extends Equatable {
  final List<UserNotification> items;
  final int unreadCount;
  final bool hasMore;
  final int currentPage;

  const NotificationsState({
    this.items = const [],
    this.unreadCount = 0,
    this.hasMore = false,
    this.currentPage = 0,
  });

  @override
  List<Object?> get props => [items, unreadCount, hasMore, currentPage];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial() : super();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading() : super();
}

class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded({
    required super.items,
    required super.unreadCount,
    required super.hasMore,
    required super.currentPage,
  });

  NotificationsLoaded copyWith({
    List<UserNotification>? items,
    int? unreadCount,
    bool? hasMore,
    int? currentPage,
  }) {
    return NotificationsLoaded(
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class NotificationsLoadingMore extends NotificationsLoaded {
  const NotificationsLoadingMore({
    required super.items,
    required super.unreadCount,
    required super.hasMore,
    required super.currentPage,
  });
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError({
    required this.message,
    super.items,
    super.unreadCount,
  });

  @override
  List<Object?> get props => [message, ...super.props];
}
