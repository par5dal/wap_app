// lib/features/profile/data/repositories/profile_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/error_handler.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:wap_app/features/profile/domain/entities/profile_entity.dart';
import 'package:wap_app/features/profile/domain/entities/user_with_profile_entity.dart';
import 'package:wap_app/features/profile/domain/entities/followed_promoter.dart';
import 'package:wap_app/features/profile/domain/entities/blocked_promoter.dart';
import 'package:wap_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserWithProfileEntity>> getMyProfile() async {
    try {
      final result = await remoteDataSource.getMyProfile();
      return Right(result);
    } catch (e, stackTrace) {
      // ✅ CAMBIADO: handleError -> handleException
      return Left(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateMyProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final result = await remoteDataSource.updateMyProfile(profileData);
      return Right(result);
    } catch (e, stackTrace) {
      // ✅ CAMBIADO: handleError -> handleException
      return Left(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUploadSignature({
    required String preset,
    required String uploadType,
    String? eventId,
    String? transformation,
  }) async {
    try {
      final result = await remoteDataSource.getUploadSignature(
        preset: preset,
        uploadType: uploadType,
        eventId: eventId,
        transformation: transformation,
      );
      return Right(result);
    } catch (e, stackTrace) {
      // ✅ CAMBIADO: handleError -> handleException
      return Left(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> deleteResource(String url) async {
    try {
      await remoteDataSource.deleteResource(url);
      return const Right(null);
    } catch (e, stackTrace) {
      // ✅ CAMBIADO: handleError -> handleException
      return Left(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<FollowedPromoter>>> getFollowedPromoters({
    int limit = 50,
  }) async {
    try {
      final models = await remoteDataSource.getFollowedPromoters(limit: limit);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleException(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, List<BlockedPromoter>>> getBlockedPromoters({
    int limit = 50,
  }) async {
    try {
      final models = await remoteDataSource.getBlockedPromotersFull(
        limit: limit,
      );
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleException(e, stackTrace));
    }
  }
}
