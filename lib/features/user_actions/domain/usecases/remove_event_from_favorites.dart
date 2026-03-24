// lib/features/user_actions/domain/usecases/remove_event_from_favorites.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/user_actions/domain/repositories/user_actions_repository.dart';

class RemoveEventFromFavoritesUseCase {
  final UserActionsRepository repository;

  RemoveEventFromFavoritesUseCase(this.repository);

  Future<Either<Failure, void>> call(String eventId) async {
    return await repository.removeEventFromFavorites(eventId);
  }
}
