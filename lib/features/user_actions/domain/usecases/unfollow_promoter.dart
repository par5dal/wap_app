// lib/features/user_actions/domain/usecases/unfollow_promoter.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/user_actions/domain/repositories/user_actions_repository.dart';

class UnfollowPromoterUseCase {
  final UserActionsRepository repository;

  UnfollowPromoterUseCase(this.repository);

  Future<Either<Failure, void>> call(String promoterId) async {
    return await repository.unfollowPromoter(promoterId);
  }
}
