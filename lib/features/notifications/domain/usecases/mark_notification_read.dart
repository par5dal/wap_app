// lib/features/notifications/domain/usecases/mark_notification_read.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/notifications/domain/repositories/notifications_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationsRepository repository;

  MarkNotificationReadUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.markRead(id);
  }
}
