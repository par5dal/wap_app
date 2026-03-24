// lib/features/profile/domain/usecases/get_blocked_promoters.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/profile/domain/entities/blocked_promoter.dart';
import 'package:wap_app/features/profile/domain/repositories/profile_repository.dart';

class GetBlockedPromotersUseCase {
  final ProfileRepository repository;

  GetBlockedPromotersUseCase(this.repository);

  Future<Either<Failure, List<BlockedPromoter>>> call({int limit = 50}) async {
    return await repository.getBlockedPromoters(limit: limit);
  }
}
