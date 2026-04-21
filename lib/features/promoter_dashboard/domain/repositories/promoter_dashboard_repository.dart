// lib/features/promoter_dashboard/domain/repositories/promoter_dashboard_repository.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/promoter_dashboard/domain/entities/my_event_entity.dart';
import 'package:wap_app/features/promoter_dashboard/domain/entities/my_events_stats_entity.dart';

abstract class PromoterDashboardRepository {
  Future<Either<Failure, List<MyEventEntity>>> getMyEvents({
    int page = 1,
    int limit = 10,
    String? search,
  });

  Future<Either<Failure, MyEventsStatsEntity>> getMyEventsStats();

  Future<Either<Failure, void>> deleteEvent(String eventId);

  Future<Either<Failure, void>> submitEventForReview(String eventId);

  Future<Either<Failure, void>> unpublishEvent(String eventId);
}
