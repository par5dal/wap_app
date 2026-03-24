// lib/features/profile/domain/usecases/get_followed_promoters.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/profile/domain/entities/followed_promoter.dart';
import 'package:wap_app/features/profile/domain/repositories/profile_repository.dart';

class GetFollowedPromotersUseCase {
  final ProfileRepository repository;

  GetFollowedPromotersUseCase(this.repository);

  Future<Either<Failure, List<FollowedPromoter>>> call({int limit = 50}) async {
    return await repository.getFollowedPromoters(limit: limit);
  }
}
