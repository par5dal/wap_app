// lib/features/profile/domain/repositories/profile_repository.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/profile/domain/entities/profile_entity.dart';
import 'package:wap_app/features/profile/domain/entities/user_with_profile_entity.dart';
import 'package:wap_app/features/profile/domain/entities/followed_promoter.dart';
import 'package:wap_app/features/profile/domain/entities/blocked_promoter.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserWithProfileEntity>> getMyProfile();
  Future<Either<Failure, ProfileEntity>> updateMyProfile(
    Map<String, dynamic> profileData,
  );
  Future<Either<Failure, Map<String, dynamic>>> getUploadSignature({
    required String preset,
    required String uploadType,
    String? eventId,
    String? transformation,
  });
  Future<Either<Failure, void>> deleteResource(String url);
  Future<Either<Failure, List<FollowedPromoter>>> getFollowedPromoters({
    int limit = 50,
  });
  Future<Either<Failure, List<BlockedPromoter>>> getBlockedPromoters({
    int limit = 50,
  });
}
