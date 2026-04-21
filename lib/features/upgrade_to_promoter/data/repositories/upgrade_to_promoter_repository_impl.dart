// lib/features/upgrade_to_promoter/data/repositories/upgrade_to_promoter_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/exceptions.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/core/utils/app_logger.dart';
import 'package:wap_app/features/upgrade_to_promoter/data/datasources/upgrade_to_promoter_remote_data_source.dart';
import 'package:wap_app/features/upgrade_to_promoter/domain/repositories/upgrade_to_promoter_repository.dart';

class UpgradeToPromoterRepositoryImpl implements UpgradeToPromoterRepository {
  final UpgradeToPromoterRemoteDataSource remoteDataSource;

  UpgradeToPromoterRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> upgradeToPromoter() async {
    try {
      await remoteDataSource.upgradeToPromoter();
      return const Right(null);
    } on ServerException catch (e) {
      AppLogger.error('ServerException in upgradeToPromoter', e, null);
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      AppLogger.error('NetworkException in upgradeToPromoter', e, null);
      return Left(NetworkFailure(message: e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in upgradeToPromoter', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
