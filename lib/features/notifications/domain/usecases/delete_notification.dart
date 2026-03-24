// lib/features/notifications/domain/usecases/delete_notification.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/notifications/domain/repositories/notifications_repository.dart';

class DeleteNotificationUseCase {
  final NotificationsRepository repository;

  DeleteNotificationUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteOne(id);
  }
}
