// lib/features/manage_event/domain/usecases/save_event_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/manage_event/domain/repositories/manage_event_repository.dart';

class SaveEventUseCase {
  final ManageEventRepository repository;
  SaveEventUseCase(this.repository);

  /// Returns the event id (for both create and update)
  Future<Either<Failure, String>> call({
    String? eventId, // null = create
    required Map<String, dynamic> payload,
  }) async {
    if (eventId == null) {
      return await repository.createEvent(payload);
    } else {
      final result = await repository.updateEvent(eventId, payload);
      return result.map((_) => eventId);
    }
  }
}
