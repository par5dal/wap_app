// lib/features/promoter_dashboard/domain/usecases/get_my_events_stats_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/promoter_dashboard/domain/entities/my_events_stats_entity.dart';
import 'package:wap_app/features/promoter_dashboard/domain/repositories/promoter_dashboard_repository.dart';

class GetMyEventsStatsUseCase {
  final PromoterDashboardRepository repository;
  GetMyEventsStatsUseCase(this.repository);

  Future<Either<Failure, MyEventsStatsEntity>> call() async {
    return await repository.getMyEventsStats();
  }
}
