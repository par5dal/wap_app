// lib/features/manage_event/data/repositories/manage_event_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/manage_event/data/datasources/manage_event_remote_data_source.dart';
import 'package:wap_app/features/manage_event/domain/entities/category_entity.dart';
import 'package:wap_app/features/manage_event/domain/entities/saved_venue_entity.dart';
import 'package:wap_app/features/manage_event/domain/repositories/manage_event_repository.dart';
import 'package:wap_app/features/promoter_dashboard/domain/entities/my_event_entity.dart';

class ManageEventRepositoryImpl implements ManageEventRepository {
  final ManageEventRemoteDataSource remoteDataSource;

  ManageEventRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      return Right(await remoteDataSource.getCategories());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e, st) {
      AppLogger.error('Unexpected error in getCategories', e, st);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SavedVenueEntity>>> getMyVenues({
    int page = 1,
    int limit = 5,
  }) async {
    try {
      return Right(
        await remoteDataSource.getMyVenues(page: page, limit: limit),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e, st) {
      AppLogger.error('Unexpected error in getMyVenues', e, st);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MyEventEntity>> getEventById(String eventId) async {
    try {
      final model = await remoteDataSource.getEventById(eventId);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e, st) {
      AppLogger.error('Unexpected error in getEventById', e, st);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createEvent(
    Map<String, dynamic> payload,
  ) async {
    try {
      return Right(await remoteDataSource.createEvent(payload));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e, st) {
      AppLogger.error('Unexpected error in createEvent', e, st);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateEvent(
    String eventId,
    Map<String, dynamic> payload,
  ) async {
    try {
      await remoteDataSource.updateEvent(eventId, payload);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e, st) {
      AppLogger.error('Unexpected error in updateEvent', e, st);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitEventForReview(String eventId) async {
    try {
      await remoteDataSource.submitEventForReview(eventId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
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
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e, st) {
      AppLogger.error('Unexpected error in unpublishEvent', e, st);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUploadSignature({
    required String preset,
    String? eventId,
  }) async {
    try {
      return Right(
        await remoteDataSource.getUploadSignature(
          preset: preset,
          eventId: eventId,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e, st) {
      AppLogger.error('Unexpected error in getUploadSignature', e, st);
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
