// lib/features/notifications/domain/usecases/get_unread_count.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/notifications/domain/repositories/notifications_repository.dart';

class GetUnreadCountUseCase {
  final NotificationsRepository repository;

  GetUnreadCountUseCase(this.repository);

  Future<Either<Failure, int>> call() {
    return repository.getUnreadCount();
  }
}
