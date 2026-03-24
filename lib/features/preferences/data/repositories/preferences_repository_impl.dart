// lib/features/preferences/data/repositories/preferences_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/preferences/data/datasources/preferences_remote_data_source.dart';
import 'package:wap_app/features/preferences/domain/entities/user_preferences.dart';
import 'package:wap_app/features/preferences/domain/repositories/preferences_repository.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferencesRemoteDataSource remoteDataSource;
  PreferencesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserPreferences>> getPreferences() async {
    try {
      final prefs = await remoteDataSource.getPreferences();
      return Right(prefs);
    } on ServerException catch (e) {
      AppLogger.error('ServerException in getPreferences', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in getPreferences', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, st) {
      AppLogger.error('Unexpected error in getPreferences', e, st);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserPreferences>> updatePreferences({
    required String lang,
  }) async {
    try {
      final prefs = await remoteDataSource.updatePreferences(lang: lang);
      return Right(prefs);
    } on ServerException catch (e) {
      AppLogger.error('ServerException in updatePreferences', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in updatePreferences', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, st) {
      AppLogger.error('Unexpected error in updatePreferences', e, st);
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
