// lib/features/promoter_dashboard/domain/usecases/delete_my_event_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:wap_app/core/error/failures.dart';
import 'package:wap_app/features/promoter_dashboard/domain/repositories/promoter_dashboard_repository.dart';

class DeleteMyEventUseCase {
  final PromoterDashboardRepository repository;
  DeleteMyEventUseCase(this.repository);

  Future<Either<Failure, void>> call(String eventId) async {
    return await repository.deleteEvent(eventId);
  }
}
