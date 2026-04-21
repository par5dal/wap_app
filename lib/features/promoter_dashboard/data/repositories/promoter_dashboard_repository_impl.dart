// lib/features/promoter_dashboard/data/repositories/promoter_dashboard_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/promoter_dashboard/data/datasources/promoter_dashboard_remote_data_source.dart';
import 'package:wap_app/features/promoter_dashboard/domain/entities/my_event_entity.dart';
import 'package:wap_app/features/promoter_dashboard/domain/entities/my_events_stats_entity.dart';
import 'package:wap_app/features/promoter_dashboard/domain/repositories/promoter_dashboard_repository.dart';

class PromoterDashboardRepositoryImpl implements PromoterDashboardRepository {
  final PromoterDashboardRemoteDataSource remoteDataSource;

  PromoterDashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MyEventEntity>>> getMyEvents({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final models = await remoteDataSource.getMyEvents(
        page: page,
        limit: limit,
        search: search,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      AppLogger.error('ServerException in getMyEvents', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in getMyEvents', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, st) {
      AppLogger.error('Unexpected error in getMyEvents', e, st);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MyEventsStatsEntity>> getMyEventsStats() async {
    try {
      final stats = await remoteDataSource.getMyEventsStats();
      return Right(stats);
    } on ServerException catch (e) {
      AppLogger.error('ServerException in getMyEventsStats', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in getMyEventsStats', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, st) {
      AppLogger.error('Unexpected error in getMyEventsStats', e, st);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(String eventId) async {
    try {
      await remoteDataSource.deleteEvent(eventId);
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('ServerException in deleteEvent', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in deleteEvent', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, st) {
      AppLogger.error('Unexpected error in deleteEvent', e, st);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitEventForReview(String eventId) async {
    try {
      await remoteDataSource.submitEventForReview(eventId);
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('ServerException in submitEventForReview', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in submitEventForReview', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, st) {
      AppLogger.error('Unexpected error in submitEventForReview', e, st);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unpublishEvent(String eventId) async {
    try {
      await remoteDataSource.unpublishEvent(eventId);
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('ServerException in unpublishEvent', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in unpublishEvent', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, st) {
      AppLogger.error('Unexpected error in unpublishEvent', e, st);
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
