// lib/features/manage_event/domain/usecases/get_my_venues_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/manage_event/domain/entities/saved_venue_entity.dart';
import 'package:wap_app/features/manage_event/domain/repositories/manage_event_repository.dart';

class GetMyVenuesUseCase {
  final ManageEventRepository repository;
  GetMyVenuesUseCase(this.repository);

  Future<Either<Failure, List<SavedVenueEntity>>> call({
    int page = 1,
    int limit = 5,
  }) async {
    return await repository.getMyVenues(page: page, limit: limit);
  }
}
