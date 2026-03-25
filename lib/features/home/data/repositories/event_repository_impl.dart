// lib/features/events/data/repositories/event_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/home/data/datasources/event_remote_data_source.dart';
import 'package:wap_app/features/home/data/datasources/location_data_source.dart';
import 'package:wap_app/features/home/data/models/event_model.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/features/home/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;
  final LocationDataSource locationDataSource;

  EventRepositoryImpl({
    required this.remoteDataSource,
    required this.locationDataSource,
  });

  @override
  Future<Either<Failure, List<Event>>> getNearbyEvents({
    required double latitude,
    required double longitude,
    double radius = 5000.0,
  }) async {
    try {
      final eventModels = await remoteDataSource.getNearbyEvents(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );

      // Convertir modelos a entidades y calcular distancias
      final events = eventModels.map((model) {
        // Calcular distancia entre usuario y evento
        final distanceInMeters = Geolocator.distanceBetween(
          latitude,
          longitude,
          model.venue.location.latitude,
          model.venue.location.longitude,
        );

        final distanceInKm = distanceInMeters / 1000;

        // Convertir a entidad pasando la distancia calculada
        return model.toEntity(calculatedDistance: distanceInKm);
      }).toList();

      return Right(events);
    } on ServerException catch (e) {
      AppLogger.error('ServerException in getNearbyEvents', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in getNearbyEvents', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in getNearbyEvents', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Event>> getEventById(String eventId) async {
    try {
      final eventModel = await remoteDataSource.getEventById(eventId);
      return Right(eventModel.toEntity());
    } on ServerException catch (e) {
      AppLogger.error('ServerException in getEventById', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in getEventById', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in getEventById', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final eventModels = await remoteDataSource.getEventsForMapBounds(
        swLat: swLat,
        swLng: swLng,
        neLat: neLat,
        neLng: neLng,
        zoomLevel: zoomLevel,
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

      // Convertir modelos a entidades y calcular distancia si tenemos ubicación del usuario
      final events = eventModels.map((model) {
        if (userLatitude != null && userLongitude != null) {
          // Calcular distancia entre usuario y evento
          final distanceInMeters = Geolocator.distanceBetween(
            userLatitude,
            userLongitude,
            model.venue.location.latitude,
            model.venue.location.longitude,
          );
          final distanceInKm = distanceInMeters / 1000;
          return model.toEntity(calculatedDistance: distanceInKm);
        }
        return model.toEntity();
      }).toList();

      return Right(events);
    } on ServerException catch (e) {
      AppLogger.error('ServerException in getEventsForMapBounds', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in getEventsForMapBounds', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in getEventsForMapBounds',
        e,
        stackTrace,
      );
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getGridClusters({
    required double swLat,
    required double swLng,
    required double neLat,
    required double neLng,
    double gridSize = 0.5,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final clusters = await remoteDataSource.getGridClusters(
        swLat: swLat,
        swLng: swLng,
        neLat: neLat,
        neLng: neLng,
        gridSize: gridSize,
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

      return Right(clusters);
    } on ServerException catch (e) {
      AppLogger.error('ServerException in getGridClusters', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in getGridClusters', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in getGridClusters', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<void> recordView(String eventId) async {
    // Fire-and-forget: errors are silenced in the data source
    await remoteDataSource.recordView(eventId);
  }
}
