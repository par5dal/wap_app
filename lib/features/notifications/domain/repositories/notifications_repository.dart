// lib/features/notifications/domain/repositories/notifications_repository.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/notifications/domain/entities/user_notification.dart';

abstract class NotificationsRepository {
  Future<
    Either<
      Failure,
      ({List<UserNotification> items, int unreadCount, bool hasMore})
    >
  >
  getNotifications({int page = 1, int limit = 20});

  Future<Either<Failure, int>> getUnreadCount();

  Future<Either<Failure, void>> markRead(String id);

  Future<Either<Failure, void>> markAllRead();

  Future<Either<Failure, void>> deleteOne(String id);

  Future<Either<Failure, void>> deleteAll();
}
