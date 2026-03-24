// lib/features/notifications/domain/usecases/get_notifications.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/notifications/domain/entities/user_notification.dart';
import 'package:wap_app/features/notifications/domain/repositories/notifications_repository.dart';

class GetNotificationsUseCase {
  final NotificationsRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<
    Either<
      Failure,
      ({List<UserNotification> items, int unreadCount, bool hasMore})
    >
  >
  call({int page = 1, int limit = 20}) {
    return repository.getNotifications(page: page, limit: limit);
  }
}
