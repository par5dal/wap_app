// lib/features/promoter_profile/data/repositories/promoter_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/home/data/models/event_model.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/features/promoter_profile/data/datasources/promoter_remote_data_source.dart';
import 'package:wap_app/features/promoter_profile/domain/entities/promoter_profile.dart';
import 'package:wap_app/features/promoter_profile/domain/repositories/promoter_repository.dart';

class PromoterRepositoryImpl implements PromoterRepository {
  final PromoterRemoteDataSource remoteDataSource;

  PromoterRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PromoterProfile>> getPromoterProfile(
    String promoterId,
  ) async {
    try {
      final profileModel = await remoteDataSource.getPromoterProfile(
        promoterId,
      );
      return Right(profileModel.toEntity());
    } on ServerException catch (e) {
      AppLogger.error('ServerException in getPromoterProfile', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in getPromoterProfile', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in getPromoterProfile', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getPromoterEvents({
    required String promoterId,
    int page = 1,
    int limit = 10,
    double? userLatitude,
    double? userLongitude,
  }) async {
    try {
      final eventModels = await remoteDataSource.getPromoterEvents(
        promoterId: promoterId,
        page: page,
        limit: limit,
      );

      // Convertir modelos a entidades calculando distancia
      final events = eventModels.map((model) {
        // Calcular distancia si tenemos ubicación del usuario
        double? distanceInKm;
        if (userLatitude != null && userLongitude != null) {
          final distanceInMeters = Geolocator.distanceBetween(
            userLatitude,
            userLongitude,
            model.venue.location.latitude,
            model.venue.location.longitude,
          );
          distanceInKm = distanceInMeters / 1000;
        }
        return model.toEntity(calculatedDistance: distanceInKm);
      }).toList();

      return Right(events);
    } on ServerException catch (e) {
      AppLogger.error('ServerException in getPromoterEvents', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in getPromoterEvents', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in getPromoterEvents', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
