// lib/features/events/domain/usecases/get_nearby_events.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/features/home/domain/repositories/event_repository.dart';

class GetNearbyEventsUseCase {
  final EventRepository repository;

  GetNearbyEventsUseCase(this.repository);

  Future<Either<Failure, List<Event>>> call({
    required double latitude,
    required double longitude,
    double radius = 5000.0,
  }) async {
    return await repository.getNearbyEvents(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );
  }
}
