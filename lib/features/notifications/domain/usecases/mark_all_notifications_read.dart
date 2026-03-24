// lib/features/notifications/domain/usecases/mark_all_notifications_read.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/notifications/domain/repositories/notifications_repository.dart';

class MarkAllNotificationsReadUseCase {
  final NotificationsRepository repository;

  MarkAllNotificationsReadUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.markAllRead();
  }
}
