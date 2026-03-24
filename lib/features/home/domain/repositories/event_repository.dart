// lib/features/events/domain/repositories/event_repository.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';

abstract class EventRepository {
  Future<Either<Failure, List<Event>>> getNearbyEvents({
    required double latitude,
    required double longitude,
    double radius = 10.0,
  });

  Future<Either<Failure, Event>> getEventById(String eventId);

  Future<Either<Failure, List<Event>>> getEventsForMapBounds({
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
  });

  Future<Either<Failure, List<Map<String, dynamic>>>> getGridClusters({
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
    double gridSize = 0.5,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
  });
}
