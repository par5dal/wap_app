// lib/features/user_actions/data/repositories/user_actions_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/user_actions/data/datasources/user_actions_remote_data_source.dart';
import 'package:wap_app/features/user_actions/domain/repositories/user_actions_repository.dart';

class UserActionsRepositoryImpl implements UserActionsRepository {
  final UserActionsRemoteDataSource remoteDataSource;

  UserActionsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> addEventToFavorites(String eventId) async {
    try {
      await remoteDataSource.addEventToFavorites(eventId);
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('ServerException in addEventToFavorites', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in addEventToFavorites', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in addEventToFavorites', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeEventFromFavorites(String eventId) async {
    try {
      await remoteDataSource.removeEventFromFavorites(eventId);
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('ServerException in removeEventFromFavorites', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in removeEventFromFavorites', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error in removeEventFromFavorites',
        e,
        stackTrace,
      );
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> followPromoter(String promoterId) async {
    try {
      await remoteDataSource.followPromoter(promoterId);
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('ServerException in followPromoter', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in followPromoter', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in followPromoter', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unfollowPromoter(String promoterId) async {
    try {
      await remoteDataSource.unfollowPromoter(promoterId);
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('ServerException in unfollowPromoter', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in unfollowPromoter', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in unfollowPromoter', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getBlockedUsers() async {
    try {
      final ids = await remoteDataSource.getBlockedUsers();
      return Right(ids);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in getBlockedUsers', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> blockUser(String userId) async {
    try {
      await remoteDataSource.blockUser(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in blockUser', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unblockUser(String userId) async {
    try {
      await remoteDataSource.unblockUser(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in unblockUser', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
