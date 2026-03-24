// lib/features/notifications/domain/usecases/delete_all_notifications.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/notifications/domain/repositories/notifications_repository.dart';

class DeleteAllNotificationsUseCase {
  final NotificationsRepository repository;

  DeleteAllNotificationsUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.deleteAll();
  }
}
