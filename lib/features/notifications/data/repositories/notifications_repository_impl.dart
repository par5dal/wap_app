// lib/features/notifications/data/repositories/notifications_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:wap_app/features/notifications/domain/entities/user_notification.dart';
import 'package:wap_app/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<
    Either<
      Failure,
      ({List<UserNotification> items, int unreadCount, bool hasMore})
    >
  >
  getNotifications({int page = 1, int limit = 20}) async {
    try {
      final result = await remoteDataSource.getNotifications(
        page: page,
        limit: limit,
      );
      return Right((
        items: result.items,
        unreadCount: result.unreadCount,
        hasMore: result.hasMore,
      ));
    } on ServerException catch (e) {
      AppLogger.error('ServerException in getNotifications', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in getNotifications', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in getNotifications', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await remoteDataSource.getUnreadCount();
      return Right(count);
    } on ServerException catch (e) {
      AppLogger.error('ServerException in getUnreadCount', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in getUnreadCount', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in getUnreadCount', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markRead(String id) async {
    try {
      await remoteDataSource.markRead(id);
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('ServerException in markRead', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in markRead', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in markRead', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllRead() async {
    try {
      await remoteDataSource.markAllRead();
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('ServerException in markAllRead', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in markAllRead', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in markAllRead', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteOne(String id) async {
    try {
      await remoteDataSource.deleteOne(id);
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('ServerException in deleteOne', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in deleteOne', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in deleteOne', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAll() async {
    try {
      await remoteDataSource.deleteAll();
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('ServerException in deleteAll', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in deleteAll', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in deleteAll', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
