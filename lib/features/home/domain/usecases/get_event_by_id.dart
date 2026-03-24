// lib/features/home/domain/usecases/get_event_by_id.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/features/home/domain/repositories/event_repository.dart';

class GetEventByIdUseCase {
  final EventRepository repository;

  GetEventByIdUseCase(this.repository);

  Future<Either<Failure, Event>> call(String eventId) async {
    return await repository.getEventById(eventId);
  }
}
