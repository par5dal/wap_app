// lib/features/promoter_dashboard/domain/usecases/get_my_events_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/promoter_dashboard/domain/entities/my_event_entity.dart';
import 'package:wap_app/features/promoter_dashboard/domain/repositories/promoter_dashboard_repository.dart';

class GetMyEventsUseCase {
  final PromoterDashboardRepository repository;
  GetMyEventsUseCase(this.repository);

  Future<Either<Failure, List<MyEventEntity>>> call({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    return await repository.getMyEvents(
      page: page,
      limit: limit,
      search: search,
    );
  }
}
