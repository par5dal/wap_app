// lib/features/promoter_profile/domain/usecases/get_promoter_events.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/home/domain/entities/event.dart';
import 'package:wap_app/features/promoter_profile/domain/repositories/promoter_repository.dart';

class GetPromoterEventsUseCase {
  final PromoterRepository repository;

  GetPromoterEventsUseCase(this.repository);

  Future<Either<Failure, List<Event>>> call({
    required String promoterId,
    int page = 1,
    int limit = 10,
    double? userLatitude,
    double? userLongitude,
  }) async {
    return await repository.getPromoterEvents(
      promoterId: promoterId,
      page: page,
      limit: limit,
      userLatitude: userLatitude,
      userLongitude: userLongitude,
    );
  }
}
