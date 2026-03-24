// lib/features/user_actions/domain/repositories/user_actions_repository.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';

abstract class UserActionsRepository {
  // Favoritos
  Future<Either<Failure, void>> addEventToFavorites(String eventId);
  Future<Either<Failure, void>> removeEventFromFavorites(String eventId);

  // Seguir promotores
  Future<Either<Failure, void>> followPromoter(String promoterId);
  Future<Either<Failure, void>> unfollowPromoter(String promoterId);

  // Bloquear usuarios
  Future<Either<Failure, List<String>>> getBlockedUsers();
  Future<Either<Failure, void>> blockUser(String userId);
  Future<Either<Failure, void>> unblockUser(String userId);
}
