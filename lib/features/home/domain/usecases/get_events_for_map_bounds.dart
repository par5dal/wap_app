// lib/features/events/domain/usecases/get_events_for_map_bounds.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/features/home/domain/repositories/event_repository.dart';

class GetEventsForMapBoundsUseCase {
  final EventRepository repository;

  GetEventsForMapBoundsUseCase(this.repository);

  Future<Either<Failure, List<Event>>> call({
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
    String? zoomLevel,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    double? userLatitude,
    double? userLongitude,
  }) async {
    return await repository.getEventsForMapBounds(
      swLat: swLat,
      swLng: swLng,
      neLat: neLat,
      neLng: neLng,
      zoomLevel: zoomLevel,
      categoryId: categoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
    );
  }
}
