// lib/features/user_actions/domain/usecases/add_event_to_favorites.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/user_actions/domain/repositories/user_actions_repository.dart';

class AddEventToFavoritesUseCase {
  final UserActionsRepository repository;

  AddEventToFavoritesUseCase(this.repository);

  Future<Either<Failure, void>> call(String eventId) async {
    return await repository.addEventToFavorites(eventId);
  }
}
