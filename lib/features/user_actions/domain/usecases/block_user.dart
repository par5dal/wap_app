// lib/features/user_actions/domain/usecases/block_user.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/user_actions/domain/repositories/user_actions_repository.dart';

class BlockUserUseCase {
  final UserActionsRepository repository;

  BlockUserUseCase(this.repository);

  Future<Either<Failure, void>> call(String userId) async {
    return await repository.blockUser(userId);
  }
}
